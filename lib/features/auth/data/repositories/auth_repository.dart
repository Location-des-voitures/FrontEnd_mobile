import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  // ═══════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _datasource.login(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      // 403: email non vérifié (OTP renvoyé auto) ou compte désactivé
      return Left(ForbiddenFailure(e.message, e.action));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final user = await _datasource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // VERIFY OTP
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      await _datasource.verifyOtp(email: email, code: code);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // RESEND OTP
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> resendOtp({
    required String email,
    String type = 'register',
  }) async {
    try {
      await _datasource.resendOtp(email: email, type: type);
      return const Right(null);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      return const Right(null);
    } catch (_) {
      // Le datasource nettoie toujours le storage local dans finally.
      return const Right(null);
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET CURRENT USER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _datasource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (_) {
      final cached = await _datasource.getCachedUser();
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // HAS TOKEN
  // ═══════════════════════════════════════════════════════
  @override
  Future<bool> hasToken() => _datasource.hasToken();

  // ═══════════════════════════════════════════════════════
  // REFRESH TOKEN
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final token = await _datasource.refreshToken();
      return Right(token);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _datasource.forgotPassword(email: email);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // VERIFY RESET OTP
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    try {
      await _datasource.verifyResetOtp(email: email, code: code);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfter: e.retryAfter,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // RESET PASSWORD
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _datasource.resetPassword(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ForbiddenException catch (e) {
      // OTP non vérifié ou fenêtre de 10 min expirée
      return Left(ForbiddenFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // LOGIN WITH GOOGLE
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> loginWithGoogle({required String idToken}) async {
    try {
      final user = await _datasource.loginWithGoogle(idToken: idToken);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
