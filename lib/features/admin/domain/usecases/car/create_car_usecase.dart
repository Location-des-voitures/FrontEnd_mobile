/// CREATE CAR USECASE
library;
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/car.dart';
import '../../repositories/car_repository.dart';

class CreateCarUsecase {
  final CarRepository repository;
  const CreateCarUsecase(this.repository);
  Future<Either<Failure, Car>> call(Map<String, dynamic> data) =>
      repository.createCar(data);
}