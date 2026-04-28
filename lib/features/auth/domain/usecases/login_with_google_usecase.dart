import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUsecase {
  final AuthRepository repository;

  const LoginWithGoogleUsecase(this.repository);

  Future<Either<Failure, User>> call({required String idToken}) {
    return repository.loginWithGoogle(idToken: idToken);
  }
}
