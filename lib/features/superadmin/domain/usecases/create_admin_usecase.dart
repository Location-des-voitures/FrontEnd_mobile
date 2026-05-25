/// CREATE ADMIN USECASE
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
    // ✅ Plus de null-assertion — on délègue la validation au repository
    return repository.createAdmin(
      name: name,
      email: email,
      notifyVia: notifyVia,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}