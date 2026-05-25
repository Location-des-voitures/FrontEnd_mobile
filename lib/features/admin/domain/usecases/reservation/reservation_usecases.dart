/// -------------------------------------------------------
/// RESERVATION USECASES — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../entities/reservation.dart';
import '../../repositories/reservation_repository.dart';

class GetReservationsUsecase {
  final ReservationRepository repository;
  const GetReservationsUsecase(this.repository);

  Future<Either<Failure, PaginatedReservations>> call(
          {ReservationFilters? filters}) =>
      repository.getReservations(filters: filters);
}

class GetReservationByIdUsecase {
  final ReservationRepository repository;
  const GetReservationByIdUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int id) =>
      repository.getReservationById(id);
}

class ApproveReservationUsecase {
  final ReservationRepository repository;
  const ApproveReservationUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int id) =>
      repository.approveReservation(id);
}

class RejectReservationUsecase {
  final ReservationRepository repository;
  const RejectReservationUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int id, {String? reason}) =>
      repository.rejectReservation(id, reason: reason);
}

class VerifyPaymentUsecase {
  final ReservationRepository repository;
  const VerifyPaymentUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int paymentId) =>
      repository.verifyPayment(paymentId);
}
