/// -------------------------------------------------------
/// RESERVATION ENTITY — FlotTrack Admin
/// -------------------------------------------------------
library;

enum ReservationStatus {
  pending,
  awaitingPayment,
  paymentPendingVerification,
  confirmed,
  completed,
  cancelled,
  rejected,
}

class Reservation {
  final int id;
  final int carId;
  final String carName;
  final String carLicensePlate;
  final String? carImage;
  final int clientId;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final ReservationStatus status;
  final String? notes;
  final DateTime? createdAt;
  final int? invoiceId;
  final int? contractId;
  final int? latestPaymentId;
  final DateTime? latestPaymentUploadedAt;

  const Reservation({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carLicensePlate,
    this.carImage,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.createdAt,
    this.invoiceId,
    this.contractId,
    this.latestPaymentId,
    this.latestPaymentUploadedAt,
  });

  // ── Logique métier ───────────────────────────────────
  int get durationDays => endDate.difference(startDate).inDays;
  bool get isPending => status == ReservationStatus.pending;
  bool get isAwaitingPayment => status == ReservationStatus.awaitingPayment;
  bool get isPaymentPendingVerification =>
      status == ReservationStatus.paymentPendingVerification;
  bool get isConfirmed => status == ReservationStatus.confirmed;
  bool get isCompleted => status == ReservationStatus.completed;
  bool get isCancelled =>
      status == ReservationStatus.cancelled ||
      status == ReservationStatus.rejected;
  bool get canApprove => status == ReservationStatus.pending;
  bool get canReject => status == ReservationStatus.pending;
  bool get canVerifyPayment =>
      status == ReservationStatus.paymentPendingVerification &&
      latestPaymentId != null;
  bool get canDownloadContract =>
      status == ReservationStatus.confirmed && contractId != null;

  String get initials {
    final parts = clientName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (clientName.trim().isEmpty) return 'CL';
    if (clientName.trim().length == 1) return clientName.trim().toUpperCase();
    return clientName.substring(0, 2).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
