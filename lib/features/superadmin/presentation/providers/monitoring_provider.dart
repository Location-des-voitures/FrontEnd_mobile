library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/monitoring_remote_datasource.dart';

// ── Injection ────────────────────────────────────────────
final monitoringDatasourceProvider = Provider((ref) =>
    MonitoringRemoteDatasource(client: ref.read(dioClientProvider)));

// ── State ────────────────────────────────────────────────
class MonitoringState {
  final List<ActivityLogItem> logs;
  final bool isLoading;
  final String? errorMessage;
  final int totalEvents;
  final int todayEvents;

  const MonitoringState({
    this.logs = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalEvents = 0,
    this.todayEvents = 0,
  });

  MonitoringState copyWith({
    List<ActivityLogItem>? logs,
    bool? isLoading,
    String? errorMessage,
    int? totalEvents,
    int? todayEvents,
  }) =>
      MonitoringState(
        logs: logs ?? this.logs,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage, // null remet à zéro
        totalEvents: totalEvents ?? this.totalEvents,
        todayEvents: todayEvents ?? this.todayEvents,
      );
}

// ── Notifier ─────────────────────────────────────────────
// ✅ Migré de StateNotifierProvider (legacy) vers NotifierProvider (API actuelle)
// ✅ Suppression de l'import 'package:flutter_riverpod/legacy.dart'
final monitoringProvider =
    NotifierProvider<MonitoringNotifier, MonitoringState>(
  MonitoringNotifier.new,
);

class MonitoringNotifier extends Notifier<MonitoringState> {
  // ✅ Pas de constructeur avec paramètres — injection via ref dans build()
  @override
  MonitoringState build() {
    return const MonitoringState();
  }

  Future<void> load({String? action, String? from, String? to}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final datasource = ref.read(monitoringDatasourceProvider);

      final results = await Future.wait([
        datasource.getActivityLogs(action: action, from: from, to: to),
        datasource.getLoginStats(),
      ]);

      final result = results[0] as Map<String, dynamic>;
      final logs = result['logs'] as List<ActivityLogItem>;
      final total = result['total'] as int;

      final stats = results[1] as Map<String, dynamic>;
      final todayTotal =
          (stats['today'] as Map<String, dynamic>?)?['total'] as int? ?? 0;

      state = state.copyWith(
        logs: logs,
        isLoading: false,
        totalEvents: total,
        todayEvents: todayTotal,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> applyFilter(String? action) => load(action: action);
}