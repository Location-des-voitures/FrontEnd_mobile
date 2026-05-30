/// -------------------------------------------------------
/// CAR USECASES — Client Space
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/car.dart';
import '../entities/price_quote.dart';
import '../repositories/car_repository.dart';

// ── Get Cars ─────────────────────────────────────────────
class GetCarsUsecase {
  final CarRepository repository;
  const GetCarsUsecase(this.repository);

  Future<Either<Failure, PaginatedCars>> call({CarFilters? filters}) =>
      repository.getCars(filters: filters);
}

// ── Get Car By Id ─────────────────────────────────────────
class GetCarByIdUsecase {
  final CarRepository repository;
  const GetCarByIdUsecase(this.repository);

  Future<Either<Failure, Car>> call(int id) =>
      repository.getCarById(id);
}

// ── Check Availability ────────────────────────────────────
class CheckAvailabilityUsecase {
  final CarRepository repository;
  const CheckAvailabilityUsecase(this.repository);

  Future<Either<Failure, AvailabilityResult>> call({
    required int carId,
    required String startDate,
    required String endDate,
  }) =>
      repository.checkAvailability(
        carId: carId,
        startDate: startDate,
        endDate: endDate,
      );
}

// ── Calculate Price ───────────────────────────────────────
class CalculatePriceUsecase {
  final CarRepository repository;
  const CalculatePriceUsecase(this.repository);

  Future<Either<Failure, PriceQuote>> call({
    required int carId,
    required String startDate,
    required String endDate,
  }) =>
      repository.calculatePrice(
        carId: carId,
        startDate: startDate,
        endDate: endDate,
      );
}