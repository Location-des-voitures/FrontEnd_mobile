import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository repository;

  const VerifyOtpUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) {
    return repository.verifyOtp(email: email, code: code);
  }
}
