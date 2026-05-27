/// -------------------------------------------------------
/// RESERVATION ENTITY — Client Space
/// -------------------------------------------------------
library;

enum ReservationStatus {
  pending,           // En attente admin
  approved,          // Approuvé → awaiting payment
  awaitingPayment,   // Attente paiement client
  confirmed,         // Payé + contrat généré
  completed,         // Terminé
  cancelled,         // Annulé par client
  rejected,          // Refusé par admin
}

class Reservation {
  final int id;
  final int carId;
  final String carBrand;
  final String carModel;
  final String? carImageUrl;
  final double pricePerDay;
  final String startDate;    // Y-m-d
  final String endDate;      // Y-m-d
  final int totalDays;
  final double totalAmount;
  final ReservationStatus status;
  final String? rejectionReason;
  final bool hasContract;
  final int? contractId;
  final DateTime createdAt;

  const Reservation({
    required this.id,
    required this.carId,
    required this.carBrand,
    required this.carModel,
    this.carImageUrl,
    required this.pricePerDay,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalAmount,
    required this.status,
    this.rejectionReason,
    required this.hasContract,
    this.contractId,
    required this.createdAt,
  });

  // ── Logique métier ────────────────────────────────────
  bool get canCancel    => status == ReservationStatus.pending;
  bool get canDownload  => status == ReservationStatus.confirmed ||
                           status == ReservationStatus.completed;
  bool get isPending    => status == ReservationStatus.pending;
  bool get isActive     => status == ReservationStatus.confirmed;
  bool get isHistory    =>
      status == ReservationStatus.completed ||
      status == ReservationStatus.cancelled ||
      status == ReservationStatus.rejected;

  String get carName => '$carBrand $carModel';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservation && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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

/// Données pour créer une réservation (multipart)
class CreateReservationRequest {
  final int carId;
  final String startDate;
  final String endDate;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String cinFilePath;            // chemin local fichier CIN
  final String drivingLicenseFilePath; // chemin local permis
  final String? birthDate;
  final String? licenseNumber;
  final String? licenseExpiration;

  const CreateReservationRequest({
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.cinFilePath,
    required this.drivingLicenseFilePath,
    this.birthDate,
    this.licenseNumber,
    this.licenseExpiration,
  });
}