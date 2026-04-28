/// CREATE ADMIN USECASE
/// Crée un nouveau compte admin (loueur).
/// Deux stratégies :
///   - 'password_reset' → l'admin reçoit un lien pour créer son mdp
///   - 'credentials'    → on lui envoie un mdp temporaire
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/user_management_repository.dart';

class CreateAdminUsecase {
  final UserManagementRepository repository;

  const CreateAdminUsecase(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String notifyVia,
    String? password,
    String? passwordConfirmation,
  }) {
    return repository.createAdmin(
      name: name,
      email: email,
      notifyVia: notifyVia,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}