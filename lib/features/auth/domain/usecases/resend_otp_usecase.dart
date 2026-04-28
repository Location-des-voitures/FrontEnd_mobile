import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUsecase {
  final AuthRepository repository;

  const ResendOtpUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    String type = 'register',
  }) {
    return repository.resendOtp(email: email, type: type);
  }
}
