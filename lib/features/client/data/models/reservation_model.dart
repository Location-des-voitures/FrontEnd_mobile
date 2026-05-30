/// -------------------------------------------------------
/// RESERVATION MODEL — Client Space
/// -------------------------------------------------------
library;

import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.carId,
    required super.carBrand,
    required super.carModel,
    super.carImageUrl,
    required super.pricePerDay,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.totalAmount,
    required super.status,
    super.rejectionReason,
    required super.hasContract,
    super.contractId,
    required super.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final car = json['car'] as Map<String, dynamic>? ?? {};

    return ReservationModel(
      id:              json['id'] as int,
      carId:           json['car_id'] as int,
      carBrand:        car['brand'] as String? ?? '',
      carModel:        car['model'] as String? ?? '',
      carImageUrl:     car['image_url'] as String?,
      pricePerDay:     (json['price_per_day'] as num? ?? 0).toDouble(),
      startDate:       json['start_date'] as String,
      endDate:         json['end_date'] as String,
      totalDays:       json['total_days'] as int? ?? 0,
      totalAmount:     (json['total_amount'] as num? ?? 0).toDouble(),
      status:          _parseStatus(json['status'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      hasContract:     json['has_contract'] as bool? ?? false,
      contractId:      json['contract_id'] as int?,
      createdAt:       DateTime.parse(json['created_at'] as String),
    );
  }

  static ReservationStatus _parseStatus(String s) => switch (s) {
        'approved'         => ReservationStatus.approved,
        'awaiting_payment' => ReservationStatus.awaitingPayment,
        'confirmed'        => ReservationStatus.confirmed,
        'completed'        => ReservationStatus.completed,
        'cancelled'        => ReservationStatus.cancelled,
        'rejected'         => ReservationStatus.rejected,
        _                  => ReservationStatus.pending,
      };
}

class PaginatedReservationsModel {
  final List<ReservationModel> reservations;
  final int total, perPage, currentPage, lastPage;

  const PaginatedReservationsModel({
    required this.reservations,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedReservationsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ??
        json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedReservationsModel(
      reservations: data
          .map((r) => ReservationModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      total:       _int(meta['total']),
      perPage:     _int(meta['per_page']),
      currentPage: _int(meta['current_page']),
      lastPage:    _int(meta['last_page']),
    );
  }

  PaginatedReservations toDomain() => PaginatedReservations(
        reservations: reservations,
        total:        total,
        perPage:      perPage,
        currentPage:  currentPage,
        lastPage:     lastPage,
      );

  static int _int(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}