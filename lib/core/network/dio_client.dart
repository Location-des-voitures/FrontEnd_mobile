/// -------------------------------------------------------
/// DIO CLIENT — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------
/// Gère la structure de réponse Laravel :
///   { "success": true/false, "message": "...", "data": {...} }
///
/// Gère tous les codes d'erreur documentés :
///   401 → AuthException (3 cas : missing, expired, invalid token + wrong credentials)
///   403 → ForbiddenException (3 cas : deactivated, unverified, wrong role)
///   404 → NotFoundException
///   422 → ValidationException (validation + protected fields + reset token)
///   429 → RateLimitException (avec retry_after)
///   500 → ServerException
/// -------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptor : Token JWT automatique ───────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 → token expiré → nettoyer le stockage
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: AppConstants.tokenKey);
            await _storage.delete(key: AppConstants.userKey);
          }
          handler.next(error);
        },
      ),
    );

    // ── Interceptor : Logs (debug seulement) ─────────
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  // ── Méthodes HTTP ──────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> postMultipart(
    String path, {
    required FormData data,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Gestion d'erreurs centralisée ──────────────────

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Connexion au serveur impossible. Vérifiez votre internet.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(e.response!);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Requête annulée');

      default:
        return const ServerException(message: 'Erreur inattendue');
    }
  }

  /// Parse les réponses d'erreur selon la structure Laravel
  /// Toutes les réponses suivent : { "success": false, "message": "..." }
  Exception _handleResponseError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;
    final message = _extractMessage(data);

    switch (statusCode) {
      // ── 401 Unauthorized ─────────────────────────────
      // "Token is missing or malformed."
      // "Token has expired."
      // "Token is invalid."
      // "Invalid email or password."
      case 401:
        return AuthException(message);

      // ── 403 Forbidden ────────────────────────────────
      // "Your account is deactivated. Please contact the administrator."
      // "Your email address is not verified. Please check your inbox."
      // "Forbidden. You do not have permission to access this resource."
      case 403:
        String? action;
        if (data is Map && data['errors'] is Map) {
          action = (data['errors'] as Map)['action']?.toString();
        }
        return ForbiddenException(message, action);

      // ── 404 Not Found ────────────────────────────────
      case 404:
        return NotFoundException(message);

      // ── 422 Unprocessable ────────────────────────────
      // Cas 1: Validation classique → { "errors": { "email": ["..."] } }
      // Cas 2: Protected fields → { "fields": ["role"] }
      // Cas 3: Business rule → { "message": "The reset token is invalid..." }
      case 422:
        final errors = <String, List<String>>{};
        List<String>? protectedFields;

        if (data is Map) {
          // Erreurs de validation Laravel
          if (data['errors'] is Map) {
            (data['errors'] as Map).forEach((key, value) {
              errors[key.toString()] =
                  (value as List).map((e) => e.toString()).toList();
            });
          }
          // Champs protégés (ForbiddenFieldsMiddleware)
          if (data['fields'] is List) {
            protectedFields =
                (data['fields'] as List).map((e) => e.toString()).toList();
          }
        }

        return ValidationException(
          message: message,
          errors: errors,
          protectedFields: protectedFields,
        );

      // ── 429 Too Many Requests ────────────────────────
      // { "retry_after": 45 }
      case 429:
        int retryAfter = 60;
        if (data is Map && data['retry_after'] != null) {
          retryAfter = int.tryParse(data['retry_after'].toString()) ?? 60;
        }
        return RateLimitException(
          message: message,
          retryAfter: retryAfter,
        );

      // ── 500+ Server Error ────────────────────────────
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// Extrait le message de la réponse Laravel
  /// Structure : { "success": false, "message": "..." }
  String _extractMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Erreur inconnue';
  }
}