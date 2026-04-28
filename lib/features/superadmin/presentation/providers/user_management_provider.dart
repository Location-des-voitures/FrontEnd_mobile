/// -------------------------------------------------------
/// USER MANAGEMENT PROVIDER
/// -------------------------------------------------------
/// State management Riverpod pour le Super Admin.
///
/// Gère :
///   - Liste des users (avec filtres, pagination, refresh)
///   - Détail d'un user
///   - Création d'admin
///   - Activation / désactivation / suppression
///
/// Architecture :
///   Provider → Usecase → Repository → Datasource → API
///
/// Les écrans écoutent ce provider via ref.watch()
/// et appellent les méthodes via ref.read().notifier
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; 
import '../../../../core/errors/failures.dart';  // ← AJOUTE CETTE LIGNE

import '../../../../core/providers/core_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/user_management_remote_datasource.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/create_admin_usecase.dart';
import '../../domain/usecases/activate_user_usecase.dart';
import '../../domain/usecases/deactivate_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';

// ═══════════════════════════════════════════════════════
// INJECTION DE DÉPENDANCES (chaîne de providers)
// ═══════════════════════════════════════════════════════

/// Datasource → dépend de DioClient
final userManagementDatasourceProvider = Provider((ref) {
  return UserManagementRemoteDatasource(
    client: ref.read(dioClientProvider),
  );
});

/// Repository → dépend de Datasource
final userManagementRepositoryProvider = Provider((ref) {
  return UserManagementRepositoryImpl(
    ref.read(userManagementDatasourceProvider),
  );
});

/// Usecases → dépendent de Repository
final getAllUsersUsecaseProvider = Provider((ref) {
  return GetAllUsersUsecase(ref.read(userManagementRepositoryProvider));
});

final getUserByIdUsecaseProvider = Provider((ref) {
  return GetUserByIdUsecase(ref.read(userManagementRepositoryProvider));
});

final createAdminUsecaseProvider = Provider((ref) {
  return CreateAdminUsecase(ref.read(userManagementRepositoryProvider));
});

final activateUserUsecaseProvider = Provider((ref) {
  return ActivateUserUsecase(ref.read(userManagementRepositoryProvider));
});

final deactivateUserUsecaseProvider = Provider((ref) {
  return DeactivateUserUsecase(ref.read(userManagementRepositoryProvider));
});

final deleteUserUsecaseProvider = Provider((ref) {
  return DeleteUserUsecase(ref.read(userManagementRepositoryProvider));
});

// ═══════════════════════════════════════════════════════
// STATE : LISTE DES USERS
// ═══════════════════════════════════════════════════════

/// État de la liste des utilisateurs
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
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filters: filters ?? this.filters,
      totalUsers: totalUsers ?? this.totalUsers,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}

/// Provider principal pour la liste des users
final userListProvider =
    StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  return UserListNotifier(ref.read(getAllUsersUsecaseProvider));
});

class UserListNotifier extends StateNotifier<UserListState> {
  final GetAllUsersUsecase _getAllUsers;

  UserListNotifier(this._getAllUsers) : super(const UserListState());

  /// Charger la première page (ou recharger)
  Future<void> loadUsers({UserFilters? filters}) async {
    final activeFilters = filters ?? state.filters;

    state = state.copyWith(
      isLoading: true,
      filters: activeFilters,
    );

    final result = await _getAllUsers(
      filters: UserFilters(
        role: activeFilters.role,
        isActive: activeFilters.isActive,
        perPage: activeFilters.perPage ?? 15,
        page: 1,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        users: paginated.users,
        isLoading: false,
        totalUsers: paginated.total,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
      ),
    );
  }

