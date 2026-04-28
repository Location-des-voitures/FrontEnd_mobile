import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyResetOtpUsecase {
  final AuthRepository repository;

  const VerifyResetOtpUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) {
    return repository.verifyResetOtp(email: email, code: code);
  }
}
