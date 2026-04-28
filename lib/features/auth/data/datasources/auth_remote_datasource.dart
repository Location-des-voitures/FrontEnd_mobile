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
  // LOGIN — POST /api/auth/login
  // ═══════════════════════════════════════════════════════
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data['data'];
    await _storeToken(data['token'] as String);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _cacheUser(user);
    return user;
  }

  // ═══════════════════════════════════════════════════════
  // REGISTER — POST /api/auth/register
  // Retourne le user sans token (email pas encore vérifié)
  // ═══════════════════════════════════════════════════════
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

    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════════════════
  // VERIFY OTP — POST /api/auth/verify-otp
  // ═══════════════════════════════════════════════════════
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    await _client.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'code': code},
    );
  }

  // ═══════════════════════════════════════════════════════
  // RESEND OTP — POST /api/auth/resend-otp
  // type: 'register' | 'reset_password'
  // ═══════════════════════════════════════════════════════
  Future<void> resendOtp({
    required String email,
    String type = 'register',
  }) async {
    await _client.post(
      ApiConstants.resendOtp,
      data: {'email': email, 'type': type},
    );
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT — POST /api/auth/logout
  // ═══════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } finally {
      await _clearStorage();
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET CURRENT USER — GET /api/auth/me
  // ═══════════════════════════════════════════════════════
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get(ApiConstants.me);
    final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    await _cacheUser(user);
    return user;
  }

  // ═══════════════════════════════════════════════════════
  // REFRESH TOKEN — POST /api/auth/refresh
  // ═══════════════════════════════════════════════════════
  Future<String> refreshToken() async {
    final response = await _client.post(ApiConstants.refreshToken);
    final token = response.data['data']['token'] as String;
    await _storeToken(token);
    return token;
  }

  // ═══════════════════════════════════════════════════════
  // FORGOT PASSWORD — POST /api/auth/forgot-password
  // ═══════════════════════════════════════════════════════
  Future<void> forgotPassword({required String email}) async {
    await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  // ═══════════════════════════════════════════════════════
  // VERIFY RESET OTP — POST /api/auth/verify-reset-otp
  // ═══════════════════════════════════════════════════════
  Future<void> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    await _client.post(
      ApiConstants.verifyResetOtp,
      data: {'email': email, 'code': code},
    );
  }

  // ═══════════════════════════════════════════════════════
  // RESET PASSWORD — POST /api/auth/reset-password
  // ═══════════════════════════════════════════════════════
  Future<void> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _client.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // ═══════════════════════════════════════════════════════
  // GOOGLE MOBILE — POST /api/auth/google/mobile
  // ═══════════════════════════════════════════════════════
  Future<UserModel> loginWithGoogle({required String idToken}) async {
    final response = await _client.post(
      ApiConstants.googleMobile,
      data: {'id_token': idToken},
    );

    final data = response.data['data'];
    await _storeToken(data['token'] as String);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _cacheUser(user);
    return user;
  }

  // ═══════════════════════════════════════════════════════
  // LOCAL HELPERS
  // ═══════════════════════════════════════════════════════

  Future<bool> hasToken() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getCachedUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(
  jsonDecode(userJson) as Map<String, dynamic>,
);
    } catch (_) {
      await _storage.delete(key: AppConstants.userKey);
      return null;
    }
  }

  Future<void> _storeToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<void> _cacheUser(UserModel user) =>
      _storage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));

  Future<void> _clearStorage() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }
}
