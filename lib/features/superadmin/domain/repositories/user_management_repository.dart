/// -------------------------------------------------------
/// USER MANAGEMENT REPOSITORY — FlotTrack API
/// -------------------------------------------------------
/// GET    /api/admin/users              → getAllUsers
/// GET    /api/admin/users/{id}         → getUserById
/// PUT    /api/admin/users/{id}/activate   → activateUser
/// PUT    /api/admin/users/{id}/deactivate → deactivateUser
/// DELETE /api/admin/users/{id}         → deleteUser
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';

/// Résultat paginé
class PaginatedUsers {
  final List<User> users;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedUsers({
    required this.users,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;
}

/// Filtres — alignés sur les query params de l'API
class UserFilters {
  final String? search;         // Recherche dans name + email
  final String? role;           // 'super_admin', 'admin', 'client'
  final bool? isActive;
  final bool? emailVerified;    // NOUVEAU — filtre par email vérifié
  final int? perPage;
  final int? page;

  const UserFilters({
    this.search,
    this.role,
    this.isActive,
    this.emailVerified,
    this.perPage,
    this.page,
  });
}

abstract class UserManagementRepository {
  Future<Either<Failure, PaginatedUsers>> getAllUsers({UserFilters? filters});
  Future<Either<Failure, User>> getUserById(int id);
  Future<Either<Failure, User>> activateUser(int id);
  Future<Either<Failure, User>> deactivateUser(int id);
  Future<Either<Failure, void>> deleteUser(int id);
}