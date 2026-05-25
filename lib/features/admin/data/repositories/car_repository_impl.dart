/// -------------------------------------------------------
/// CAR REPOSITORY IMPL — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/car_remote_datasource.dart';

class CarRepositoryImpl implements CarRepository {
  final CarRemoteDatasource _datasource;
  const CarRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedCars>> getCars({CarFilters? filters}) async {
    try {
      final params = <String, dynamic>{};
      if (filters != null) {
        if (filters.search?.isNotEmpty == true) params['search'] = filters.search;
        if (filters.status != null) {
          params['status'] = switch (filters.status!) {
            CarStatus.available => 'available',
            CarStatus.rented => 'rented',
            CarStatus.maintenance => 'maintenance',
          };
        }
        if (filters.brand != null) params['brand'] = filters.brand;
        if (filters.isActive != null) params['is_active'] = filters.isActive.toString();
        if (filters.perPage != null) params['per_page'] = filters.perPage;
        if (filters.page != null) params['page'] = filters.page;
      }
      final result = await _datasource.getCars(params: params.isNotEmpty ? params : null);
      return Right(result.toDomain());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Car>> getCarById(int id) async {
    try {
      final car = await _datasource.getCarById(id);
      return Right(car);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Car>> createCar(Map<String, dynamic> data) async {
    try {
      final car = await _datasource.createCar(data);
      return Right(car);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Car>> updateCar(int id, Map<String, dynamic> data) async {
    try {
      final car = await _datasource.updateCar(id, data);
      return Right(car);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(int id) async {
    try {
      await _datasource.deleteCar(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Car>> updateCarStatus(int id, CarStatus status) async {
    try {
      final car = await _datasource.updateCarStatus(id, status);
      return Right(car);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}