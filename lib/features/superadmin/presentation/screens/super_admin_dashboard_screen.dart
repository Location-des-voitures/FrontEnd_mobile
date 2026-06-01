/// -------------------------------------------------------
/// SUPER ADMIN DASHBOARD — version interactive
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/providers/core_providers.dart';
import 'user_list_screen.dart';
import 'loueur_list_screen.dart';
import 'subscription_management_screen.dart';
import 'system_log_screen.dart';
import 'fleet_alerts_screen.dart';

// ── Providers ─────────────────────────────────────────────
final _dashboardKpisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response =
      await ref.read(dioClientProvider).get(ApiConstants.dashboardKpis);
  return response.data['data'] as Map<String, dynamic>;
});

final _dashboardChartsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final response =
      await ref.read(dioClientProvider).get(ApiConstants.dashboardCharts);
  return response.data['data'] as Map<String, dynamic>;
});

final _dashboardAlertsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final response =
      await ref.read(dioClientProvider).get(ApiConstants.dashboardAlerts);
  return response.data['data'] as Map<String, dynamic>;
});

// ══════════════════════════════════════════════════════════
// SUPER ADMIN DASHBOARD SCREEN
// ══════════════════════════════════════════════════════════

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardBody(),
    UsersListScreen(),
    LoueurListScreen(),
    SubscriptionManagementScreen(),
    SystemLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.dashboard_outlined,      Icons.dashboard_rounded,      'Dashboard'),
      (Icons.people_outline,          Icons.people_alt_rounded,     'Users'),
      (Icons.directions_car_outlined, Icons.directions_car_rounded, 'Admins'),
      (Icons.credit_card_outlined,    Icons.credit_card_rounded,    'Plans'),
      (Icons.receipt_long_outlined,   Icons.receipt_long_rounded,   'Logs'),
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = _currentIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? items[i].$2 : items[i].$1,
                    size: 24,
                    color: isActive
                        ? const Color(0xFF3B5BDB)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$3,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.3,
                      color: isActive
                          ? const Color(0xFF3B5BDB)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 4 : 0,
                    height: isActive ? 4 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B5BDB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// DASHBOARD BODY
