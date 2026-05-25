/// GET CARS USECASE
library;
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/car_repository.dart';

class GetCarsUsecase {
  final CarRepository repository;
  const GetCarsUsecase(this.repository);

  Future<Either<Failure, PaginatedCars>> call({CarFilters? filters}) {
    return repository.getCars(filters: filters);
  }
}