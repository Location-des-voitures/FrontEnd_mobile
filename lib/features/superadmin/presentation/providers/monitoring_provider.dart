library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/monitoring_remote_datasource.dart';
import 'package:flutter_riverpod/legacy.dart';

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
        errorMessage: errorMessage,
        totalEvents: totalEvents ?? this.totalEvents,
        todayEvents: todayEvents ?? this.todayEvents,
      );
}

// ── Provider ─────────────────────────────────────────────
final monitoringProvider =
    StateNotifierProvider<MonitoringNotifier, MonitoringState>((ref) {
  return MonitoringNotifier(ref.read(monitoringDatasourceProvider));
});

class MonitoringNotifier extends StateNotifier<MonitoringState> {
  final MonitoringRemoteDatasource _datasource;

  MonitoringNotifier(this._datasource) : super(const MonitoringState());

  Future<void> load({String? action, String? from, String? to}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _datasource.getActivityLogs(action: action, from: from, to: to),
        _datasource.getLoginStats(),
      ]);

      // ── FIX: getActivityLogs retourne maintenant Map, pas List
      final result = results[0] as Map<String, dynamic>;
      final logs = result['logs'] as List<ActivityLogItem>;
      final total = result['total'] as int;

      final stats = results[1] as Map<String, dynamic>;
      final todayTotal =
          (stats['today'] as Map<String, dynamic>?)?['total'] as int? ?? 0;

      state = state.copyWith(
        logs: logs,
        isLoading: false,
        totalEvents: total, // ← vrai total API
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