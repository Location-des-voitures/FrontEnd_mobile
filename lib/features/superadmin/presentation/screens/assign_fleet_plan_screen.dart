import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'subscription_management_screen.dart';

// ─── Models ────────────────────────────────────────────────────────────────

class ClientOption {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const ClientOption({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class FleetPlan {
  final PlanType type;
  final String name;
  final double pricePerMonth;
  final List<String> features;
  final String? badge;
  final Color? badgeColor;
  final bool isPopular;

  const FleetPlan({
    required this.type,
    required this.name,
    required this.pricePerMonth,
    required this.features,
    this.badge,
    this.badgeColor,
    this.isPopular = false,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────

class AssignFleetPlanScreen extends StatefulWidget {
  /// Pass an existing subscription to prefill (Renew/Change flow)
  final SubscriptionItem? existingSubscription;

  const AssignFleetPlanScreen({super.key, this.existingSubscription});

  @override
  State<AssignFleetPlanScreen> createState() => _AssignFleetPlanScreenState();
}

class _AssignFleetPlanScreenState extends State<AssignFleetPlanScreen> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  ClientOption? _selectedClient;
  PlanType? _selectedPlan;

  final List<ClientOption> _clients = [
    ClientOption(id: '1', name: 'Ahmed Benali', email: 'ahmed@mail.com'),
    ClientOption(id: '2', name: 'Fatima Zahra', email: 'f.zahra@global.com'),
    ClientOption(id: '3', name: 'Youssef Tazi', email: 'y.tazi@freemail.com'),
    ClientOption(id: '4', name: 'Karim Idrissi', email: 'k.idrissi@tech.ma'),
  ];

  final List<FleetPlan> _plans = const [
    FleetPlan(
      type: PlanType.free,
      name: 'Free',
      pricePerMonth: 0,
      features: ['Basic fleet browsing', 'Up to 5 bookings/month'],
    ),
    FleetPlan(
      type: PlanType.pro,
      name: 'Pro',
      pricePerMonth: 99,
      features: [
        'Full fleet management',
        'Up to 50 vehicles',
        'Smart pricing engine',
      ],
      badge: 'POPULAR',
      badgeColor: Color(0xFF3B5BDB),
      isPopular: true,
    ),
    FleetPlan(
      type: PlanType.premium,
      name: 'Premium',
      pricePerMonth: 199,
      features: [
        'Unlimited vehicles',
        '24/7 VIP support',
        'Advanced analytics',
      ],
      badge: 'BEST VALUE',
      badgeColor: Color(0xFFEF4444),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Prefill from existing subscription if provided
    if (widget.existingSubscription != null) {
      final sub = widget.existingSubscription!;
      _selectedClient = ClientOption(
        id: sub.id.toString(),
        name: sub.clientName,
        email: sub.clientEmail,
      );
      _selectedPlan = sub.plan;
      _amountController.text = sub.amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _defaultPrice {
    final plan = _plans.firstWhere(
      (p) => p.type == _selectedPlan,
      orElse: () => _plans.first,
    );
    return plan.pricePerMonth;
  }

  void _selectPlan(PlanType type) {
    setState(() {
      _selectedPlan = type;
      _amountController.text = _defaultPrice.toStringAsFixed(2);
    });
  }

  void _showClientSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      builder: (ctx) => _ClientSearchSheet(
        clients: _clients,
        onSelect: (client) {
          setState(() => _selectedClient = client);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _submit() {
    if (_selectedClient == null || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client and a plan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: const Text(
          'Confirm Assignment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Assign ${_planLabel(_selectedPlan!)} plan to ${_selectedClient!.name} for ${_amountController.text} MAD/month?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Fleet plan assigned to ${_selectedClient!.name}',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _planLabel(PlanType type) {
    switch (type) {
      case PlanType.free:
        return 'Free';
      case PlanType.pro:
        return 'Pro';
      case PlanType.premium:
        return 'Premium';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            Text(
              'Assign Fleet Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Configure client subscription',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(height: 24, color: AppColors.textPrimary),
        ),
      ),
      body: Stack(
        children: [
          // Dark top header continuation
          Container(
            height: 32,
            color: AppColors.textPrimary,
          ),

          // Fleet plan icon overlap
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 22),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Select Client ───────────────────────────────
                Text('SELECT CLIENT', style: AppTextStyles.labelUppercase),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () => _showClientSearch(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMD),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: AppColors.textHint, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Search client by name or email...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.vpn_key_outlined,
                                    color: AppColors.textHint, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Selected client
                      if (_selectedClient != null)
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.15),
                                child: Text(
                                  _initials(_selectedClient!.name),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _selectedClient!.name,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _selectedClient!.email,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showClientSearch(context),
                                child: Text(
                                  'Change',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Select Fleet Plan ───────────────────────────
                Text('SELECT FLEET PLAN', style: AppTextStyles.labelUppercase),
                const SizedBox(height: 10),

                ...List.generate(_plans.length, (i) {
                  final plan = _plans[i];
                  final isSelected = _selectedPlan == plan.type;
                  return _PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    onTap: () => _selectPlan(plan.type),
                  );
                }),

                const SizedBox(height: 20),

                // ── Subscription Amount ─────────────────────────
                Text('SUBSCRIPTION AMOUNT', style: AppTextStyles.labelUppercase),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_outlined,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MAD',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (_selectedPlan != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Default price for ${_planLabel(_selectedPlan!)} plan. Adjust if needed.',
                      style: AppTextStyles.caption,
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Internal Notes ──────────────────────────────
                Text('INTERNAL NOTES', style: AppTextStyles.labelUppercase),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.content_paste_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add any specific details or internal codes...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom button ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              color: AppColors.background,
              child: SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.vpn_key, size: 20),
                  label: const Text('Assign Fleet Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    textStyle: AppTextStyles.button,
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card ─────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final FleetPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  Color get _nameColor {
    switch (plan.type) {
      case PlanType.free:
        return AppColors.textPrimary;
      case PlanType.pro:
        return AppColors.primary;
      case PlanType.premium:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _nameColor,
                        ),
                      ),
                      if (plan.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: plan.badgeColor!.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            plan.badge!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: plan.badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.pricePerMonth == 0
                        ? '0 MAD/month'
                        : '${plan.pricePerMonth.toInt()} MAD/month',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _nameColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...plan.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            plan.type == PlanType.premium
                                ? Icons.cancel_outlined
                                : Icons.check,
                            size: 14,
                            color: plan.type == PlanType.premium
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(f, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Client Search Sheet ───────────────────────────────────────────────────

class _ClientSearchSheet extends StatefulWidget {
  final List<ClientOption> clients;
  final ValueChanged<ClientOption> onSelect;

  const _ClientSearchSheet({
    required this.clients,
    required this.onSelect,
  });

  @override
  State<_ClientSearchSheet> createState() => _ClientSearchSheetState();
}

class _ClientSearchSheetState extends State<_ClientSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  List<ClientOption> get _filtered => _query.isEmpty
      ? widget.clients
      : widget.clients
          .where(
            (c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.email.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Client',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _filtered.length,
              (i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    _initials(_filtered[i].name),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  _filtered[i].name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_filtered[i].email),
                onTap: () => widget.onSelect(_filtered[i]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}