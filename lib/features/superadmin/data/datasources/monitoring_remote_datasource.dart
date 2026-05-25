library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ActivityLogItem {
  final int id;
  final String action;
  final String? entityType;
  final String? actorName;
  final String? ipAddress;
  final DateTime performedAt;

  const ActivityLogItem({
    required this.id,
    required this.action,
    this.entityType,
    this.actorName,
    this.ipAddress,
    required this.performedAt,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> j) => ActivityLogItem(
        id: j['id'] as int,
        action: j['action'] as String,
        entityType: j['entity_type'] as String?,
        actorName: (j['user'] as Map<String, dynamic>?)?['name'] as String?,
        ipAddress: j['ip'] as String?,
        performedAt: DateTime.parse(
            j['performed_at']?.toString() ??
            j['created_at']?.toString() ??
            DateTime.now().toIso8601String()),
      );
}

class MonitoringRemoteDatasource {
  final DioClient _client;
  const MonitoringRemoteDatasource({required DioClient client})
      : _client = client;

  // Retourne logs + total
  Future<Map<String, dynamic>> getActivityLogs({
    String? action,
    String? from,
    String? to,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{'per_page': perPage};
    if (action != null) params['action'] = action;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await _client.get(
      ApiConstants.activityLogs,
      queryParameters: params,
    );

    final data = response.data['data'];
    final List rawLogs = data is List
        ? data
        : (data['logs'] ?? data['data'] ?? []) as List;
    final int total =
        (data['pagination']?['total'] as num?)?.toInt() ?? rawLogs.length;

    return {
      'logs': rawLogs.map((e) => ActivityLogItem.fromJson(e)).toList(),
      'total': total,
    };
  }

  Future<Map<String, dynamic>> getLoginStats() async {
    final response = await _client.get(ApiConstants.loginStats);
    return response.data['data'] as Map<String, dynamic>;
  }
}