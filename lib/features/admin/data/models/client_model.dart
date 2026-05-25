/// -------------------------------------------------------
/// CLIENT MODEL — FlotTrack API
/// -------------------------------------------------------
library;

import '../../domain/entities/client_profile.dart';

class ClientModel extends ClientProfile {
  const ClientModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.isActive,
    required super.emailVerified,
    super.totalReservations,
    super.activeReservations,
    super.totalSpent,
    super.lastReservationDate,
    super.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return ClientModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified_at'] != null,
      totalReservations: stats['total_reservations'] as int? ?? 0,
      activeReservations: stats['active_reservations'] as int? ?? 0,
      totalSpent: (stats['total_spent'] as num?)?.toDouble() ?? 0.0,
      lastReservationDate: json['last_reservation_date'] != null
          ? DateTime.tryParse(json['last_reservation_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class PaginatedClientsModel {
  final List<ClientModel> clients;
  final int total, perPage, currentPage, lastPage;

  const PaginatedClientsModel({
    required this.clients,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedClientsModel.fromJson(Map<String, dynamic> json) {
    final list = (json['clients'] as List)
        .map((c) => ClientModel.fromJson(c as Map<String, dynamic>))
        .toList();
    final p = json['pagination'] as Map<String, dynamic>;
    return PaginatedClientsModel(
      clients: list,
      total: p['total'] as int,
      perPage: p['per_page'] as int,
      currentPage: p['current_page'] as int,
      lastPage: p['last_page'] as int,
    );
  }
}
