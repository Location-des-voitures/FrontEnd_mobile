/// UPDATE CAR USECASE
library;
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/car.dart';
import '../../repositories/car_repository.dart';

class UpdateCarUsecase {
  final CarRepository repository;
  const UpdateCarUsecase(this.repository);
  Future<Either<Failure, Car>> call(int id, Map<String, dynamic> data) =>
      repository.updateCar(id, data);
}