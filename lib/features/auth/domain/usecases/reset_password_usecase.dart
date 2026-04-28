import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;

  const ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.resetPassword(
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
