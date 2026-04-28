import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUsecase {
  final AuthRepository repository;

  const RefreshTokenUsecase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.refreshToken();
  }
}
