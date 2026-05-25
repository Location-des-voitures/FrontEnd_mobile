/// -------------------------------------------------------
/// SUBSCRIPTION MANAGEMENT SCREEN — Connecté aux vrais endpoints
/// -------------------------------------------------------
/// GET /api/admin/subscriptions/stats
/// GET /api/admin/subscriptions
/// PUT /api/admin/subscriptions/{id}/renew
/// PUT /api/admin/subscriptions/{id}/cancel
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/constants/api_constants.dart';

// ══════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════

enum SubscriptionStatus { active, expired, cancelled }
enum PlanType { free, pro, premium }

class SubscriptionItem {
  final int id;
  final String clientName;
  final String clientEmail;
  final PlanType plan;
  final String planLabel;
  final SubscriptionStatus status;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final int? daysRemaining;

  const SubscriptionItem({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.plan,
    required this.planLabel,
    required this.status,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.daysRemaining,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final planStr = json['plan']?.toString() ?? 'free';
    final statusStr = json['status']?.toString() ?? 'active';
    final days = (json['days_remaining'] as num?)?.toInt();

    return SubscriptionItem(
      id: (json['id'] as num).toInt(),
      clientName: user['name']?.toString() ?? '—',
      clientEmail: user['email']?.toString() ?? '—',
      plan: _parsePlan(planStr),
      planLabel: json['plan_label']?.toString() ?? planStr.toUpperCase(),
      status: _parseStatus(statusStr),
      amount: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'MAD',
      startDate: DateTime.tryParse(json['starts_at']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['ends_at']?.toString() ?? '') ??
          DateTime.now(),
      daysRemaining: days,
    );
  }

  static PlanType _parsePlan(String s) {
    switch (s) {
      case 'pro':
        return PlanType.pro;
      case 'premium':
        return PlanType.premium;
      default:
        return PlanType.free;
    }
  }

  static SubscriptionStatus _parseStatus(String s) {
    switch (s) {
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.active;
    }
  }
}

class SubscriptionStats {
  final int total;
  final int active;
  final int expired;
  final int cancelled;
  final int expiringSoon;
  final double totalRevenue;
  final int byFree;
  final int byPro;
  final int byPremium;

  const SubscriptionStats({
    this.total = 0,
    this.active = 0,
    this.expired = 0,
    this.cancelled = 0,
    this.expiringSoon = 0,
    this.totalRevenue = 0,
    this.byFree = 0,
    this.byPro = 0,
    this.byPremium = 0,
  });

  factory SubscriptionStats.fromJson(Map<String, dynamic> json) {
    final byPlan = json['by_plan'] as Map<String, dynamic>? ?? {};
    return SubscriptionStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      expiringSoon: (json['expiring_soon'] as num?)?.toInt() ?? 0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      byFree: (byPlan['free'] as num?)?.toInt() ?? 0,
      byPro: (byPlan['pro'] as num?)?.toInt() ?? 0,
      byPremium: (byPlan['premium'] as num?)?.toInt() ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════
// FILTER STATE
// ══════════════════════════════════════════════════════════

class SubFilter {
  final int tabIndex; // 0=all 1=active 2=expired 3=cancelled
  final PlanType? plan;
  final int page;

  const SubFilter({this.tabIndex = 0, this.plan, this.page = 1});

  SubFilter copyWith({int? tabIndex, PlanType? plan, bool clearPlan = false, int? page}) =>
      SubFilter(
        tabIndex: tabIndex ?? this.tabIndex,
        plan: clearPlan ? null : (plan ?? this.plan),
        page: page ?? this.page,
      );

  String? get statusParam {
    switch (tabIndex) {
      case 1: return 'active';
      case 2: return 'expired';
      case 3: return 'cancelled';
      default: return null;
    }
  }

  String? get planParam {
    switch (plan) {
      case PlanType.free: return 'free';
      case PlanType.pro: return 'pro';
      case PlanType.premium: return 'premium';
      default: return null;
    }
  }
}

class SubFilterNotifier extends Notifier<SubFilter> {
  @override
  SubFilter build() => const SubFilter();

  void update(SubFilter Function(SubFilter) fn) => state = fn(state);
}

final subFilterProvider =
    NotifierProvider<SubFilterNotifier, SubFilter>(SubFilterNotifier.new);

// ══════════════════════════════════════════════════════════
// PROVIDERS
// ══════════════════════════════════════════════════════════

// Stats — appelé en premier (avant /{id} selon la doc)
final subscriptionStatsProvider =
    FutureProvider.autoDispose<SubscriptionStats>((ref) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get(ApiConstants.subscriptionStats);
  final data = response.data['data'] as Map<String, dynamic>? ?? {};
  return SubscriptionStats.fromJson(data);
});

// Liste paginée
final subscriptionListProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final filter = ref.watch(subFilterProvider);
  final dio = ref.read(dioClientProvider);

