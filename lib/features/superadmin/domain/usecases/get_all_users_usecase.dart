/// GET ALL USERS USECASE
/// Liste tous les utilisateurs avec filtres optionnels.
/// Utilisé dans l'écran principal du Super Admin.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_management_repository.dart';

class GetAllUsersUsecase {
  final UserManagementRepository repository;

  const GetAllUsersUsecase(this.repository);

  Future<Either<Failure, PaginatedUsers>> call({
    UserFilters? filters,
  }) {
    return repository.getAllUsers(filters: filters);
  }
}