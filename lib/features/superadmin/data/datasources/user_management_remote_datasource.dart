/// -------------------------------------------------------
/// USER MANAGEMENT REMOTE DATASOURCE — FlotTrack API
/// -------------------------------------------------------
/// GET    /api/admin/users?search=&role=&is_active=&email_verified=
/// GET    /api/admin/users/{id}
/// PUT    /api/admin/users/{id}/activate
/// PUT    /api/admin/users/{id}/deactivate
/// DELETE /api/admin/users/{id}
/// -------------------------------------------------------
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../models/user_list_model.dart';

class UserManagementRemoteDatasource {
  final DioClient _client;

  const UserManagementRemoteDatasource({required DioClient client})
      : _client = client;

      Future<UserModel> createAdmin(UserModel user) async {
    final response = await _client.post(
      ApiConstants.users, // Vérifiez que cet endpoint correspond à votre API Laravel
      data: user.toJson(),
    );
    
    return UserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<UserListModel> getAllUsers({UserFilters? filters}) async {
    final queryParams = <String, dynamic>{};

    if (filters != null) {
      if (filters.search != null && filters.search!.isNotEmpty) {
        queryParams['search'] = filters.search;
      }
      if (filters.role != null) {
        queryParams['role'] = filters.role;
      }
      if (filters.isActive != null) {
        queryParams['is_active'] = filters.isActive.toString();
      }
      if (filters.emailVerified != null) {
        queryParams['email_verified'] = filters.emailVerified.toString();
      }
      if (filters.perPage != null) {
        queryParams['per_page'] = filters.perPage;
      }
      if (filters.page != null) {
        queryParams['page'] = filters.page;
      }
    }

    final response = await _client.get(
      ApiConstants.users,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return UserListModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<UserModel> getUserById(int id) async {
    final response = await _client.get(ApiConstants.userById(id));
    return UserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<UserModel> activateUser(int id) async {
    final response = await _client.put(ApiConstants.activateUser(id));
    return UserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<UserModel> deactivateUser(int id) async {
    final response = await _client.put(ApiConstants.deactivateUser(id));
    return UserModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteUser(int id) async {
    await _client.delete(ApiConstants.deleteUser(id));
  }
}