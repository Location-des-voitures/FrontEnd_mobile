/// DELETE USER USECASE
/// Supprime définitivement un utilisateur.
/// Action irréversible — nécessite confirmation dans l'UI.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_management_repository.dart';

class DeleteUserUsecase {
  final UserManagementRepository repository;

  const DeleteUserUsecase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteUser(id);
  }
}