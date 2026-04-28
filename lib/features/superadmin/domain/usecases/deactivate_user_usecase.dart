/// DEACTIVATE USER USECASE
/// Désactive un compte utilisateur.
/// L'utilisateur ne pourra plus se connecter.
/// Note : impossible de désactiver son propre compte (422).
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_management_repository.dart';

class DeactivateUserUsecase {
  final UserManagementRepository repository;

  const DeactivateUserUsecase(this.repository);

  Future<Either<Failure, User>> call(int id) {
    return repository.deactivateUser(id);
  }
}