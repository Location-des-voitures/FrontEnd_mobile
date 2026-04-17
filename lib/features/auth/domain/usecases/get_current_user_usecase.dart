/// -------------------------------------------------------
/// GET CURRENT USER USECASE
/// -------------------------------------------------------
/// Récupère l'utilisateur connecté via le token stocké.
/// Utilisé au démarrage de l'app pour savoir si on
/// redirige vers login ou vers home.
/// -------------------------------------------------------

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  const GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}