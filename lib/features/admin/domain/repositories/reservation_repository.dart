/// -------------------------------------------------------
/// RESERVATION REPOSITORY — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reservation.dart';

class PaginatedReservations {
  final List<Reservation> reservations;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedReservations({
    required this.reservations,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;
}

class ReservationFilters {
  final String? search;
  final ReservationStatus? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? carId;
  final int? clientId;
  final int? perPage;
  final int? page;

  const ReservationFilters({
    this.search,
    this.status,
    this.fromDate,
    this.toDate,
    this.carId,
    this.clientId,
    this.perPage,
    this.page,
  });
}

abstract class ReservationRepository {
  Future<Either<Failure, PaginatedReservations>> getReservations(
      {ReservationFilters? filters});
  Future<Either<Failure, Reservation>> getReservationById(int id);
  Future<Either<Failure, Reservation>> approveReservation(int id);
  Future<Either<Failure, Reservation>> rejectReservation(int id,
      {String? reason});
  Future<Either<Failure, Reservation>> verifyPayment(int paymentId);
  Future<Either<Failure, Reservation>> cancelReservation(int id);
}
