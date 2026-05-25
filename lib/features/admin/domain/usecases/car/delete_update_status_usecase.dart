/// DELETE CAR USECASE
library;
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../repositories/car_repository.dart';
import '../../entities/car.dart';

class DeleteCarUsecase {
  final CarRepository repository;
  const DeleteCarUsecase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteCar(id);
}

/// UPDATE CAR STATUS USECASE
class UpdateCarStatusUsecase {
  final CarRepository repository;
  const UpdateCarStatusUsecase(this.repository);
  Future<Either<Failure, dynamic>> call(int id, CarStatus status) =>
      repository.updateCarStatus(id, status);
}