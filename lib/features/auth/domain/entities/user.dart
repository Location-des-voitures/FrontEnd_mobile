/// -------------------------------------------------------
/// USER ENTITY — FlotTrack
/// -------------------------------------------------------
/// Aligné sur la réponse API :
/// {
///   "id": 1, "name": "Ahmed", "email": "ahmed@flottrack.ma",
///   "role": "super_admin", "is_active": true,
///   "email_verified_at": "2026-04-20T10:00:00.000000Z",
///   "google_id": null, "google_avatar": null
/// }
/// -------------------------------------------------------
library;

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? emailVerifiedAt;  // null = pas vérifié
  final String? googleId;
  final String? googleAvatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    this.googleId,
    this.googleAvatar,
  });

  // ── Logique métier ───────────────────────────────────
  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';
  bool get isClient => role == 'client';
  bool get emailVerified => emailVerifiedAt != null;
  bool get canLogin => isActive && emailVerified;
  bool get isGoogleUser => googleId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, role: $role)';
}