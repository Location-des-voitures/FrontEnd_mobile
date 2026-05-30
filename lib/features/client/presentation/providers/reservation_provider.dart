/// -------------------------------------------------------
/// RESERVATION PROVIDER — Client Space
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart'; // ← assure-toi que ce chemin est correct
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reservation_remote_datasource.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../domain/usecases/reservation_usecases.dart';

// ── Injection ─────────────────────────────────────────────
final reservationDatasourceProvider = Provider(
    (ref) => ReservationRemoteDatasource(client: ref.read(dioClientProvider)));

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) =>
    ReservationRepositoryImpl(ref.read(reservationDatasourceProvider)));

final createReservationUsecaseProvider = Provider(
    (ref) => CreateReservationUsecase(ref.read(reservationRepositoryProvider)));

final getReservationsUsecaseProvider = Provider(
    (ref) => GetReservationsUsecase(ref.read(reservationRepositoryProvider)));

final getHistoryUsecaseProvider = Provider(
    (ref) => GetHistoryUsecase(ref.read(reservationRepositoryProvider)));

final getReservationDetailUsecaseProvider = Provider((ref) =>
    GetReservationDetailUsecase(ref.read(reservationRepositoryProvider)));

final cancelReservationUsecaseProvider = Provider(
    (ref) => CancelReservationUsecase(ref.read(reservationRepositoryProvider)));

final downloadContractUsecaseProvider = Provider(
    (ref) => DownloadContractUsecase(ref.read(reservationRepositoryProvider)));

// ── State : Liste active ──────────────────────────────────
class ReservationListState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? errorMessage;
  final int total;
  final int currentPage;
  final int lastPage;

  const ReservationListState({
    this.reservations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get isEmpty => reservations.isEmpty && !isLoading;

  int get pendingCount =>
      reservations.where((r) => r.isPending).length;

  ReservationListState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? errorMessage,
    int? total,
    int? currentPage,
    int? lastPage,
  }) =>
      ReservationListState(
        reservations: reservations ?? this.reservations,
        isLoading:    isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        total:        total ?? this.total,
        currentPage:  currentPage ?? this.currentPage,
        lastPage:     lastPage ?? this.lastPage,
      );
}

final reservationListProvider =
    NotifierProvider<ReservationListNotifier, ReservationListState>(() {
  return ReservationListNotifier();
});

class ReservationListNotifier extends Notifier<ReservationListState> {
  late final GetReservationsUsecase _getReservations;
  late final CancelReservationUsecase _cancel;

  @override
  ReservationListState build() {
    _getReservations = ref.read(getReservationsUsecaseProvider);
    _cancel          = ref.read(cancelReservationUsecaseProvider);
    return const ReservationListState();
  }

  Future<void> load({String? status}) async {
    state = state.copyWith(isLoading: true);
    final result = await _getReservations(
        status: status, perPage: 15, page: 1);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(
        reservations: p.reservations,
        isLoading:    false,
        total:        p.total,
        currentPage:  p.currentPage,
        lastPage:     p.lastPage,
      ),
    );
  }

  Future<bool> cancel(int id) async {
    final result = await _cancel(id);
    return result.fold(
      (_) => false,
      (updated) {
        state = state.copyWith(
          reservations: state.reservations
              .map((r) => r.id == updated.id ? updated : r)
              .toList(),
        );
        return true;
      },
    );
  }

  Future<void> refresh() => load();
}

// ── State : Historique ────────────────────────────────────
final historyListProvider =
    NotifierProvider<HistoryNotifier, ReservationListState>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends Notifier<ReservationListState> {
  late final GetHistoryUsecase _getHistory;

  @override
  ReservationListState build() {
    _getHistory = ref.read(getHistoryUsecaseProvider);
    return const ReservationListState();
  }

  Future<void> load({String? status, String? from, String? to}) async {
    state = state.copyWith(isLoading: true);
    final result = await _getHistory(
        status: status, from: from, to: to, perPage: 15, page: 1);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(
        reservations: p.reservations,
        isLoading:    false,
        total:        p.total,
        currentPage:  p.currentPage,
        lastPage:     p.lastPage,
      ),
    );
  }

  Future<void> refresh() => load();
}

// ── State : Création réservation ──────────────────────────
class CreateReservationState {
  final bool isLoading;
  final Reservation? created;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;

  const CreateReservationState({
    this.isLoading = false,
    this.created,
    this.errorMessage,
    this.fieldErrors,
  });
}

final createReservationProvider =
    NotifierProvider<CreateReservationNotifier, CreateReservationState>(() {
  return CreateReservationNotifier();
});

class CreateReservationNotifier extends Notifier<CreateReservationState> {
  late final CreateReservationUsecase _create;

  @override
  CreateReservationState build() {
    _create = ref.read(createReservationUsecaseProvider);
    return const CreateReservationState();
  }

  Future<bool> submit(CreateReservationRequest request) async {
    state = const CreateReservationState(isLoading: true);
    final result = await _create(request);
    return result.fold(
      (f) {
        state = CreateReservationState(
          errorMessage: f.message,
          fieldErrors:  f is ValidationFailure ? f.errors : null,
        );
        return false;
      },
      (reservation) {
        state = CreateReservationState(created: reservation);
        return true;
      },
    );
  }

  void reset() => state = const CreateReservationState();
}

// ── Détail réservation ────────────────────────────────────
final reservationDetailProvider =
    FutureProvider.family<Reservation?, int>((ref, id) async {
  final usecase = ref.read(getReservationDetailUsecaseProvider);
  final result  = await usecase(id);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});