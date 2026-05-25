import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/monitoring_provider.dart';

// ─── Models ────────────────────────────────────────────────────────────────

enum LogEventType {
  userCreated,
  userDeleted,
  userActivated,
  adminCreated,
  adminSuspended,
  subscriptionCreated,
  subscriptionRenewed,
  subscriptionCancelled,
}

enum LogCategory { all, users, admins, subscriptions }

class LogEvent {
  final String id;
  final LogEventType type;
  final String message;
  final String actor;
  final String? actorAvatarUrl;
  final String ipAddress;
  final DateTime timestamp;
  final bool isFlagged;

  const LogEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.actor,
    this.actorAvatarUrl,
    required this.ipAddress,
    required this.timestamp,
    this.isFlagged = false,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────

class SystemLogScreen extends ConsumerStatefulWidget {
  const SystemLogScreen({super.key});

  @override
  ConsumerState<SystemLogScreen> createState() => _SystemLogScreenState();
}

class _SystemLogScreenState extends ConsumerState<SystemLogScreen> {
  LogCategory _selectedCategory = LogCategory.all;
  DateTime _fromDate = DateTime(2023, 10, 12);
  DateTime _toDate = DateTime(2023, 10, 24);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monitoringProvider.notifier).load();
    });
  }

  // Tag label + color per event type
  String _tagLabel(LogEventType type) {
    switch (type) {
      case LogEventType.userCreated:
        return 'user.created';
      case LogEventType.userDeleted:
        return 'user.deleted';
      case LogEventType.userActivated:
        return 'user.activated';
      case LogEventType.adminCreated:
        return 'admin.created';
      case LogEventType.adminSuspended:
        return 'admin.suspended';
      case LogEventType.subscriptionCreated:
        return 'subscription.created';
      case LogEventType.subscriptionRenewed:
        return 'subscription.renewed';
      case LogEventType.subscriptionCancelled:
        return 'subscription.cancelled';
    }
  }

  Color _tagColor(LogEventType type) {
    switch (type) {
      case LogEventType.userCreated:
        return AppColors.success;
      case LogEventType.userDeleted:
        return AppColors.error;
      case LogEventType.userActivated:
        return AppColors.primary;
      case LogEventType.adminCreated:
        return AppColors.primary;
      case LogEventType.adminSuspended:
        return AppColors.warning;
      case LogEventType.subscriptionCreated:
        return AppColors.success;
      case LogEventType.subscriptionRenewed:
        return AppColors.warning;
      case LogEventType.subscriptionCancelled:
        return AppColors.error;
    }
  }

  Color _dotColor(LogEventType type) {
    switch (type) {
      case LogEventType.userCreated:
        return AppColors.success;
      case LogEventType.userDeleted:
        return AppColors.error;
      case LogEventType.userActivated:
        return AppColors.primary;
      case LogEventType.adminCreated:
        return AppColors.primary;
      case LogEventType.adminSuspended:
        return AppColors.error;
      case LogEventType.subscriptionCreated:
        return AppColors.success;
      case LogEventType.subscriptionRenewed:
        return AppColors.error;
      case LogEventType.subscriptionCancelled:
        return AppColors.error;
    }
  }

  LogEventType _actionToType(String action) {
    switch (action) {
      case 'user.created':           return LogEventType.userCreated;
      case 'user.deleted':           return LogEventType.userDeleted;
      case 'user.activated':
      case 'user.deactivated':       return LogEventType.userActivated;
      case 'admin.created':          return LogEventType.adminCreated;
      case 'admin.suspended':        return LogEventType.adminSuspended;
      case 'subscription.created':   return LogEventType.subscriptionCreated;
      case 'subscription.renewed':   return LogEventType.subscriptionRenewed;
      case 'subscription.cancelled': return LogEventType.subscriptionCancelled;
      default:                       return LogEventType.userCreated;
    }
  }

  bool _matchesCategory(LogEvent e) {
    switch (_selectedCategory) {
      case LogCategory.all:
        return true;
      case LogCategory.users:
        return [
          LogEventType.userCreated,
          LogEventType.userDeleted,
          LogEventType.userActivated,
        ].contains(e.type);
      case LogCategory.admins:
        return [
          LogEventType.adminCreated,
          LogEventType.adminSuspended,
        ].contains(e.type);
      case LogCategory.subscriptions:
        return [
          LogEventType.subscriptionCreated,
          LogEventType.subscriptionRenewed,
          LogEventType.subscriptionCancelled,
        ].contains(e.type);
    }
  }

  List<LogEvent> get _filtered {
    final monState = ref.read(monitoringProvider);
    return monState.logs
        .map((item) => LogEvent(
              id: item.id.toString(),
              type: _actionToType(item.action),
              message: item.action,
              actor: item.actorName ?? 'System',
              ipAddress: item.ipAddress ?? '—',
              timestamp: item.performedAt,
            ))
        .where(_matchesCategory)
        .toList();
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
       ref.read(monitoringProvider.notifier).load(
      from: '${_fromDate.year}-${_fromDate.month.toString().padLeft(2,'0')}-${_fromDate.day.toString().padLeft(2,'0')}',
      to: '${_toDate.year}-${_toDate.month.toString().padLeft(2,'0')}-${_toDate.day.toString().padLeft(2,'0')}',
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monState = ref.watch(monitoringProvider);
    final filtered = monState.isLoading ? <LogEvent>[] : _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'ACTIVITY RECORDER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => ref.read(monitoringProvider.notifier).load(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: monState.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    icon: Icons.grid_view,
                    label: 'All Events',
                    selected: _selectedCategory == LogCategory.all,
                    onTap: () {
                      setState(() => _selectedCategory = LogCategory.all);
                      ref.read(monitoringProvider.notifier).applyFilter(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    icon: Icons.person_outline,
                    label: 'Users',
                    selected: _selectedCategory == LogCategory.users,
                    onTap: () {
                      setState(() => _selectedCategory = LogCategory.users);
                      ref.read(monitoringProvider.notifier).applyFilter('user.created');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    icon: Icons.shield_outlined,
                    label: 'Admins',
                    selected: _selectedCategory == LogCategory.admins,
                    onTap: () {
                      setState(() => _selectedCategory = LogCategory.admins);
                      ref.read(monitoringProvider.notifier).applyFilter('admin.created');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    icon: Icons.credit_card_outlined,
                    label: '',
                    selected: _selectedCategory == LogCategory.subscriptions,
                    onTap: () {
                      setState(() => _selectedCategory = LogCategory.subscriptions);
                      ref.read(monitoringProvider.notifier).applyFilter('subscription.created');
                    },
                    iconOnly: true,
                  ),
                ],
              ),
            ),
          ),

          // Date range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'FROM',
                    date: _formatDate(_fromDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward,
                      color: AppColors.textSecondary, size: 18),
                ),
                Expanded(
                  child: _DateButton(
                    label: 'TO',
                    date: _formatDate(_toDate),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
          ),

          // Stats banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${monState.totalEvents} total events recorded',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    'Today: ${monState.todayEvents} events',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: monState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : monState.errorMessage != null
                    ? Center(
                        child: Text(
                          monState.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return _LoadMoreButton(onTap: () {});
                          }
                          return _LogEventCard(
                            event: filtered[index],
                            tagLabel: _tagLabel(filtered[index].type),
                            tagColor: _tagColor(filtered[index].type),
                            dotColor: _dotColor(filtered[index].type),
                            relativeTime: _relativeTime(filtered[index].timestamp),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ─────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool iconOnly;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? 14 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            if (!iconOnly && label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Date Button ───────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelUppercase),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                date,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Log Event Card ────────────────────────────────────────────────────────

class _LogEventCard extends StatelessWidget {
  final LogEvent event;
  final String tagLabel;
  final Color tagColor;
  final Color dotColor;
  final String relativeTime;

  const _LogEventCard({
    required this.event,
    required this.tagLabel,
    required this.tagColor,
    required this.dotColor,
    required this.relativeTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border(
          left: BorderSide(color: tagColor, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  relativeTime,
                  style: AppTextStyles.caption,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              event.message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      size: 13, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  event.actor,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  event.ipAddress,
                  style: AppTextStyles.caption,
                ),
                if (event.isFlagged) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppColors.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Load More Button ──────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Load Older Records',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textPrimary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}