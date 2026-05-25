/// -------------------------------------------------------
/// ADMIN DETAIL SCREEN — Super Admin Space
/// -------------------------------------------------------
/// Affiché quand le super admin clique sur un loueur/admin
/// depuis UsersListScreen ou LoueurListScreen.
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../screens/user_list_screen.dart'; // UserModel, UserStatus

class AdminDetailScreen extends StatefulWidget {
  final UserModel user;
  const AdminDetailScreen({super.key, required this.user});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  // Mock data — remplacer par appels API
  final _plan = 'Pro';
  final _planColor = AppColors.primary;
  final _planExpiry = '1 Jun 2026';
  final _totalCars = 12;
  final _totalClients = 48;
  final _totalRevenue = 24850;
  final _activeReservations = 7;
  bool _isActive = true;

  UserModel get user => widget.user;

  String get _initials => user.initials;
  String get _fullName => user.fullName;

  @override
  void initState() {
    super.initState();
    _isActive = user.status == UserStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () => _showOptions(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF2B44A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          // Status dot
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _fullName,
                        style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 10),
                      // Plan badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _planColor.withValues(alpha: 0.25),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                          border: Border.all(
                              color: _planColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium,
                                size: 14, color: _planColor),
                            const SizedBox(width: 6),
                            Text(
                              '$_plan Plan · Expires $_planExpiry',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _planColor,
                                  letterSpacing: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Stats ──────────────────────────────
                  _StatsRow(
                    cars: _totalCars,
                    clients: _totalClients,
                    revenue: _totalRevenue,
                    activeRes: _activeReservations,
                  ),

                  const SizedBox(height: 16),

                  // ── Contact Info ───────────────────────
                  _SectionCard(
                    title: 'CONTACT INFO',
                    children: [
                      _InfoTile(
                          Icons.mail_outline_rounded, 'Email', user.email),
                      _Divider(),
                      _InfoTile(Icons.badge_outlined, 'Role', 'Fleet Manager'),
                      _Divider(),
                      _InfoTile(
                        Icons.calendar_today_outlined,
                        'Member Since',
                        'Jan 2026',
                      ),
                      _Divider(),
                      _InfoTile(
                        Icons.history_outlined,
                        'Last Login',
                        '2 hours ago',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Subscription Card ──────────────────
                  _SubscriptionCard(
                    plan: _plan,
                    planColor: _planColor,
                    expiry: _planExpiry,
                    amountPaid: 99,
                    onChangePlan: () => _showChangePlan(context),
                  ),

                  const SizedBox(height: 16),

                  // ── Fleet Overview ─────────────────────
                  _SectionCard(
                    title: 'FLEET OVERVIEW',
                    children: [
                      _FleetStatRow(
                        icon: Icons.directions_car_outlined,
                        label: 'Total vehicles',
                        value: '$_totalCars',
                        color: AppColors.primary,
                      ),
                      _Divider(),
                      _FleetStatRow(
                        icon: Icons.people_outline,
                        label: 'Total clients',
                        value: '$_totalClients',
                        color: AppColors.success,
                      ),
                      _Divider(),
                      _FleetStatRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Active reservations',
                        value: '$_activeReservations',
                        color: AppColors.warning,
                      ),
                      _Divider(),
                      _FleetStatRow(
                        icon: Icons.payments_outlined,
                        label: 'Total revenue',
                        value: '$_totalRevenue MAD',
                        color: AppColors.success,
                        isHighlighted: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Management Actions ─────────────────
                  _SectionCard(
                    title: 'MANAGEMENT',
                    children: [
                      _ActionTile(
                        icon: _isActive
                            ? Icons.block_outlined
                            : Icons.check_circle_outline,
                        color: _isActive ? AppColors.error : AppColors.success,
                        label: _isActive
                            ? 'Suspend Account'
                            : 'Activate Account',
                        subtitle: _isActive
                            ? 'Admin won\'t be able to access the platform'
                            : 'Restore admin access to the platform',
                        onTap: () => _confirmToggle(context),
                      ),
                      _Divider(),
                      _ActionTile(
                        icon: Icons.credit_card_outlined,
                        color: AppColors.primary,
                        label: 'Manage Subscription',
                        subtitle: 'Change or renew the fleet plan',
                        onTap: () => _showChangePlan(context),
                      ),
                      _Divider(),
                      _ActionTile(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        label: 'Delete Account',
                        subtitle: 'Permanently remove this admin',
                        onTap: () => _confirmDelete(context),
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Options menu ──────────────────────────────────────
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Admin Info'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline, color: AppColors.primary),
              title: const Text('Send Email'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.textSecondary),
              title: const Text('View Activity Logs'),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Change plan ───────────────────────────────────────
  void _showChangePlan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Change Fleet Plan',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...[
              ('Free', 0, AppColors.textSecondary),
              ('Pro', 99, AppColors.primary),
              ('Premium', 199, AppColors.warning),
            ].map((plan) => GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Plan changed to ${plan.$1} for $_fullName'),
                      backgroundColor: AppColors.success,
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: plan.$3.withValues(alpha: 0.06),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                          color: plan.$3.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.workspace_premium,
                            color: plan.$3, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(plan.$1,
                              style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: plan.$3)),
                        ),
                        Text(
                          plan.$2 == 0 ? 'Free' : '${plan.$2} MAD/mo',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: plan.$3),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Confirm toggle ────────────────────────────────────
  Future<void> _confirmToggle(BuildContext context) async {
    final action = _isActive ? 'suspend' : 'activate';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG)),
        title: Text(
          '${action[0].toUpperCase()}${action.substring(1)} account?',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to $action $_fullName?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isActive ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
                action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _isActive = !_isActive);
      // TODO: appeler usecase activate/deactivate
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Account ${_isActive ? 'activated' : 'suspended'} successfully'),
        backgroundColor:
            _isActive ? AppColors.success : AppColors.warning,
      ));
    }
  }

  // ── Confirm delete ────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG)),
        title: const Text('Delete Admin Account',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Delete $_fullName? All their fleet data will be permanently lost. This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      // TODO: appeler deleteUser usecase
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Admin account deleted'),
        backgroundColor: AppColors.error,
      ));
    }
  }
}

