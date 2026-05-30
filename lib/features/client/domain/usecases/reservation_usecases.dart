/// -------------------------------------------------------
/// RESERVATION USECASES — Client Space
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

// ── Create Reservation ────────────────────────────────────
class CreateReservationUsecase {
  final ReservationRepository repository;
  const CreateReservationUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(
          CreateReservationRequest request) =>
      repository.createReservation(request);
}

// ── Get Active Reservations ───────────────────────────────
class GetReservationsUsecase {
  final ReservationRepository repository;
  const GetReservationsUsecase(this.repository);

  Future<Either<Failure, PaginatedReservations>> call({
    String? status,
    int? perPage,
    int? page,
  }) =>
      repository.getReservations(
        status: status,
        perPage: perPage,
        page: page,
      );
}

// ── Get History ───────────────────────────────────────────
class GetHistoryUsecase {
  final ReservationRepository repository;
  const GetHistoryUsecase(this.repository);

  Future<Either<Failure, PaginatedReservations>> call({
    String? status,
    String? from,
    String? to,
    int? perPage,
    int? page,
  }) =>
      repository.getHistory(
        status: status,
        from: from,
        to: to,
        perPage: perPage,
        page: page,
      );
}

// ── Get Reservation Detail ────────────────────────────────
class GetReservationDetailUsecase {
  final ReservationRepository repository;
  const GetReservationDetailUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int id) =>
      repository.getReservationById(id);
}

// ── Cancel Reservation ────────────────────────────────────
class CancelReservationUsecase {
  final ReservationRepository repository;
  const CancelReservationUsecase(this.repository);

  Future<Either<Failure, Reservation>> call(int id) =>
      repository.cancelReservation(id);
}

// ── Download Contract ─────────────────────────────────────
class DownloadContractUsecase {
  final ReservationRepository repository;
  const DownloadContractUsecase(this.repository);

  /// Retourne les bytes bruts du PDF
  Future<Either<Failure, List<int>>> call(int reservationId) =>
      repository.downloadContract(reservationId);
}