/// -------------------------------------------------------
/// AUTH REPOSITORY IMPLEMENTATION
/// -------------------------------------------------------
/// Implémente le contrat AuthRepository du Domain.
///
/// Son unique job :
///   1. Appeler le datasource
///   2. Si succès → retourner Right(user)
///   3. Si exception → convertir en Left(Failure)
///
/// C'est le SEUL endroit où les Exceptions deviennent
/// des Failures. Le Domain ne voit jamais d'exceptions.
///
/// Flow :
///   Provider → Usecase → Repository (ici)
///     → try { datasource.login() }
///       → Right(user)          ← succès
///     → catch AuthException
///       → Left(AuthFailure)    ← erreur typée
///     → catch NetworkException
///       → Left(NetworkFailure) ← pas de réseau
/// -------------------------------------------------------

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  // ═══════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _datasource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      // 401 — Mauvais identifiants
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      // 403 — Compte désactivé ou email non vérifié
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      // 422 — Erreurs de validation
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors,
      ));
    } on RateLimitException catch (e) {
      // 429 — Trop de tentatives
      return Left(ServerFailure(
        '${e.message} Réessayez dans ${e.retryAfter} secondes.',
      ));
    } on NetworkException catch (e) {
      // Pas de connexion internet
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // 500+ — Erreur serveur
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Erreur inattendue
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final user = await _datasource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return Right(user);
    } on ValidationException catch (e) {
      // 422 — Email déjà utilisé, mot de passe trop court, etc.
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors,
      ));
    } on RateLimitException catch (e) {
      // 429 — Trop de tentatives d'inscription
      return Left(ServerFailure(
        '${e.message} Réessayez dans ${e.retryAfter} secondes.',
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      // Même si le logout API échoue, le datasource
      // nettoie toujours le storage local (dans le finally).
      // Donc on retourne succès quand même.
      return const Right(null);
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET CURRENT USER
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _datasource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      // 401 — Token expiré ou invalide
      return Left(AuthFailure(e.message));
    } on NetworkException catch (_) {
      // Pas de réseau → essayer le cache local
      final cachedUser = await _datasource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  // ═══════════════════════════════════════════════════════
  // HAS TOKEN
  // ═══════════════════════════════════════════════════════
  @override
  Future<bool> hasToken() {
    return _datasource.hasToken();
  }
}