/// -------------------------------------------------------
/// USER MODEL — FlotTrack API
/// -------------------------------------------------------
library;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    super.emailVerifiedAt,
    super.googleId,
    super.googleAvatar,
  });

  /// Parse depuis le JSON de l'API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? true,
      emailVerifiedAt: json['email_verified_at'] as String?,
      googleId: json['google_id'] as String?,
      googleAvatar: json['google_avatar'] as String?,
    );
  }

  /// Convertir en JSON (pour cache local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'email_verified_at': emailVerifiedAt,
      'google_id': googleId,
      'google_avatar': googleAvatar,
    };
  }
}
