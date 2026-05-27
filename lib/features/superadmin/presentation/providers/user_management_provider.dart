/// -------------------------------------------------------
/// USER MANAGEMENT PROVIDER
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✅ Suppression de l'import legacy 'package:flutter_riverpod/legacy.dart'

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/user_management_remote_datasource.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_admins_usecase.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/create_admin_usecase.dart';
import '../../domain/usecases/activate_user_usecase.dart';
import '../../domain/usecases/deactivate_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';

// ═══════════════════════════════════════════════════════
// INJECTION DE DÉPENDANCES
// ═══════════════════════════════════════════════════════

final userManagementDatasourceProvider = Provider((ref) {
  return UserManagementRemoteDatasource(client: ref.read(dioClientProvider));
});

final userManagementRepositoryProvider = Provider((ref) {
  return UserManagementRepositoryImpl(ref.read(userManagementDatasourceProvider));
});

final getAllUsersUsecaseProvider = Provider((ref) =>
    GetAllUsersUsecase(ref.read(userManagementRepositoryProvider)));

final getAdminsUsecaseProvider = Provider((ref) =>
    GetAdminsUsecase(ref.read(userManagementRepositoryProvider)));

final getUserByIdUsecaseProvider = Provider((ref) =>
    GetUserByIdUsecase(ref.read(userManagementRepositoryProvider)));

final createAdminUsecaseProvider = Provider((ref) =>
    CreateAdminUsecase(ref.read(userManagementRepositoryProvider)));

final activateUserUsecaseProvider = Provider((ref) =>
    ActivateUserUsecase(ref.read(userManagementRepositoryProvider)));

final deactivateUserUsecaseProvider = Provider((ref) =>
    DeactivateUserUsecase(ref.read(userManagementRepositoryProvider)));

final deleteUserUsecaseProvider = Provider((ref) =>
    DeleteUserUsecase(ref.read(userManagementRepositoryProvider)));

// ═══════════════════════════════════════════════════════
// STATE : LISTE DES USERS
// ═══════════════════════════════════════════════════════

class UserListState {
  final List<User> users;
  final bool isLoading;
  final String? errorMessage;
  final UserFilters filters;
  final int totalUsers;
  final int currentPage;
  final int lastPage;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filters = const UserFilters(),
    this.totalUsers = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasError => errorMessage != null;
  bool get isEmpty => users.isEmpty && !isLoading;

  UserListState copyWith({
    List<User>? users,
    bool? isLoading,
    String? errorMessage,
    UserFilters? filters,
    int? totalUsers,
    int? currentPage,
    int? lastPage,
  }) =>
      UserListState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        filters: filters ?? this.filters,
        totalUsers: totalUsers ?? this.totalUsers,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
      );
}

// ═══════════════════════════════════════════════════════
// NOTIFIER : LISTE DES USERS
// ✅ Migré de StateNotifierProvider vers NotifierProvider
// ═══════════════════════════════════════════════════════

final userListProvider =
    NotifierProvider<UserListNotifier, UserListState>(UserListNotifier.new);

class UserListNotifier extends Notifier<UserListState> {
  @override
  UserListState build() => const UserListState();

  GetAllUsersUsecase get _getAllUsers => ref.read(getAllUsersUsecaseProvider);

