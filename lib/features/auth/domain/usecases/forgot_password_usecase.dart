import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repository;

  const ForgotPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
