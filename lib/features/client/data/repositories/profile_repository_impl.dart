/// -------------------------------------------------------
/// PROFILE REPOSITORY IMPL — Client Space
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;
  const ProfileRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, ClientProfile>> getProfile() async {
    try {
      return Right(await _datasource.getProfile());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> updateProfile(
      UpdateProfileRequest request) async {
    try {
      return Right(await _datasource.updateProfile(request));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      ChangePasswordRequest request) async {
    try {
      await _datasource.changePassword(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}