import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart'
    as domain;
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import '../network/dio_client.dart';

// ══════════════════════════════════════════════════════════
// 🧪 MODE MOCK
// Mettez kUseMock = false quand votre backend Laravel est prêt.
//
// Comptes de test :
//   super_admin → admin@test.com   / password
//   loueur      → loueur@test.com  / password
//   client      → client@test.com  / password
// ══════════════════════════════════════════════════════════
const bool kUseMock = true;

const _mockUsers = {
  'admin@test.com': User(
    id: 1,
    name: 'Super Admin',
    email: 'admin@test.com',
    role: 'super_admin',
    isActive: true,
    emailVerifiedAt: '2026-01-01T00:00:00Z',
  ),
  'loueur@test.com': User(
    id: 2,
    name: 'Ahmed Loueur',
    email: 'loueur@test.com',
    role: 'admin',
    isActive: true,
    emailVerifiedAt: '2026-01-01T00:00:00Z',
  ),
  'client@test.com': User(
    id: 3,
    name: 'Youssef Client',
    email: 'client@test.com',
    role: 'client',
    isActive: true,
    emailVerifiedAt: '2026-01-01T00:00:00Z',
  ),
};

/// Appelé directement par LoginScreen quand kUseMock = true.
/// Retourne le User si ok, null si mauvais identifiants.
Future<User?> mockLogin(String email, String password) async {
  await Future.delayed(const Duration(milliseconds: 400));
  final user = _mockUsers[email.trim().toLowerCase()];
  if (user == null || password != 'password') return null;
  return user;
}

// ══════════════════════════════════════════════════════════
// AUTH STATE
// ══════════════════════════════════════════════════════════
class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = 'client';
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  User? get user => _user;

  void login(User user) {
    _isLoggedIn = true;
    _role = user.role;
    _user = user;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _role = 'client';
    _user = null;
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();

// ══════════════════════════════════════════════════════════
// INFRASTRUCTURE PROVIDERS
// ══════════════════════════════════════════════════════════
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(storage: ref.read(secureStorageProvider));
});

// ══════════════════════════════════════════════════════════
// DATA LAYER PROVIDERS
// ══════════════════════════════════════════════════════════
final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(client: ref.read(dioClientProvider));
});

final authRepositoryProvider = Provider<domain.AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDatasourceProvider));
});

// ══════════════════════════════════════════════════════════
// USE CASE PROVIDERS
// ══════════════════════════════════════════════════════════
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.read(authRepositoryProvider));
});

final verifyOtpUsecaseProvider = Provider<VerifyOtpUsecase>((ref) {
  return VerifyOtpUsecase(ref.read(authRepositoryProvider));
});

final resendOtpUsecaseProvider = Provider<ResendOtpUsecase>((ref) {
  return ResendOtpUsecase(ref.read(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.read(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.read(authRepositoryProvider));
});

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  return ForgotPasswordUsecase(ref.read(authRepositoryProvider));
});

final verifyResetOtpUsecaseProvider = Provider<VerifyResetOtpUsecase>((ref) {
  return VerifyResetOtpUsecase(ref.read(authRepositoryProvider));
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(ref.read(authRepositoryProvider));
});

final refreshTokenUsecaseProvider = Provider<RefreshTokenUsecase>((ref) {
  return RefreshTokenUsecase(ref.read(authRepositoryProvider));
});

final loginWithGoogleUsecaseProvider = Provider<LoginWithGoogleUsecase>((ref) {
  return LoginWithGoogleUsecase(ref.read(authRepositoryProvider));
});

final authNotifierProvider = Provider<AuthNotifier>((ref) => authNotifier);