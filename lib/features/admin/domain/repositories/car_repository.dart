/// -------------------------------------------------------
/// CAR REPOSITORY — FlotTrack Admin
/// -------------------------------------------------------
/// GET    /admin/cars                → getCars
/// GET    /admin/cars/{id}           → getCarById
/// POST   /admin/cars                → createCar
/// PUT    /admin/cars/{id}           → updateCar
/// DELETE /admin/cars/{id}           → deleteCar
/// PUT    /admin/cars/{id}/status    → updateCarStatus
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/car.dart';

class PaginatedCars {
  final List<Car> cars;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedCars({
    required this.cars,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;
}

class CarFilters {
  final String? search;
  final CarStatus? status;
  final String? brand;
  final bool? isActive;
  final int? perPage;
  final int? page;

  const CarFilters({
    this.search,
    this.status,
    this.brand,
    this.isActive,
    this.perPage,
    this.page,
  });
}

abstract class CarRepository {
  Future<Either<Failure, PaginatedCars>> getCars({CarFilters? filters});
  Future<Either<Failure, Car>> getCarById(int id);
  Future<Either<Failure, Car>> createCar(Map<String, dynamic> data);
  Future<Either<Failure, Car>> updateCar(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteCar(int id);
  Future<Either<Failure, Car>> updateCarStatus(int id, CarStatus status);
}