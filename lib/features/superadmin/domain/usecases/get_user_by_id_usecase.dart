/// GET USER BY ID USECASE
/// Récupère le détail d'un utilisateur.
/// Utilisé dans l'écran détail du Super Admin.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_management_repository.dart';

class GetUserByIdUsecase {
  final UserManagementRepository repository;

  const GetUserByIdUsecase(this.repository);

  Future<Either<Failure, User>> call(int id) {
    return repository.getUserById(id);
  }
}