  /// Charger la page suivante (pagination infinie)
  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final result = await _getAllUsers(
      filters: UserFilters(
        role: state.filters.role,
        isActive: state.filters.isActive,
        perPage: state.filters.perPage ?? 15,
        page: state.currentPage + 1,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        users: [...state.users, ...paginated.users],
        isLoading: false,
        totalUsers: paginated.total,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
      ),
    );
  }

  /// Rafraîchir la liste (pull-to-refresh)
  Future<void> refresh() async {
    await loadUsers(filters: state.filters);
  }

  /// Changer les filtres et recharger
  Future<void> applyFilters(UserFilters filters) async {
    await loadUsers(filters: filters);
  }

  /// Mettre à jour un user dans la liste après modification
  void updateUserInList(User updatedUser) {
    final updatedList = state.users.map((u) {
      return u.id == updatedUser.id ? updatedUser : u;
    }).toList();
    state = state.copyWith(users: updatedList);
  }

  /// Retirer un user de la liste après suppression
  void removeUserFromList(int userId) {
    final updatedList = state.users.where((u) => u.id != userId).toList();
    state = state.copyWith(
      users: updatedList,
      totalUsers: state.totalUsers - 1,
    );
  }
}

// ═══════════════════════════════════════════════════════
// STATE : DÉTAIL D'UN USER
// ═══════════════════════════════════════════════════════

/// Provider pour le détail d'un user (par ID)
final userDetailProvider = FutureProvider.family<User?, int>((ref, id) async {
  final usecase = ref.read(getUserByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// ═══════════════════════════════════════════════════════
// ACTIONS : CRÉER / ACTIVER / DÉSACTIVER / SUPPRIMER
// ═══════════════════════════════════════════════════════

/// Provider pour les actions sur un user
/// Utilisé par les écrans détail et création
final userActionsProvider =
    StateNotifierProvider<UserActionsNotifier, UserActionState>((ref) {
  return UserActionsNotifier(
    createAdmin: ref.read(createAdminUsecaseProvider),
    activateUser: ref.read(activateUserUsecaseProvider),
    deactivateUser: ref.read(deactivateUserUsecaseProvider),
    deleteUser: ref.read(deleteUserUsecaseProvider),
    listNotifier: ref.read(userListProvider.notifier),
  );
});

/// État d'une action en cours
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

  /// Récupère la première erreur d'un champ
  String? fieldError(String field) {
    if (validationErrors.containsKey(field) &&
        validationErrors[field]!.isNotEmpty) {
      return validationErrors[field]!.first;
    }
    return null;
  }

  UserActionState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
  }) {
    return UserActionState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
      errorMessage: errorMessage,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

class UserActionsNotifier extends StateNotifier<UserActionState> {
  final CreateAdminUsecase _createAdmin;
  final ActivateUserUsecase _activateUser;
  final DeactivateUserUsecase _deactivateUser;
  final DeleteUserUsecase _deleteUser;
  final UserListNotifier _listNotifier;

  UserActionsNotifier({
    required CreateAdminUsecase createAdmin,
    required ActivateUserUsecase activateUser,
    required DeactivateUserUsecase deactivateUser,
    required DeleteUserUsecase deleteUser,
    required UserListNotifier listNotifier,
  })  : _createAdmin = createAdmin,
        _activateUser = activateUser,
        _deactivateUser = deactivateUser,
        _deleteUser = deleteUser,
        _listNotifier = listNotifier,
        super(const UserActionState());

  /// Réinitialiser l'état (avant une nouvelle action)
  void reset() => state = const UserActionState();

  /// Créer un nouvel admin
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
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        }
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Admin créé avec succès',
        );
        // Rafraîchir la liste
        _listNotifier.refresh();
        return true;
      },
    );
  }

  /// Activer un compte
  Future<bool> activateUser(int id) async {
    state = state.copyWith(isLoading: true);

    final result = await _activateUser(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Compte activé',
        );
        _listNotifier.updateUserInList(user);
        return true;
      },
    );
  }

  /// Désactiver un compte
  Future<bool> deactivateUser(int id) async {
    state = state.copyWith(isLoading: true);

    final result = await _deactivateUser(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Compte désactivé',
        );
        _listNotifier.updateUserInList(user);
        return true;
      },
    );
  }

  /// Supprimer un utilisateur
  Future<bool> deleteUser(int id) async {
    state = state.copyWith(isLoading: true);

    final result = await _deleteUser(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Utilisateur supprimé',
        );
        _listNotifier.removeUserFromList(id);
        return true;
      },
    );
  }
}