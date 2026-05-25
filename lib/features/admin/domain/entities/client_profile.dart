/// -------------------------------------------------------
/// CLIENT ENTITY — FlotTrack Admin
/// -------------------------------------------------------
/// Un client est un User avec role = 'client' + stats
library;

class ClientProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final bool emailVerified;
  final int totalReservations;
  final int activeReservations;
  final double totalSpent;
  final DateTime? lastReservationDate;
  final DateTime? createdAt;

  const ClientProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.emailVerified,
    this.totalReservations = 0,
    this.activeReservations = 0,
    this.totalSpent = 0,
    this.lastReservationDate,
    this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.trim().isEmpty) return 'CL';
    if (name.trim().length == 1) return name.trim().toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
