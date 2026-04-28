import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resendOtp({
    required String email,
    String type,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> hasToken();

  Future<Either<Failure, String>> refreshToken();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> verifyResetOtp({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, User>> loginWithGoogle({required String idToken});
}
