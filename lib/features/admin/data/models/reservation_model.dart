/// -------------------------------------------------------
/// RESERVATION MODEL — FlotTrack API
/// -------------------------------------------------------
library;

import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.carId,
    required super.carName,
    required super.carLicensePlate,
    super.carImage,
    required super.clientId,
    required super.clientName,
    required super.clientEmail,
    super.clientPhone,
    required super.startDate,
    required super.endDate,
    required super.totalPrice,
    required super.status,
    super.notes,
    super.createdAt,
    super.invoiceId,
    super.contractId,
    super.latestPaymentId,
    super.latestPaymentUploadedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final car = json['car'] as Map<String, dynamic>? ?? {};
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final invoice = json['invoice'] as Map<String, dynamic>?;
    final contract = json['contract'] as Map<String, dynamic>?;
    final payment = _latestPayment(json);

    return ReservationModel(
      id: json['id'] as int,
      carId: _asInt(json['car_id'] ?? car['id']),
      carName: _carName(car),
      carLicensePlate:
          (car['plate'] ?? car['license_plate'] ?? json['car_plate'] ?? '')
              .toString(),
      carImage: (car['image'] ?? (car['images'] as List?)?.firstOrNull)
          ?.toString(),
      clientId: _asInt(json['client_id'] ?? client['id']),
      clientName: client['name'] as String? ?? '',
      clientEmail: client['email'] as String? ?? '',
      clientPhone: client['phone'] as String?,
      startDate: DateTime.parse(
          (json['start_date'] ?? json['starts_at']).toString()),
      endDate:
          DateTime.parse((json['end_date'] ?? json['ends_at']).toString()),
      totalPrice: _asDouble(
          json['total_price'] ?? json['amount'] ?? json['amount_paid']),
      status: _parseStatus(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      invoiceId: _nullableInt(json['invoice_id'] ?? invoice?['id']),
      contractId: _nullableInt(json['contract_id'] ?? contract?['id']),
      latestPaymentId: _nullableInt(payment?['id'] ?? json['payment_id']),
      latestPaymentUploadedAt: payment?['uploaded_at'] != null
          ? DateTime.tryParse(payment!['uploaded_at'].toString())
          : null,
    );
  }

  static ReservationStatus _parseStatus(String s) => switch (s.toUpperCase()) {
        'AWAITING_PAYMENT' => ReservationStatus.awaitingPayment,
        'PAYMENT_PENDING_VERIFICATION' =>
          ReservationStatus.paymentPendingVerification,
        'CONFIRMED' => ReservationStatus.confirmed,
        'COMPLETED' => ReservationStatus.completed,
        'CANCELLED' => ReservationStatus.cancelled,
        'REJECTED' || 'REFUSED' => ReservationStatus.rejected,
        _ => ReservationStatus.pending,
      };

  static String _carName(Map<String, dynamic> car) {
    final name = car['name']?.toString();
    if (name != null && name.isNotEmpty) return name;
    final brand = car['brand']?.toString() ?? '';
    final model = car['model']?.toString() ?? '';
    return '$brand $model'.trim();
  }

  static int _asInt(Object? value) => int.tryParse(value.toString()) ?? 0;
  static int? _nullableInt(Object? value) =>
      value == null ? null : int.tryParse(value.toString());

  static Map<String, dynamic>? _latestPayment(Map<String, dynamic> json) {
    final payments = json['payments'] ?? json['payment_history'];
    if (payments is List && payments.isNotEmpty) {
      return Map<String, dynamic>.from(payments.last as Map);
    }
    if (json['payment'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json['payment'] as Map);
    }
    return null;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PaginatedReservationsModel {
  final List<ReservationModel> reservations;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedReservationsModel({
    required this.reservations,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedReservationsModel.fromJson(Map<String, dynamic> json) {
    final list = ((json['reservations'] ?? json['data'] ?? []) as List)
        .map((r) => ReservationModel.fromJson(r as Map<String, dynamic>))
        .toList();
    final p = json['pagination'] as Map<String, dynamic>? ?? {};
    return PaginatedReservationsModel(
      reservations: list,
      total: p['total'] as int? ?? list.length,
      perPage: p['per_page'] as int? ?? list.length,
      currentPage: p['current_page'] as int? ?? 1,
      lastPage: p['last_page'] as int? ?? 1,
    );
  }

  PaginatedReservations toDomain() => PaginatedReservations(
        reservations: reservations,
        total: total,
        perPage: perPage,
        currentPage: currentPage,
        lastPage: lastPage,
      );
}
