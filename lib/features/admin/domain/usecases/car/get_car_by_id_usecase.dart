/// GET CAR BY ID USECASE
library;
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/car_repository.dart';
import '../../entities/car.dart';

class GetCarByIdUsecase {
  final CarRepository repository;
  const GetCarByIdUsecase(this.repository);

  Future<Either<Failure, Car>> call(int id) {
    return repository.getCarById(id);
  }
}