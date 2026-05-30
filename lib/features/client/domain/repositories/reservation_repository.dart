/// -------------------------------------------------------
/// RESERVATION REPOSITORY — Client Space (abstract)
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation.dart';

abstract class ReservationRepository {
  /// POST /api/client/reservations (multipart/form-data)
  Future<Either<Failure, Reservation>> createReservation(
      CreateReservationRequest request);

  /// GET /api/client/reservations (pending, approved, confirmed)
  Future<Either<Failure, PaginatedReservations>> getReservations({
    String? status,
    int? perPage,
    int? page,
  });

  /// GET /api/client/reservations/history (cancelled, completed, rejected)
  Future<Either<Failure, PaginatedReservations>> getHistory({
    String? status,
    String? from, // Y-m-d
    String? to,   // Y-m-d
    int? perPage,
    int? page,
  });

  /// GET /api/client/reservations/{id}
  Future<Either<Failure, Reservation>> getReservationById(int id);

  /// POST /api/client/reservations/{id}/cancel
  Future<Either<Failure, Reservation>> cancelReservation(int id);

  /// GET /api/client/contracts/{reservationId}/download → bytes
  Future<Either<Failure, List<int>>> downloadContract(int reservationId);

  /// GET /api/client/documents/{documentId}/download → bytes
  Future<Either<Failure, List<int>>> downloadDocument(int documentId);
}