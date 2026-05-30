/// -------------------------------------------------------
/// CLIENT PROFILE MODEL
/// -------------------------------------------------------
library;

import '../../domain/entities/client_profile.dart';

class ClientProfileModel extends ClientProfile {
  const ClientProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.address,
    required super.emailVerified,
    super.createdAt,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id:            json['id'] as int,
      firstName:     json['first_name'] as String,
      lastName:      json['last_name'] as String,
      email:         json['email'] as String,
      phone:         json['phone'] as String?,
      address:       json['address'] as String?,
      emailVerified: json['email_verified_at'] != null,
      createdAt:     json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toUpdateJson(UpdateProfileRequest req) => {
        'first_name': req.firstName,
        'last_name':  req.lastName,
        if (req.phone != null)   'phone':   req.phone,
        if (req.address != null) 'address': req.address,
      };
}