/// -------------------------------------------------------
/// CAR REPOSITORY — Client Space (abstract)
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/car.dart';
import '../entities/price_quote.dart';

abstract class CarRepository {
  /// GET /api/client/cars
  Future<Either<Failure, PaginatedCars>> getCars({CarFilters? filters});

  /// GET /api/client/cars/{id}
  Future<Either<Failure, Car>> getCarById(int id);

  /// POST /api/client/cars/check-availability
  Future<Either<Failure, AvailabilityResult>> checkAvailability({
    required int carId,
    required String startDate,
    required String endDate,
  });

  /// POST /api/client/cars/calculate-price
  Future<Either<Failure, PriceQuote>> calculatePrice({
    required int carId,
    required String startDate,
    required String endDate,
  });
}