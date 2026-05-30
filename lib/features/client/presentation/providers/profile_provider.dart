/// -------------------------------------------------------
/// PROFILE PROVIDER — Client Space
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

// ── Injection ─────────────────────────────────────────────
final profileDatasourceProvider = Provider(
    (ref) => ProfileRemoteDatasource(client: ref.read(dioClientProvider)));

final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => ProfileRepositoryImpl(ref.read(profileDatasourceProvider)));

final getProfileUsecaseProvider =
    Provider((ref) => GetProfileUsecase(ref.read(profileRepositoryProvider)));

final updateProfileUsecaseProvider = Provider(
    (ref) => UpdateProfileUsecase(ref.read(profileRepositoryProvider)));

final changePasswordUsecaseProvider = Provider(
    (ref) => ChangePasswordUsecase(ref.read(profileRepositoryProvider)));

// ── State : Profil ────────────────────────────────────────
class ProfileState {
  final ClientProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    ClientProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) =>
      ProfileState(
        profile:      profile ?? this.profile,
        isLoading:    isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  late final GetProfileUsecase     _getProfile;
  late final UpdateProfileUsecase  _updateProfile;
  late final ChangePasswordUsecase _changePassword;

  @override
  ProfileState build() {
    _getProfile     = ref.read(getProfileUsecaseProvider);
    _updateProfile  = ref.read(updateProfileUsecaseProvider);
    _changePassword = ref.read(changePasswordUsecaseProvider);
    return const ProfileState();
  }

  // ── Load ────────────────────────────────────────────────
  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await _getProfile();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(profile: p, isLoading: false),
    );
  }

  // ── Update ──────────────────────────────────────────────
  Future<bool> update(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true);
    final result = await _updateProfile(request);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
      (updated) {
        state = state.copyWith(profile: updated, isLoading: false);
        return true;
      },
    );
  }

  // ── Change Password ─────────────────────────────────────
  Future<bool> changePassword(ChangePasswordRequest request) async {
    state = state.copyWith(isLoading: true);
    final result = await _changePassword(request);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}