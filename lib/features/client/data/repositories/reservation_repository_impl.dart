/// -------------------------------------------------------
/// RESERVATION REPOSITORY IMPL — Client Space
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
  Future<Either<Failure, Reservation>> createReservation(
      CreateReservationRequest request) async {
    try {
      final result = await _datasource.createReservation(request);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedReservations>> getReservations({
    String? status,
    int? perPage,
    int? page,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null)  params['status']   = status;
      if (perPage != null) params['per_page'] = perPage;
      if (page != null)    params['page']     = page;

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
  Future<Either<Failure, PaginatedReservations>> getHistory({
    String? status,
    String? from,
    String? to,
    int? perPage,
    int? page,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null)  params['status']   = status;
      if (from != null)    params['from']     = from;
      if (to != null)      params['to']       = to;
      if (perPage != null) params['per_page'] = perPage;
      if (page != null)    params['page']     = page;

      final result = await _datasource.getHistory(
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
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Reservation>> cancelReservation(int id) async {
    try {
      return Right(await _datasource.cancelReservation(id));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadContract(
      int reservationId) async {
    try {
      final bytes = await _datasource.downloadContract(reservationId);
      return Right(bytes);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadDocument(int documentId) async {
    try {
      final bytes = await _datasource.downloadDocument(documentId);
      return Right(bytes);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}