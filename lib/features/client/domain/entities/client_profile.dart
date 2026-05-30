/// -------------------------------------------------------
/// CLIENT PROFILE ENTITY
/// -------------------------------------------------------
library;

class ClientProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final bool emailVerified;
  final DateTime? createdAt;

  const ClientProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    required this.emailVerified,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty  ? lastName[0]  : '';
    return '$f$l'.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Body pour PUT /api/client/profile
class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
  });
}

/// Body pour PUT /api/client/profile/password
class ChangePasswordRequest {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });
}