// ═══════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════

// ── Stats Row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int cars, clients, revenue, activeRes;
  const _StatsRow({
    required this.cars,
    required this.clients,
    required this.revenue,
    required this.activeRes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatBubble(
                '$cars', 'Cars', Icons.directions_car_outlined,
                AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatBubble(
                '$clients', 'Clients', Icons.people_outline,
                AppColors.success)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatBubble(
                '$activeRes', 'Active', Icons.calendar_month_outlined,
                AppColors.warning)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatBubble(
                '${(revenue / 1000).toStringAsFixed(1)}k',
                'MAD',
                Icons.payments_outlined,
                const Color(0xFF7C3AED))),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatBubble(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.divider),
      );
}

// ── Info Tile ─────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelUppercase.copyWith(fontSize: 10)),
              Text(value,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fleet Stat Row ────────────────────────────────────────
class _FleetStatRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final bool isHighlighted;
  const _FleetStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Subscription Card ─────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  final String plan, expiry;
  final Color planColor;
  final double amountPaid;
  final VoidCallback onChangePlan;
  const _SubscriptionCard({
    required this.plan,
    required this.expiry,
    required this.planColor,
    required this.amountPaid,
    required this.onChangePlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            planColor.withValues(alpha: 0.12),
            planColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: planColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SUBSCRIPTION',
                  style: AppTextStyles.labelUppercase.copyWith(
                      fontSize: 11, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onChangePlan,
                child: Text('Change plan',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: planColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: planColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium,
                        size: 18, color: planColor),
                    const SizedBox(width: 6),
                    Text(
                      plan,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: planColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amountPaid.toInt()} MAD/mo',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: planColor),
                  ),
                  Text('Expires $expiry',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Tile ───────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary)),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.textHint),
        ],
      ),
    );
  }
}