  Future<void> loadUsers({UserFilters? filters}) async {
    final activeFilters = filters ?? state.filters;
    state = state.copyWith(isLoading: true, filters: activeFilters);

    final result = await _getAllUsers(
      filters: UserFilters(
        search: activeFilters.search,
        role: activeFilters.role,
        isActive: activeFilters.isActive,
        emailVerified: activeFilters.emailVerified,
        perPage: activeFilters.perPage ?? 15,
        page: 1,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (paginated) => state = state.copyWith(
        users: paginated.users,
        isLoading: false,
        totalUsers: paginated.total,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
      ),
    );
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final result = await _getAllUsers(
      filters: UserFilters(
        search: state.filters.search,
        role: state.filters.role,
        isActive: state.filters.isActive,
        emailVerified: state.filters.emailVerified,
        perPage: state.filters.perPage ?? 15,
        page: state.currentPage + 1,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (paginated) => state = state.copyWith(
        users: [...state.users, ...paginated.users],
        isLoading: false,
        totalUsers: paginated.total,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
      ),
    );
  }

  Future<void> refresh() => loadUsers(filters: state.filters);
  Future<void> applyFilters(UserFilters filters) => loadUsers(filters: filters);

  void updateUserInList(User updatedUser) {
    state = state.copyWith(
      users: state.users.map((u) => u.id == updatedUser.id ? updatedUser : u).toList(),
    );
  }

  void removeUserFromList(int userId) {
    state = state.copyWith(
      users: state.users.where((u) => u.id != userId).toList(),
      totalUsers: state.totalUsers - 1,
    );
  }
}

// ═══════════════════════════════════════════════════════
// NOTIFIER : LISTE DES ADMINS
// ✅ Migré de StateNotifierProvider vers NotifierProvider
// ═══════════════════════════════════════════════════════

final adminListProvider =
    NotifierProvider<AdminListNotifier, UserListState>(AdminListNotifier.new);

class AdminListNotifier extends Notifier<UserListState> {
  @override
  UserListState build() => const UserListState();

  GetAdminsUsecase get _getAdmins => ref.read(getAdminsUsecaseProvider);

  Future<void> loadAdmins({UserFilters? filters}) async {
    final activeFilters = filters ?? state.filters;
    state = state.copyWith(isLoading: true, filters: activeFilters);

    final result = await _getAdmins(
      filters: UserFilters(
        search: activeFilters.search,
        isActive: activeFilters.isActive,
        perPage: activeFilters.perPage ?? 15,
        page: 1,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (paginated) => state = state.copyWith(
        users: paginated.users,
        isLoading: false,
        totalUsers: paginated.total,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
      ),
    );
  }

  Future<void> refresh() => loadAdmins(filters: state.filters);
  Future<void> applyFilters(UserFilters filters) => loadAdmins(filters: filters);
}

// ═══════════════════════════════════════════════════════
// DETAIL D'UN USER
// ═══════════════════════════════════════════════════════

final userDetailProvider = FutureProvider.family<User?, int>((ref, id) async {
  final usecase = ref.read(getUserByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// ═══════════════════════════════════════════════════════
// STATE : ACTIONS
// ═══════════════════════════════════════════════════════

class UserActionState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final Map<String, List<String>> validationErrors;

  const UserActionState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
    this.validationErrors = const {},
  });

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  String? fieldError(String field) {
    if (validationErrors.containsKey(field) && validationErrors[field]!.isNotEmpty) {
      return validationErrors[field]!.first;
    }
    return null;
  }

  UserActionState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
  }) =>
      UserActionState(
        isLoading: isLoading ?? this.isLoading,
        successMessage: successMessage,
        errorMessage: errorMessage,
        validationErrors: validationErrors ?? this.validationErrors,
      );
}

// ═══════════════════════════════════════════════════════
// NOTIFIER : ACTIONS
// ✅ Migré de StateNotifierProvider vers NotifierProvider
// ═══════════════════════════════════════════════════════

final userActionsProvider =
    NotifierProvider<UserActionsNotifier, UserActionState>(UserActionsNotifier.new);

class UserActionsNotifier extends Notifier<UserActionState> {
  @override
  UserActionState build() => const UserActionState();

  // Accesseurs via ref — pas de constructeur avec paramètres
  CreateAdminUsecase get _createAdmin => ref.read(createAdminUsecaseProvider);
  ActivateUserUsecase get _activateUser => ref.read(activateUserUsecaseProvider);
  DeactivateUserUsecase get _deactivateUser => ref.read(deactivateUserUsecaseProvider);
  DeleteUserUsecase get _deleteUser => ref.read(deleteUserUsecaseProvider);
  UserListNotifier get _listNotifier => ref.read(userListProvider.notifier);
  AdminListNotifier get _adminListNotifier => ref.read(adminListProvider.notifier);

  void reset() => state = const UserActionState();

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String notifyVia,
    String? password,
    String? passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _createAdmin(
      name: name,
      email: email,
      notifyVia: notifyVia,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    return result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            validationErrors: failure.errors,
          );
        } else {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        }
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, successMessage: 'Admin créé avec succès');
        _listNotifier.refresh();
        _adminListNotifier.refresh();
        return true;
      },
    );
  }

  Future<bool> activateUser(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await _activateUser(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, successMessage: 'Compte activé');
        _listNotifier.updateUserInList(user);
        return true;
      },
    );
  }

  Future<bool> deactivateUser(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await _deactivateUser(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, successMessage: 'Compte désactivé');
        _listNotifier.updateUserInList(user);
        return true;
      },
    );
  }

  Future<bool> deleteUser(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await _deleteUser(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, successMessage: 'Utilisateur supprimé');
        _listNotifier.removeUserFromList(id);
        return true;
      },
    );
  }
}