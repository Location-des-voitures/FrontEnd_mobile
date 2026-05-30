/// -------------------------------------------------------
/// PROFILE USECASES — Client Space
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/client_profile.dart';
import '../repositories/profile_repository.dart';

// ── Get Profile ───────────────────────────────────────────
class GetProfileUsecase {
  final ProfileRepository repository;
  const GetProfileUsecase(this.repository);

  Future<Either<Failure, ClientProfile>> call() =>
      repository.getProfile();
}

// ── Update Profile ────────────────────────────────────────
class UpdateProfileUsecase {
  final ProfileRepository repository;
  const UpdateProfileUsecase(this.repository);

  Future<Either<Failure, ClientProfile>> call(
          UpdateProfileRequest request) =>
      repository.updateProfile(request);
}

// ── Change Password ───────────────────────────────────────
class ChangePasswordUsecase {
  final ProfileRepository repository;
  const ChangePasswordUsecase(this.repository);

  Future<Either<Failure, void>> call(ChangePasswordRequest request) =>
      repository.changePassword(request);
}