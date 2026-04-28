/// ACTIVATE USER USECASE
/// Active un compte désactivé.
/// L'utilisateur pourra se reconnecter.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_management_repository.dart';

class ActivateUserUsecase {
  final UserManagementRepository repository;

  const ActivateUserUsecase(this.repository);

  Future<Either<Failure, User>> call(int id) {
    return repository.activateUser(id);
  }
}