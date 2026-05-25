/// -------------------------------------------------------
/// RESERVATION PROVIDER — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reservation_remote_datasource.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../domain/usecases/reservation/reservation_usecases.dart';

// ── Injection ───────────────────────────────────────────
final reservationDatasourceProvider = Provider((ref) =>
    ReservationRemoteDatasource(client: ref.read(dioClientProvider)));

final reservationRepositoryProvider =
    Provider<ReservationRepository>((ref) =>
        ReservationRepositoryImpl(ref.read(reservationDatasourceProvider)));

final getReservationsUsecaseProvider = Provider((ref) =>
    GetReservationsUsecase(ref.read(reservationRepositoryProvider)));

final getReservationByIdUsecaseProvider = Provider((ref) =>
    GetReservationByIdUsecase(ref.read(reservationRepositoryProvider)));

final approveReservationUsecaseProvider = Provider((ref) =>
    ApproveReservationUsecase(ref.read(reservationRepositoryProvider)));

final rejectReservationUsecaseProvider = Provider((ref) =>
    RejectReservationUsecase(ref.read(reservationRepositoryProvider)));

final verifyPaymentUsecaseProvider = Provider((ref) =>
    VerifyPaymentUsecase(ref.read(reservationRepositoryProvider)));

// ── State ───────────────────────────────────────────────
class ReservationListState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? errorMessage;
  final ReservationFilters filters;
  final int total;
  final int currentPage;
  final int lastPage;

  const ReservationListState({
    this.reservations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filters = const ReservationFilters(),
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasNextPage => currentPage < lastPage;
  int get pendingCount => reservations.where((r) => r.isPending).length;

  ReservationListState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? errorMessage,
    ReservationFilters? filters,
    int? total,
    int? currentPage,
    int? lastPage,
  }) =>
      ReservationListState(
        reservations: reservations ?? this.reservations,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,          // null autorisé pour reset
        filters: filters ?? this.filters,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
      );
}

// ── Notifier ─────────────────────────────────────────────
final reservationListProvider =
    NotifierProvider<ReservationListNotifier, ReservationListState>(
      ReservationListNotifier.new,           // ✅ Riverpod 3.x
    );

class ReservationListNotifier extends Notifier<ReservationListState> {
  // ✅ Plus de constructeur avec paramètres — on lit via ref dans build()
  late final GetReservationsUsecase _getReservations;
  late final ApproveReservationUsecase _approve;
  late final RejectReservationUsecase _reject;
  late final VerifyPaymentUsecase _verifyPayment;

  @override
  ReservationListState build() {
    // Injection ici
    _getReservations = ref.read(getReservationsUsecaseProvider);
    _approve = ref.read(approveReservationUsecaseProvider);
    _reject = ref.read(rejectReservationUsecaseProvider);
    _verifyPayment = ref.read(verifyPaymentUsecaseProvider);
    return const ReservationListState();    // état initial
  }

  Future<void> loadReservations({ReservationFilters? filters}) async {
    final active = filters ?? state.filters;
    state = state.copyWith(isLoading: true, filters: active);

    final result = await _getReservations(
      filters: ReservationFilters(
        search: active.search,
        status: active.status,
        fromDate: active.fromDate,
        toDate: active.toDate,
        perPage: active.perPage ?? 15,
        page: 1,
      ),
    );

    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(
        reservations: p.reservations,
        isLoading: false,
        total: p.total,
        currentPage: p.currentPage,
        lastPage: p.lastPage,
      ),
    );
  }

  Future<void> refresh() => loadReservations(filters: state.filters);
  Future<void> applyFilters(ReservationFilters f) =>
      loadReservations(filters: f);

  Future<bool> approveReservation(int id) async {
    final result = await _approve(id);
    return result.fold(
      (_) => false,
      (updated) {
        _updateInList(updated);
        return true;
      },
    );
  }

  Future<bool> rejectReservation(int id, {String? reason}) async {
    final result = await _reject(id, reason: reason);
    return result.fold(
      (_) => false,
      (updated) {
        _updateInList(updated);
        return true;
      },
    );
  }

  Future<bool> verifyPayment(int paymentId) async {
    final result = await _verifyPayment(paymentId);
    return result.fold(
      (_) => false,
      (updated) {
        _updateInList(updated);
        return true;
      },
    );
  }

  void _updateInList(Reservation updated) {
    state = state.copyWith(
      reservations: state.reservations
          .map((r) => r.id == updated.id ? updated : r)
          .toList(),
    );
  }
}

// ── Détail ───────────────────────────────────────────────
final reservationDetailProvider =
    FutureProvider.family<Reservation?, int>((ref, id) async {
  final usecase = ref.read(getReservationByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});
