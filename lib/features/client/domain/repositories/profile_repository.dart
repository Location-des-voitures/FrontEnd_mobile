/// -------------------------------------------------------
/// PROFILE REPOSITORY — Client Space (abstract)
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/client_profile.dart';

abstract class ProfileRepository {
  /// GET /api/client/profile
  Future<Either<Failure, ClientProfile>> getProfile();

  /// PUT /api/client/profile
  Future<Either<Failure, ClientProfile>> updateProfile(
      UpdateProfileRequest request);

  /// PUT /api/client/profile/password
  Future<Either<Failure, void>> changePassword(
      ChangePasswordRequest request);
}