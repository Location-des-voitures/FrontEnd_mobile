/// -------------------------------------------------------
/// USER MODEL — Traducteur JSON ↔ Dart
/// -------------------------------------------------------
/// Extends l'entité User du Domain.
/// Ajoute fromJson() et toJson() pour communiquer
/// avec l'API Laravel.
///
/// Structure JSON de l'API (login, register, me) :
/// {
///   "id":             5,
///   "name":           "Jane Dupont",
///   "email":          "jane@example.com",
///   "role":           "client",
///   "is_active":      true,
///   "email_verified": true,
///   "created_at":     "2024-06-01 09:00:00"
/// }
/// -------------------------------------------------------

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    required super.emailVerified,
    required super.createdAt,
  });

  /// Crée un UserModel à partir du JSON de l'API
  ///
  /// Utilisé dans 2 cas :
  ///   1. Login  → json = response['data']['user']
  ///   2. Me     → json = response['data']
  ///   3. Register → json = response['data']
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      emailVerified: json['email_verified'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  /// Convertit le UserModel en JSON
  /// Utile pour stocker le user localement (cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'email_verified': emailVerified,
      'created_at': createdAt,
    };
  }

  /// Crée un UserModel depuis un JSON stocké localement
  /// (même format que toJson)
  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}