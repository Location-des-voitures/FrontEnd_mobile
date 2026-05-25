/// USER LIST MODEL — FlotTrack API
library;

import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/user_management_repository.dart';

class UserListModel {
  final List<UserModel> users;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const UserListModel({
    required this.users,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    final rawUsers = (json['users'] ?? json['admins']) as List;
    final usersList = rawUsers
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>;

    return UserListModel(
      users: usersList,
      total: pagination['total'] as int,
      perPage: pagination['per_page'] as int,
      currentPage: pagination['current_page'] as int,
      lastPage: pagination['last_page'] as int,
    );
  }

  PaginatedUsers toDomain() {
    return PaginatedUsers(
      users: users,
      total: total,
      perPage: perPage,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}
