/// -------------------------------------------------------
/// RESERVATION REMOTE DATASOURCE
/// -------------------------------------------------------
library;

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/reservation_model.dart';

// Ajoute dans api_constants.dart :
// static const String reservations = '/admin/reservations';
// static String reservationById(int id) => '/admin/reservations/$id';
// static String approveReservation(int id) => '/admin/reservations/$id/approve';
// static String rejectReservation(int id) => '/admin/reservations/$id/reject';

class ReservationRemoteDatasource {
  final DioClient _client;
  const ReservationRemoteDatasource({required DioClient client})
      : _client = client;

  Future<PaginatedReservationsModel> getReservations(
      {Map<String, dynamic>? params}) async {
    final response = await _client.get('/admin/reservations',
        queryParameters: params);
    return PaginatedReservationsModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ReservationModel> getReservationById(int id) async {
    final response = await _client.get('/admin/reservations/$id');
    return ReservationModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ReservationModel> approveReservation(int id) async {
    final response =
        await _client.post('/admin/reservations/$id/approve');
    return ReservationModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ReservationModel> rejectReservation(int id,
      {String? reason}) async {
    final response = await _client.post(
      '/admin/reservations/$id/reject',
      data: reason != null ? {'reason': reason} : null,
    );
    return ReservationModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ReservationModel> verifyPayment(int paymentId) async {
    final response = await _client.post(
      '/admin/reservations/payments/$paymentId/verify',
    );
    return ReservationModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<Response<List<int>>> downloadPaymentReceipt(int paymentId) {
    return _client.getBytes('/admin/reservations/payments/$paymentId/receipt');
  }

  Future<Response<List<int>>> downloadInvoicePdf(int invoiceId) {
    return _client.getBytes('/admin/invoices/$invoiceId/pdf');
  }

  Future<Response<List<int>>> downloadContractPdf(int contractId) {
    return _client.getBytes('/admin/contracts/$contractId/pdf');
  }

  Future<ReservationModel> cancelReservation(int id) async {
    final response =
        await _client.put('/admin/reservations/$id/cancel');
    return ReservationModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
