/// -------------------------------------------------------
/// USER MANAGEMENT REPOSITORY IMPLEMENTATION
/// -------------------------------------------------------
/// Implémente le contrat UserManagementRepository.
///
/// Même pattern que AuthRepositoryImpl :
///   try { datasource.method() } → Right(résultat)
///   catch XxxException → Left(XxxFailure)
///
/// Cas d'erreurs spécifiques au Super Admin :
///   - 403 : "Forbidden" → l'utilisateur n'est pas super_admin
///   - 422 : "You cannot deactivate your own account"
///   - 404 : User not found
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_remote_datasource.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDatasource _datasource;

  const UserManagementRepositoryImpl(this._datasource);

  // ═══════════════════════════════════════════════════════
  // GET ALL USERS
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, PaginatedUsers>> getAllUsers({
    UserFilters? filters,
  }) async {
    try {
      final result = await _datasource.getAllUsers(filters: filters);
      // Convertir le Model en Domain avec toDomain()
      return Right(result.toDomain());
    } on AuthException catch (e) {
      // 401 — Token expiré ou invalide
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      // 403 — Pas le rôle super_admin
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET USER BY ID
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      final user = await _datasource.getUserById(id);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      // 404 — User introuvable
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // CREATE ADMIN
  // ═══════════════════════════════════════════════════════
  

  // ═══════════════════════════════════════════════════════
  // ACTIVATE USER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> activateUser(int id) async {
    try {
      final user = await _datasource.activateUser(id);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // DEACTIVATE USER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> deactivateUser(int id) async {
    try {
      final user = await _datasource.deactivateUser(id);
      return Right(user);
    } on ValidationException catch (e) {
      // 422 — "You cannot deactivate your own account"
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // DELETE USER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await _datasource.deleteUser(id);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, User>> createAdmin({required String name, required String email, required String password, required String passwordConfirmation, String? notifyVia}) {
    // TODO: implement createAdmin
    throw UnimplementedError();
  }
}