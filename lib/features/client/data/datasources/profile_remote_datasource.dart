/// -------------------------------------------------------
/// PROFILE REMOTE DATASOURCE — Client Space
/// -------------------------------------------------------
library;

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/client_profile.dart';
import '../models/client_profile_model.dart';

class ProfileRemoteDatasource {
  final DioClient _client;
  const ProfileRemoteDatasource({required DioClient client})
      : _client = client;

  Future<ClientProfileModel> getProfile() async {
    final response = await _client.get('/client/profile');
    return ClientProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<ClientProfileModel> updateProfile(
      UpdateProfileRequest request) async {
    final response = await _client.put(
      '/client/profile',
      data: {
        'first_name': request.firstName,
        'last_name':  request.lastName,
        if (request.phone != null)   'phone':   request.phone,
        if (request.address != null) 'address': request.address,
      },
    );
    return ClientProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _client.put(
      '/client/profile/password',
      data: {
        'current_password':      request.currentPassword,
        'password':              request.password,
        'password_confirmation': request.passwordConfirmation,
      },
    );
  }
}