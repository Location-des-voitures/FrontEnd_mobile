/// -------------------------------------------------------
/// RESERVATION REPOSITORY IMPL
/// -------------------------------------------------------
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDatasource _datasource;
  const ReservationRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedReservations>> getReservations(
      {ReservationFilters? filters}) async {
    try {
      final params = <String, dynamic>{};
      if (filters != null) {
        if (filters.search?.isNotEmpty == true) params['search'] = filters.search;
        if (filters.status != null) {
          params['status'] = _statusToApi(filters.status!);
        }
        if (filters.fromDate != null) {
          params['from'] = filters.fromDate!.toIso8601String().split('T')[0];
        }
        if (filters.toDate != null) {
          params['to'] = filters.toDate!.toIso8601String().split('T')[0];
        }
        if (filters.carId != null) params['car_id'] = filters.carId;
        if (filters.clientId != null) params['client_id'] = filters.clientId;
        if (filters.perPage != null) params['per_page'] = filters.perPage;
        if (filters.page != null) params['page'] = filters.page;
      }
      final result = await _datasource.getReservations(
          params: params.isNotEmpty ? params : null);
      return Right(result.toDomain());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(int id) async {
    try {
      return Right(await _datasource.getReservationById(id));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> approveReservation(int id) async {
    try {
      return Right(await _datasource.approveReservation(id));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> rejectReservation(int id,
      {String? reason}) async {
    try {
      return Right(await _datasource.rejectReservation(id, reason: reason));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> verifyPayment(int paymentId) async {
    try {
      return Right(await _datasource.verifyPayment(paymentId));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> cancelReservation(int id) async {
    try {
      return Right(await _datasource.cancelReservation(id));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  String _statusToApi(ReservationStatus status) => switch (status) {
        ReservationStatus.pending => 'PENDING',
        ReservationStatus.awaitingPayment => 'AWAITING_PAYMENT',
        ReservationStatus.paymentPendingVerification =>
          'PAYMENT_PENDING_VERIFICATION',
        ReservationStatus.confirmed => 'CONFIRMED',
        ReservationStatus.completed => 'COMPLETED',
        ReservationStatus.cancelled => 'CANCELLED',
        ReservationStatus.rejected => 'REJECTED',
      };
}
