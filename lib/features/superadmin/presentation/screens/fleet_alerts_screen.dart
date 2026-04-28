import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ─── Models ────────────────────────────────────────────────────────────────

enum AlertSeverity { critical, warning, info }

class FleetAlert {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String timeAgo;
  final String actionLabel;
  final String actionRoute;
  final IconData icon;
  final bool isUnread;

  const FleetAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.actionLabel,
    required this.actionRoute,
    required this.icon,
    this.isUnread = false,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────

class FleetAlertsScreen extends StatelessWidget {
  const FleetAlertsScreen({super.key});

  static const List<FleetAlert> _alerts = [
    // Critical
    FleetAlert(
      id: '1',
      severity: AlertSeverity.critical,
      title: 'Brute Force Detected',
      description: '10+ failed login attempts from IP 196.206.10.5',
      timeAgo: '15 MIN AGO',
      actionLabel: 'View Login Logs',
      actionRoute: '/superadmin/system-log',
      icon: Icons.security,
      isUnread: true,
    ),
    FleetAlert(
      id: '2',
      severity: AlertSeverity.critical,
      title: 'Fleet Plan Expiring',
      description: "Ahmed Benali's Pro plan expires in 2 days",
      timeAgo: '',
      actionLabel: 'Manage Subscription',
      actionRoute: '/superadmin/subscriptions',
      icon: Icons.alarm,
    ),
    // Warning
    FleetAlert(
      id: '3',
      severity: AlertSeverity.warning,
      title: 'Overdue Subscriptions',
      description: '3 fleet subscriptions have passed their end date',
      timeAgo: '',
      actionLabel: 'Review Subscriptions',
      actionRoute: '/superadmin/subscriptions',
      icon: Icons.calendar_today_outlined,
    ),
    // Info
    FleetAlert(
      id: '4',
      severity: AlertSeverity.info,
      title: 'Inactive Fleet Users',
      description: '5 client accounts are currently deactivated',
      timeAgo: '',
      actionLabel: 'View Inactive Users',
      actionRoute: '/superadmin/users',
      icon: Icons.person_off_outlined,
    ),
  ];

  int get _criticalCount =>
      _alerts.where((a) => a.severity == AlertSeverity.critical).length;
  int get _warningCount =>
      _alerts.where((a) => a.severity == AlertSeverity.warning).length;
  int get _infoCount =>
      _alerts.where((a) => a.severity == AlertSeverity.info).length;

  List<FleetAlert> _byType(AlertSeverity s) =>
      _alerts.where((a) => a.severity == s).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          _GradientHeader(unreadCount: _alerts.where((a) => a.isUnread).length),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row
                  _SummaryRow(
                    criticalCount: _criticalCount,
                    warningCount: _warningCount,
                    infoCount: _infoCount,
                  ),

                  const SizedBox(height: 20),

                  // Critical section
                  if (_byType(AlertSeverity.critical).isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.warning_amber_rounded,
                      label: 'CRITICAL ALERTS',
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 10),
                    ..._byType(AlertSeverity.critical).map(
                      (a) => _AlertCard(alert: a),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Warnings section
                  if (_byType(AlertSeverity.warning).isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.error_outline,
                      label: 'WARNINGS',
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 10),
                    ..._byType(AlertSeverity.warning).map(
                      (a) => _AlertCard(alert: a),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info section
                  if (_byType(AlertSeverity.info).isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.info_outline,
                      label: 'INFORMATION',
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 10),
                    ..._byType(AlertSeverity.info).map(
                      (a) => _AlertCard(alert: a),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ─── Gradient Header ───────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final int unreadCount;
  const _GradientHeader({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB71C1C), // deep red
            Color(0xFF3B1E8E), // deep indigo
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Fleet Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 26),
                  if (unreadCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Row ───────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final int criticalCount;
  final int warningCount;
  final int infoCount;

  const _SummaryRow({
    required this.criticalCount,
    required this.warningCount,
    required this.infoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryCell(
                count: criticalCount,
                label: 'CRITICAL',
                dotColor: AppColors.error,
              ),
            ),
            VerticalDivider(
              width: 1,
              color: AppColors.divider,
              indent: 14,
              endIndent: 14,
            ),
            Expanded(
              child: _SummaryCell(
                count: warningCount,
                label: 'WARNING',
                dotColor: AppColors.warning,
              ),
            ),
            VerticalDivider(
              width: 1,
              color: AppColors.divider,
              indent: 14,
              endIndent: 14,
            ),
            Expanded(
              child: _SummaryCell(
                count: infoCount,
                label: 'INFO',
                dotColor: AppColors.info,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final int count;
  final String label;
  final Color dotColor;

  const _SummaryCell({
    required this.count,
    required this.label,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: dotColor,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Alert Card ────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final FleetAlert alert;

  const _AlertCard({required this.alert});

  Color get _borderColor {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  Color get _iconBg {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppColors.error.withOpacity(0.1);
      case AlertSeverity.warning:
        return AppColors.warning.withOpacity(0.1);
      case AlertSeverity.info:
        return AppColors.info.withOpacity(0.1);
    }
  }

  Color get _iconColor {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border(
          left: BorderSide(color: _borderColor, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(alert.icon, color: _iconColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (alert.isUnread)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Time + action button
            Row(
              mainAxisAlignment: alert.timeAgo.isNotEmpty
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (alert.timeAgo.isNotEmpty)
                  Text(
                    alert.timeAgo,
                    style: AppTextStyles.labelUppercase.copyWith(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, alert.actionRoute),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(alert.actionLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Nav ────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.directions_car_outlined, label: 'FLEET', active: false),
              _NavItem(icon: Icons.map_outlined, label: 'MAP', active: false),
              _NavItem(icon: Icons.notifications_outlined, label: 'ALERTS', active: true),
              _NavItem(icon: Icons.person_outline, label: 'PROFILE', active: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Icon(
            icon,
            size: 22,
            color: active ? AppColors.primary : AppColors.textHint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textHint,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}