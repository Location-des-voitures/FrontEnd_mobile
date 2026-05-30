/// -------------------------------------------------------
/// CAR REPOSITORY IMPL — Client Space
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/price_quote.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/car_remote_datasource.dart';

class CarRepositoryImpl implements CarRepository {
  final CarRemoteDatasource _datasource;
  const CarRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedCars>> getCars({
    CarFilters? filters,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (filters != null) {
        if (filters.brand != null)    params['brand']     = filters.brand;
        if (filters.minPrice != null) params['min_price'] = filters.minPrice;
        if (filters.maxPrice != null) params['max_price'] = filters.maxPrice;
        if (filters.fuelType != null)
          params['fuel_type'] = filters.fuelType!.name;
        if (filters.transmission != null)
          params['transmission'] = filters.transmission!.name;
        if (filters.startDate != null) params['start_date'] = filters.startDate;
        if (filters.endDate != null)   params['end_date']   = filters.endDate;
        if (filters.perPage != null)   params['per_page']   = filters.perPage;
        if (filters.page != null)      params['page']       = filters.page;
      }
      final result = await _datasource.getCars(
          params: params.isNotEmpty ? params : null);
      return Right(result.toDomain());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
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
      return Right(await _datasource.getCarById(id));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AvailabilityResult>> checkAvailability({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final result = await _datasource.checkAvailability(
        carId: carId, startDate: startDate, endDate: endDate,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PriceQuote>> calculatePrice({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final result = await _datasource.calculatePrice(
        carId: carId, startDate: startDate, endDate: endDate,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}