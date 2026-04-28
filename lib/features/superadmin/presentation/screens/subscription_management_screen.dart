import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ─── Models ────────────────────────────────────────────────────────────────

enum SubscriptionStatus { active, expired, cancelled }

enum PlanType { free, pro, premium }

class SubscriptionItem {
  final int id;
  final String clientName;
  final String clientEmail;
  final PlanType plan;
  final SubscriptionStatus status;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final int? daysUntilRenewal;

  const SubscriptionItem({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.plan,
    required this.status,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.daysUntilRenewal,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PlanType? _selectedPlan; // null = All Plans

  final List<SubscriptionItem> _subscriptions = [
    SubscriptionItem(
      id: 42,
      clientName: 'Ahmed Benali',
      clientEmail: 'a.benali@company.ma',
      plan: PlanType.pro,
      status: SubscriptionStatus.active,
      amount: 99.00,
      currency: 'MAD',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 5, 1),
    ),
    SubscriptionItem(
      id: 43,
      clientName: 'Fatima Zahra',
      clientEmail: 'f.zahra@global.com',
      plan: PlanType.premium,
      status: SubscriptionStatus.active,
      amount: 199.00,
      currency: 'MAD',
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 4, 30),
      daysUntilRenewal: 3,
    ),
    SubscriptionItem(
      id: 44,
      clientName: 'Youssef Tazi',
      clientEmail: 'y.tazi@freemail.com',
      plan: PlanType.free,
      status: SubscriptionStatus.active,
      amount: 0.00,
      currency: 'MAD',
      startDate: DateTime(2026, 4, 10),
      endDate: DateTime(2026, 5, 10),
    ),
    SubscriptionItem(
      id: 45,
      clientName: 'Karim Idrissi',
      clientEmail: 'k.idrissi@tech.ma',
      plan: PlanType.pro,
      status: SubscriptionStatus.expired,
      amount: 99.00,
      currency: 'MAD',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 4, 1),
    ),
    SubscriptionItem(
      id: 46,
      clientName: 'Nadia Alaoui',
      clientEmail: 'n.alaoui@design.com',
      plan: PlanType.premium,
      status: SubscriptionStatus.cancelled,
      amount: 199.00,
      currency: 'MAD',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 3, 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Stats
  int get _total => _subscriptions.length;
  int get _active =>
      _subscriptions.where((s) => s.status == SubscriptionStatus.active).length;
  int get _expired =>
      _subscriptions.where((s) => s.status == SubscriptionStatus.expired).length;
  int get _cancelled =>
      _subscriptions.where((s) => s.status == SubscriptionStatus.cancelled).length;
  double get _totalRevenue =>
      _subscriptions.fold(0, (sum, s) => sum + s.amount);

  List<SubscriptionItem> get _filtered {
    final tabIndex = _tabController.index;
    List<SubscriptionItem> list = _subscriptions;

    // Tab filter
    if (tabIndex == 1) {
      list = list.where((s) => s.status == SubscriptionStatus.active).toList();
    } else if (tabIndex == 2) {
      list = list.where((s) => s.status == SubscriptionStatus.expired).toList();
    } else if (tabIndex == 3) {
      list = list.where((s) => s.status == SubscriptionStatus.cancelled).toList();
    }

    // Plan filter
    if (_selectedPlan != null) {
      list = list.where((s) => s.plan == _selectedPlan).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: const Text(
          'Subscription\nManagement',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              child: const Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Revenue Banner
          _RevenueCard(totalRevenue: _totalRevenue),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outline,
                    iconColor: AppColors.primaryLight,
                    value: _total.toString(),
                    label: 'TOTAL',
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    value: _active.toString(),
                    label: 'ACTIVE',
                    valueColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer_off_outlined,
                    iconColor: AppColors.textSecondary,
                    value: _expired.toString(),
                    label: 'EXPIRED',
                    valueColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel_outlined,
                    iconColor: AppColors.error,
                    value: _cancelled.toString(),
                    label: 'CANCELLED',
                    valueColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Expired'),
              Tab(text: 'Cancelled'),
            ],
          ),

          // Plan Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _PlanChip(
                  label: 'All Plans',
                  selected: _selectedPlan == null,
                  color: AppColors.textSecondary,
                  onTap: () => setState(() => _selectedPlan = null),
                ),
                const SizedBox(width: 8),
                _PlanChip(
                  label: 'Free',
                  selected: _selectedPlan == PlanType.free,
                  color: AppColors.textSecondary,
                  onTap: () => setState(() => _selectedPlan = PlanType.free),
                ),
                const SizedBox(width: 8),
                _PlanChip(
                  label: 'Pro',
                  selected: _selectedPlan == PlanType.pro,
                  color: AppColors.primary,
                  onTap: () => setState(() => _selectedPlan = PlanType.pro),
                ),
                const SizedBox(width: 8),
                _PlanChip(
                  label: 'Premium',
                  selected: _selectedPlan == PlanType.premium,
                  color: AppColors.warning,
                  onTap: () => setState(() => _selectedPlan = PlanType.premium),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                return _SubscriptionCard(
                  item: _filtered[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/superadmin/subscription-detail',
                    arguments: _filtered[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/superadmin/assign-plan',
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Assign Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Revenue Card ──────────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final double totalRevenue;
  const _RevenueCard({required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL REVENUE',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${totalRevenue.toStringAsFixed(2)}\nMAD',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(label, style: AppTextStyles.labelUppercase),
        ],
      ),
    );
  }
}

// ─── Plan Chip ─────────────────────────────────────────────────────────────

class _PlanChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PlanChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            if (label != 'All Plans') ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subscription Card ─────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionItem item;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.item, required this.onTap});

  Color get _statusColor {
    switch (item.status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get _planColor {
    switch (item.plan) {
      case PlanType.free:
        return AppColors.textSecondary;
      case PlanType.pro:
        return AppColors.primary;
      case PlanType.premium:
        return AppColors.warning;
    }
  }

  String get _planLabel {
    switch (item.plan) {
      case PlanType.free:
        return 'FREE';
      case PlanType.pro:
        return 'PRO';
      case PlanType.premium:
        return 'PREMIUM';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final hasRenewalAlert = item.daysUntilRenewal != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: hasRenewalAlert
              ? Border.all(color: AppColors.warning, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Plan badge
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _planColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _planLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _planColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Client info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.clientName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.clientEmail,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}, ${item.endDate.year}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),

                  // Status + Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: item.status == SubscriptionStatus.cancelled
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        item.currency,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item.status == SubscriptionStatus.cancelled
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Renewal alert banner
            if (hasRenewalAlert)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSizes.radiusLG),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.daysUntilRenewal} days left until renewal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}