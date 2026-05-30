/// -------------------------------------------------------
/// RESERVATION REMOTE DATASOURCE — Client Space
/// -------------------------------------------------------
/// Points clés :
///  • createReservation → multipart/form-data (CIN + permis)
///  • downloadContract  → ResponseType.bytes (PDF binaire)
/// -------------------------------------------------------
library;

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/reservation.dart';
import '../models/reservation_model.dart';

class ReservationRemoteDatasource {
  final DioClient _client;
  const ReservationRemoteDatasource({required DioClient client})
      : _client = client;

  // ── Create (multipart) ────────────────────────────────
  Future<ReservationModel> createReservation(
      CreateReservationRequest request) async {
    final formData = FormData.fromMap({
      'car_id':     request.carId,
      'start_date': request.startDate,
      'end_date':   request.endDate,
      'full_name':  request.fullName,
      'email':      request.email,
      'phone':      request.phone,
      'address':    request.address,
      // Fichiers — Dio gère le multipart automatiquement
      'cin': await MultipartFile.fromFile(
        request.cinFilePath,
        filename: 'cin${_ext(request.cinFilePath)}',
      ),
      'driving_license': await MultipartFile.fromFile(
        request.drivingLicenseFilePath,
        filename: 'license${_ext(request.drivingLicenseFilePath)}',
      ),
      if (request.birthDate != null)
        'birth_date': request.birthDate,
      if (request.licenseNumber != null)
        'license_number': request.licenseNumber,
      if (request.licenseExpiration != null)
        'license_expiration': request.licenseExpiration,
    });

    final response = await _client.post(
      '/client/reservations',
      data: formData,
    );

    return ReservationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── List active ───────────────────────────────────────
  Future<PaginatedReservationsModel> getReservations({
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.get(
      '/client/reservations',
      queryParameters: params,
    );
    return PaginatedReservationsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── History ───────────────────────────────────────────
  Future<PaginatedReservationsModel> getHistory({
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.get(
      '/client/reservations/history',
      queryParameters: params,
    );
    return PaginatedReservationsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── Detail ────────────────────────────────────────────
  Future<ReservationModel> getReservationById(int id) async {
    final response = await _client.get('/client/reservations/$id');
    return ReservationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── Cancel ────────────────────────────────────────────
  Future<ReservationModel> cancelReservation(int id) async {
    final response = await _client.post('/client/reservations/$id/cancel');
    return ReservationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── Download PDF (bytes bruts) ────────────────────────
  Future<List<int>> downloadContract(int reservationId) async {
  final response = await _client.getBytes(
    '/client/contracts/$reservationId/download',
  );
  return response.data ?? [];
}

  // ── Download document ─────────────────────────────────
  Future<List<int>> downloadDocument(int documentId) async {
  final response = await _client.getBytes(
    '/client/documents/$documentId/download',
  );
  return response.data ?? [];
}

  // ── Helper extension fichier ──────────────────────────
  String _ext(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? '.${parts.last}' : '.jpg';
  }
}