  final params = <String, String>{
    'per_page': '20',
    'page': filter.page.toString(),
  };
  if (filter.statusParam != null) params['status'] = filter.statusParam!;
  if (filter.planParam != null) params['plan'] = filter.planParam!;

  final response = await dio.get(
    ApiConstants.subscriptions,
    queryParameters: params,
  );

  return response.data['data'] as Map<String, dynamic>;
});

// ══════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(subFilterProvider.notifier)
            .update((f) => f.copyWith(tabIndex: _tabController.index, page: 1));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(subscriptionStatsProvider);
    final listAsync = ref.watch(subscriptionListProvider);
    final filter = ref.watch(subFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Revenue Banner
          statsAsync.when(
            data: (s) => _RevenueCard(totalRevenue: s.totalRevenue),
            loading: () => _RevenueCard(totalRevenue: 0),
            error: (_, _) => _RevenueCard(totalRevenue: 0),
          ),

          // Stats Row
          statsAsync.when(
            data: (s) => _StatsGrid(stats: s),
            loading: () => const _StatsGridSkeleton(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Tab Bar
          TabBar(
            controller: _tabController,
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
          _PlanFilterRow(
            selected: filter.plan,
            onSelect: (plan) => ref
                .read(subFilterProvider.notifier)
                .update((f) => plan == null
                    ? f.copyWith(clearPlan: true, page: 1)
                    : f.copyWith(plan: plan, page: 1)),
          ),

          // List
          Expanded(
            child: listAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorState(
                message: err.toString(),
                onRetry: () {
                  ref.invalidate(subscriptionListProvider);
                  ref.invalidate(subscriptionStatsProvider);
                },
              ),
              data: (data) {
                final items = (data['subscriptions'] as List<dynamic>? ??
                        data['data'] as List<dynamic>? ??
                        [])
                    .map((e) => SubscriptionItem.fromJson(
                        e as Map<String, dynamic>))
                    .toList();

                final pagination =
                    data['pagination'] as Map<String, dynamic>? ?? {};
                final lastPage =
                    (pagination['last_page'] as num?)?.toInt() ?? 1;
                final hasMore = filter.page < lastPage;

                if (items.isEmpty) return const _EmptyState();

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(subscriptionListProvider);
                    ref.invalidate(subscriptionStatsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return _LoadMoreButton(
                          onTap: () => ref
                              .read(subFilterProvider.notifier)
                              .update((f) =>
                                  f.copyWith(page: f.page + 1)),
                        );
                      }
                      return _SubscriptionCard(
                        item: items[index],
                        onRenew: () =>
                            _showRenewDialog(context, items[index]),
                        onCancel: () =>
                            _showCancelConfirm(context, items[index]),
                        onTap: () {},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAssignPlanSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Assign Plan',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          onPressed: () {
            ref.invalidate(subscriptionListProvider);
            ref.invalidate(subscriptionStatsProvider);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            child: const Icon(Icons.person,
                size: 18, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ── Renew Dialog ────────────────────────────────────────
  void _showRenewDialog(BuildContext context, SubscriptionItem item) {
    PlanType selectedPlan = item.plan;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Renew Subscription',
                  style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text('Choose a plan for ${item.clientName}',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 20),
              // Plan selector
              Row(
                children: [PlanType.free, PlanType.pro, PlanType.premium]
                    .map((p) {
                  final isSelected = selectedPlan == p;
                  final label = p.name.toUpperCase();
                  final prices = {
                    PlanType.free: '0',
                    PlanType.pro: '99',
                    PlanType.premium: '199'
                  };
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedPlan = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                )),
                            Text('${prices[p]} MAD',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.textHint,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _renewSubscription(item.id, selectedPlan);
                      },
                      child: const Text('Confirm Renew'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cancel Confirm ──────────────────────────────────────
  void _showCancelConfirm(BuildContext context, SubscriptionItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined,
                  color: AppColors.error, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Cancel Subscription?', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'This will cancel ${item.clientName}\'s ${item.planLabel} plan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Keep'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _cancelSubscription(item.id);
                    },
                    child: const Text('Cancel Plan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _renewSubscription(int id, PlanType plan) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.put(
        '${ApiConstants.subscriptions}/$id/renew',
        data: {'plan': plan.name},
      );
      ref.invalidate(subscriptionListProvider);
      ref.invalidate(subscriptionStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription renewed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _cancelSubscription(int id) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.put('${ApiConstants.subscriptions}/$id/cancel');
      ref.invalidate(subscriptionListProvider);
      ref.invalidate(subscriptionStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Assign Plan Sheet ──────────────────────────────────
  void _showAssignPlanSheet(BuildContext context) {
    final emailCtrl = TextEditingController();
    PlanType selectedPlan = PlanType.pro;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Assign Plan', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('Assign a subscription to a client',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 20),
                // Email field
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'CLIENT EMAIL',
                    hintText: 'client@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                // Plan selector
                Text('SELECT PLAN',
                    style: AppTextStyles.labelUppercase),
                const SizedBox(height: 10),
                Row(
                  children: [
                    PlanType.free,
                    PlanType.pro,
                    PlanType.premium
                  ].map((p) {
                    final isSelected = selectedPlan == p;
                    final prices = {
                      PlanType.free: '0',
                      PlanType.pro: '99',
                      PlanType.premium: '199',
                    };
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedPlan = p),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                p.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${prices[p]} MAD',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (emailCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Please enter a client email'),
                              ));
                              return;
                            }
                            setModalState(
                                () => isLoading = true);
                            try {
                              final dio =
                                  ref.read(dioClientProvider);
                              // 1. Find user by email
                              final usersRes = await dio.get(
                                ApiConstants.users,
                                queryParameters: {
                                  'search': emailCtrl.text.trim(),
                                  'role': 'client',
                                },
                              );
                              final users = (usersRes
                                      .data['data']['users']
                                  as List<dynamic>?);
                              if (users == null || users.isEmpty) {
                                throw Exception(
                                    'No client found with this email');
                              }
                              final userId =
                                  (users.first as Map)['id'];
                              // 2. Assign plan
                              await dio.post(
                                ApiConstants.subscriptions,
                                data: {
                                  'user_id': userId,
                                  'plan': selectedPlan.name,
                                },
                              );
                              Navigator.pop(ctx);
                              ref.invalidate(
                                  subscriptionListProvider);
                              ref.invalidate(
                                  subscriptionStatsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Plan assigned successfully!'),
                                ));
                              }
                            } catch (e) {
                              setModalState(
                                  () => isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                ));
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Assign Plan'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// REVENUE CARD
// ══════════════════════════════════════════════════════════

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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL REVENUE',
                  style: AppTextStyles.labelUppercase
                      .copyWith(color: Colors.white70)),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// STATS GRID (from real API)
// ══════════════════════════════════════════════════════════

class _StatsGrid extends StatelessWidget {
  final SubscriptionStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.primaryLight,
                  value: stats.total.toString(),
                  label: 'TOTAL',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  value: stats.active.toString(),
                  label: 'ACTIVE',
                  valueColor: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_off_outlined,
                  iconColor: AppColors.textSecondary,
                  value: stats.expired.toString(),
                  label: 'EXPIRED',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.cancel_outlined,
                  iconColor: AppColors.error,
                  value: stats.cancelled.toString(),
                  label: 'CANCELLED',
                  valueColor: AppColors.error,
                ),
              ),
            ],
          ),
          if (stats.expiringSoon > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    '${stats.expiringSoon} subscriptions expiring within 7 days',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(
          2,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 1 ? 12 : 0),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// PLAN FILTER ROW
// ══════════════════════════════════════════════════════════

class _PlanFilterRow extends StatelessWidget {
  final PlanType? selected;
  final ValueChanged<PlanType?> onSelect;

  const _PlanFilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final chips = [
      (label: 'All Plans', plan: null as PlanType?, color: AppColors.textSecondary),
      (label: 'Free', plan: PlanType.free as PlanType?, color: AppColors.textSecondary),
      (label: 'Pro', plan: PlanType.pro as PlanType?, color: AppColors.primary),
      (label: 'Premium', plan: PlanType.premium as PlanType?, color: AppColors.warning),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: chips.map((c) {
          final isSelected = selected == c.plan;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(c.plan),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.plan != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : c.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      c.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// STAT CARD
// ══════════════════════════════════════════════════════════

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
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          Text(label, style: AppTextStyles.labelUppercase),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SUBSCRIPTION CARD
// ══════════════════════════════════════════════════════════

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionItem item;
  final VoidCallback onTap;
  final VoidCallback onRenew;
  final VoidCallback onCancel;

  const _SubscriptionCard({
    required this.item,
    required this.onTap,
    required this.onRenew,
    required this.onCancel,
  });

  Color get _statusColor {
    switch (item.status) {
      case SubscriptionStatus.active: return AppColors.success;
      case SubscriptionStatus.expired: return AppColors.textSecondary;
      case SubscriptionStatus.cancelled: return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case SubscriptionStatus.active: return 'ACTIVE';
      case SubscriptionStatus.expired: return 'EXPIRED';
      case SubscriptionStatus.cancelled: return 'CANCELLED';
    }
  }

  Color get _planColor {
    switch (item.plan) {
      case PlanType.free: return AppColors.textSecondary;
      case PlanType.pro: return AppColors.primary;
      case PlanType.premium: return AppColors.warning;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  bool get _isExpiringSoon =>
      item.status == SubscriptionStatus.active &&
      item.daysRemaining != null &&
      item.daysRemaining! <= 7;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: _isExpiringSoon
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
                      color: _planColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.planLabel,
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
                        Text(item.clientName,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(item.clientEmail,
                            style: AppTextStyles.bodySmall),
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
                      Text(_statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                            letterSpacing: 0.8,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        item.amount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: item.status == SubscriptionStatus.cancelled
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      Text(item.currency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.status == SubscriptionStatus.cancelled
                                ? AppColors.error
                                : AppColors.primary,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Expiring soon banner
            if (_isExpiringSoon)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppSizes.radiusLG)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.daysRemaining} days left until expiry',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.warning),
                      ),
                    ),
                    // Quick actions
                    GestureDetector(
                      onTap: onRenew,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull),
                        ),
                        child: const Text('Renew',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

            // Action row for active (non-expiring)
            if (item.status == SubscriptionStatus.active && !_isExpiringSoon)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onRenew,
                      child: Text('Renew',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onCancel,
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error)),
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

// ══════════════════════════════════════════════════════════
// LOAD MORE / EMPTY / ERROR
// ══════════════════════════════════════════════════════════

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
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Load More',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textPrimary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined,
              size: 52,
              color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No subscriptions found',
              style: AppTextStyles.h3
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Try changing the filter',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load subscriptions',
                style: AppTextStyles.h3.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}