// ══════════════════════════════════════════════════════════

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync   = ref.watch(_dashboardKpisProvider);
    final chartsAsync = ref.watch(_dashboardChartsProvider);
    final alertsAsync = ref.watch(_dashboardAlertsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            _buildHeader(context),

            // ── Loading / error bar ──────────────────────
            if (kpisAsync.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            if (kpisAsync.hasError)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Dashboard API error: ${kpisAsync.error}',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: const Color(0xFFEF4444)),
                ),
              ),

            const SizedBox(height: 24),

            // ── Welcome ──────────────────────────────────
            _buildWelcome(kpisAsync.value),
            const SizedBox(height: 24),

            // ── Stat Cards ───────────────────────────────
            _buildStatCards(context, kpisAsync.value, alertsAsync.value),
            const SizedBox(height: 32),

            // ── User Growth Chart ────────────────────────
            _buildUserGrowthSection(chartsAsync.value),
            const SizedBox(height: 32),

            // ── Loueurs Overview ─────────────────────────
            _buildLoueursOverview(kpisAsync.value),
            const SizedBox(height: 32),

            // ── Recent Activity ──────────────────────────
            _buildRecentActivity(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.1),
            ),
            child:
                const Icon(Icons.person, color: Color(0xFF3B5BDB), size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E))),
              Text('SUPER ADMIN CONTROL',
                  style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: const Color(0xFF6B7280))),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/superadmin/alerts'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.notifications_outlined,
                        color: Color(0xFF1A1A2E), size: 20),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('FlotTrack',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  // ── Welcome ─────────────────────────────────────────────
  Widget _buildWelcome(Map<String, dynamic>? kpis) {
    final users      = _section(kpis, 'users');
    final totalUsers = _intValue(users['total']);
    final activeUsers = _intValue(users['active']);
    final admins     = _intValue(users['admins']);
    final health = totalUsers == 0
        ? 0.0
        : (activeUsers / totalUsers * 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Super\nAdmin.',
            style: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
                height: 1.15),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Platform health at ',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                  height: 1.5),
              children: [
                TextSpan(
                  text: '${health.toStringAsFixed(1)}%',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B5BDB)),
                ),
                TextSpan(
                  text: ' — $admins loueurs active\nacross the network.',
                  style:
                      GoogleFonts.outfit(color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ───────────────────────────────────────────
  Widget _buildStatCards(
    BuildContext context,
    Map<String, dynamic>? kpis,
    Map<String, dynamic>? alertsData,
  ) {
    final users         = _section(kpis, 'users');
    final subscriptions = _section(kpis, 'subscriptions');
    final admins        = _intValue(users['admins']);
    final clients       = _intValue(users['clients']);
    final newThisMonth  = _intValue(users['new_this_month']);
    final newToday      = _intValue(users['new_today']);
    final expiringSoon  = _intValue(subscriptions['expiring_soon']);

    // Alerts depuis l'endpoint /admin/dashboard/alerts
    final criticalCount = _intValue(alertsData?['critical_count']);
    final warningCount  = _intValue(alertsData?['warning_count']);
    final totalAlerts   = criticalCount + warningCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              // Loueurs
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_car_outlined,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL LOUEURS',
                  value: '$admins',
                  change: '+$newThisMonth this month',
                  changeColor: const Color(0xFF3B5BDB),
                  onTap: () {
                    final state = context.findAncestorStateOfType<
                        _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 2);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Clients
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL CLIENTS',
                  value: _formatNumber(clients),
                  change: '+$newToday new today',
                  changeColor: const Color(0xFF3B5BDB),
                  onTap: () {
                    final state = context.findAncestorStateOfType<
                        _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Expiring soon
              Expanded(
                child: _StatCard(
                  icon: Icons.approval_outlined,
                  iconBgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF59E0B),
                  label: 'EXPIRING SOON',
                  value: '$expiringSoon',
                  change: 'subscriptions',
                  changeColor: const Color(0xFFF59E0B),
                  onTap: () {
                    final state = context.findAncestorStateOfType<
                        _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 3);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // ✅ ALERTS CARD — remplace Platform Usage
              Expanded(
                child: _AlertsCard(
                  totalAlerts: totalAlerts,
                  criticalCount: criticalCount,
                  warningCount: warningCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FleetAlertsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── User Growth ──────────────────────────────────────────
  Widget _buildUserGrowthSection(Map<String, dynamic>? charts) {
    final allSeries = _series(charts);
    final series    = allSeries.length > 7
        ? allSeries.sublist(allSeries.length - 7)
        : allSeries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Growth',
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E))),
                    Text('Last 30 days',
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: const Color(0xFF9CA3AF))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F1EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('MONTHLY',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color(0xFF6B7280))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 140, child: _buildBarChart(series)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: series
                  .map((item) => Text(
                        _dayLabel(item['date']),
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                            letterSpacing: 0.5),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> series) {
    if (series.isEmpty) {
      return Center(
        child: Text('No chart data',
            style: GoogleFonts.outfit(
                fontSize: 13, color: const Color(0xFF9CA3AF))),
      );
    }
    final values   = series.map((e) => _intValue(e['new_users'])).toList();
    final maxValue = values.fold<int>(0, (m, v) => v > m ? v : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(series.length, (i) {
        final value       = values[i];
        final height      = maxValue == 0 ? 0.0 : (value / maxValue) * 100;
        final highlighted = value == maxValue && maxValue > 0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (highlighted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('+$value users',
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? const Color(0xFF3B5BDB)
                        : const Color(0xFFE8E7E4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Loueurs Overview ─────────────────────────────────────
  Widget _buildLoueursOverview(Map<String, dynamic>? kpis) {
    // Utilise les données API si dispo, sinon mock
    final loueursSection = _section(kpis, 'top_admins');
    final List<Map<String, dynamic>> topAdmins =
        loueursSection.isNotEmpty && loueursSection['list'] is List
            ? (loueursSection['list'] as List)
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList()
            : [
                {'name': 'Ahmed Rentals',    'clients': 284, 'progress': 1.0},
                {'name': 'Casa Premium Cars', 'clients': 196, 'progress': 0.69},
                {'name': 'Atlas Auto',        'clients': 142, 'progress': 0.50},
              ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loueurs Overview',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 20),
          ...topAdmins.map((admin) {
            final name     = admin['name']?.toString() ?? '';
            final clients  = _intValue(admin['clients']);
            final progress = (admin['progress'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _loueurBar(name, clients, progress),
            );
          }),
        ],
      ),
    );
  }

  Widget _loueurBar(String name, int clients, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E))),
            Text('$clients clients',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B5BDB))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8E7E4),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF3B5BDB)),
          ),
        ),
      ],
    );
  }

  // ── Recent Activity ──────────────────────────────────────
  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
              GestureDetector(
                onTap: () {
                  final state = context.findAncestorStateOfType<
                      _SuperAdminDashboardScreenState>();
                  state?.setState(() => state._currentIndex = 4);
                },
                child: Text('VIEW ALL',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B5BDB),
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActivityItem(
            icon: Icons.person_add_outlined,
            iconBgColor: const Color(0xFFF0F2FF),
            iconColor: const Color(0xFF3B5BDB),
            title: 'New loueur created',
            subtitle: 'Sara Gestionnaire • joined 2h ago',
            badgeText: 'ACTIVE',
            badgeColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.block_outlined,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            title: 'Account deactivated',
            subtitle: 'Client #1182 • 5h ago',
            badgeText: 'INACTIVE',
            badgeColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.verified_outlined,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            title: 'Email verified',
            subtitle: 'Ahmed Loueur • yesterday',
            badgeText: 'VERIFIED',
            badgeColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  Map<String, dynamic> _section(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  List<Map<String, dynamic>> _series(Map<String, dynamic>? data) {
    final value = data?['series'];
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  String _dayLabel(dynamic date) {
    final parsed = DateTime.tryParse(date?.toString() ?? '');
    if (parsed == null) return '';
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[parsed.weekday - 1];
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }
}

// ══════════════════════════════════════════════════════════
// ALERTS CARD — remplace Platform Usage
// ══════════════════════════════════════════════════════════

class _AlertsCard extends StatelessWidget {
  final int totalAlerts;
  final int criticalCount;
  final int warningCount;
  final VoidCallback onTap;

  const _AlertsCard({
    required this.totalAlerts,
    required this.criticalCount,
    required this.warningCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCritical = criticalCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: hasCritical
              ? const Color(0xFFEF4444)
              : const Color(0xFFF59E0B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (hasCritical
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF59E0B))
                  .withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                // Badge "unread" dot
                if (criticalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$criticalCount CRITICAL',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'FLEET ALERTS',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalAlerts',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '$warningCount warnings',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SHARED SUB-WIDGETS
// ══════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String change;
  final Color changeColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.change,
    required this.changeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: const Color(0xFF9CA3AF))),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(change,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: changeColor),
                      overflow: TextOverflow.ellipsis),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios,
                      size: 10, color: changeColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;

  const _ActivityItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(badgeText,
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}