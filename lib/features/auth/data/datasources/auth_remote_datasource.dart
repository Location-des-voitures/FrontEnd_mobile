/// -------------------------------------------------------
/// AUTH REMOTE DATASOURCE
/// -------------------------------------------------------
/// Fait les vrais appels HTTP à ton API Laravel.
/// Chaque méthode correspond à un endpoint :
///
///   login()          → POST /api/auth/login
///   register()       → POST /api/auth/register
///   logout()         → POST /api/auth/logout
///   getCurrentUser() → GET  /api/auth/me
///
/// Gestion du token JWT :
///   - login()  → stocke le token dans FlutterSecureStorage
///   - logout() → supprime le token
///   - Le DioClient ajoute automatiquement le token
///     dans le header Authorization de chaque requête
///
/// Les exceptions (AuthException, ValidationException...)
/// sont lancées par DioClient._handleError()
/// et remontent vers le Repository qui les convertit
/// en Failures.
/// -------------------------------------------------------

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRemoteDatasource({
    required DioClient client,
    FlutterSecureStorage? storage,
  })  : _client = client,
        _storage = storage ?? const FlutterSecureStorage();

  // ═══════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════
  /// POST /api/auth/login
  ///
  /// Réponse attendue :
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "user": { ... },
  ///     "token": "eyJ0eXAi...",
  ///     "token_type": "bearer",
  ///     "expires_in": 3600
  ///   }
  /// }
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data['data'];

    // ── Stocker le token JWT ─────────────────────────
    await _storage.write(
      key: AppConstants.tokenKey,
      value: data['token'] as String,
    );

    // ── Stocker le user localement (pour accès offline) ─
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(data['user']),
    );

    // ── Parser et retourner le UserModel ─────────────
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════
  /// POST /api/auth/register
  ///
  /// Note importante : l'API ne retourne PAS de token
  /// au register. L'utilisateur doit vérifier son email
  /// avant de pouvoir se connecter.
  ///
  /// Réponse attendue :
  /// {
  ///   "success": true,
  ///   "message": "Registration successful. Please check your email...",
  ///   "data": { "id": 5, "name": "...", ... }
  /// }
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = response.data['data'];

    // Pas de token à stocker ici — l'user doit vérifier son email
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════
  /// POST /api/auth/logout
  ///
  /// Invalide le token côté serveur et supprime
  /// le token + les données user localement.
  Future<void> logout() async {
    try {
      // Appeler l'API pour invalider le token côté serveur
      await _client.post(ApiConstants.logout);
    } finally {
      // Toujours nettoyer le stockage local,
      // même si l'appel API échoue (ex: token déjà expiré)
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.userKey);
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET CURRENT USER
  // ═══════════════════════════════════════════════════════
  /// GET /api/auth/me
  ///
  /// Récupère l'utilisateur connecté via le token JWT.
  /// Utilisé au démarrage de l'app pour vérifier que
  /// le token est encore valide.
  ///
  /// Réponse attendue :
  /// {
  ///   "success": true,
  ///   "data": { "id": 5, "name": "...", ... }
  /// }
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get(ApiConstants.me);

    final data = response.data['data'];
    final user = UserModel.fromJson(data as Map<String, dynamic>);

    // Mettre à jour le cache local avec les données fraîches
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );

    return user;
  }

  // ═══════════════════════════════════════════════════════
  // HAS TOKEN (vérification locale)
  // ═══════════════════════════════════════════════════════
  /// Vérifie si un token JWT est stocké localement.
  /// Ne fait AUCUN appel réseau.
  /// Utilisé par le router pour décider : login ou home ?
  Future<bool> hasToken() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════
  // GET CACHED USER (lecture locale)
  // ═══════════════════════════════════════════════════════
  /// Lit le user depuis le cache local (sans appel réseau).
  /// Retourne null si rien n'est stocké.
  Future<UserModel?> getCachedUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      // JSON corrompu → supprimer le cache
      await _storage.delete(key: AppConstants.userKey);
      return null;
    }
  }
}