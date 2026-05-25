library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../domain/entities/client_profile.dart';

// ── Injection ───────────────────────────────────────────
final clientDatasourceProvider = Provider(
    (ref) => ClientRemoteDatasource(client: ref.read(dioClientProvider)));

// ── State ───────────────────────────────────────────────
class ClientListState {
  final List<ClientProfile> clients;
  final bool isLoading;
  final String? errorMessage;
  final String? search;
  final int total, currentPage, lastPage;

  const ClientListState({
    this.clients = const [],
    this.isLoading = false,
    this.errorMessage,
    this.search,
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasNextPage => currentPage < lastPage;

  ClientListState copyWith({
    List<ClientProfile>? clients,
    bool? isLoading,
    String? errorMessage,
    String? search,
    int? total,
    int? currentPage,
    int? lastPage,
  }) =>
      ClientListState(
        clients: clients ?? this.clients,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,          // null remet à zéro l'erreur ✅
        search: search ?? this.search,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
      );
}

// ── Provider ─────────────────────────────────────────────
final clientListProvider =
    NotifierProvider<ClientListNotifier, ClientListState>(
        ClientListNotifier.new);

class ClientListNotifier extends Notifier<ClientListState> {
  // ref est disponible directement, plus besoin de l'injecter
  ClientRemoteDatasource get _datasource =>
      ref.read(clientDatasourceProvider);

  @override
  ClientListState build() => const ClientListState(); // remplace super(...)

  Future<void> loadClients({String? search}) async {
    state = state.copyWith(isLoading: true, search: search);
    try {
      final params = <String, dynamic>{'per_page': 15, 'page': 1};
      if (search?.isNotEmpty == true) params['search'] = search;
      final result = await _datasource.getClients(params: params);
      state = state.copyWith(
        clients: result.clients,
        isLoading: false,
        total: result.total,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => loadClients(search: state.search);
}

// ── Détail client ────────────────────────────────────────
final clientDetailProvider =
    FutureProvider.family<ClientProfile?, int>((ref, id) async {
  final ds = ref.read(clientDatasourceProvider);
  return ds.getClientById(id);
});