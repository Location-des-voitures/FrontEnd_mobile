import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'subscription_management_screen.dart';

// ─── Screen ────────────────────────────────────────────────────────────────

class SubscriptionDetailScreen extends StatelessWidget {
  final SubscriptionItem subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  Color get _statusColor {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get _planLabel {
    switch (subscription.plan) {
      case PlanType.free:
        return 'FREE';
      case PlanType.pro:
        return 'PRO';
      case PlanType.premium:
        return 'PREMIUM';
    }
  }

  Color get _planColor {
    switch (subscription.plan) {
      case PlanType.free:
        return AppColors.textSecondary;
      case PlanType.pro:
        return AppColors.primary;
      case PlanType.premium:
        return AppColors.warning;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int get _totalDays =>
      subscription.endDate.difference(subscription.startDate).inDays;

  int get _daysRemaining {
    final now = DateTime.now();
    final diff = subscription.endDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get _progress {
    if (_totalDays == 0) return 0;
    return (_totalDays - _daysRemaining) / _totalDays;
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Subscription #${subscription.id}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Plan header card
            _PlanHeaderCard(
              planLabel: _planLabel,
              planColor: _planColor,
              statusLabel: _statusLabel,
              statusColor: _statusColor,
              clientName: subscription.clientName,
              clientEmail: subscription.clientEmail,
              initials: _initials(subscription.clientName),
            ),

            const SizedBox(height: 16),

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'START DATE',
                    value: _formatDate(subscription.startDate),
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: 'END DATE',
                    value: _formatDate(subscription.endDate),
                  ),
                  const Divider(height: 24, color: AppColors.divider),

                  // Days remaining with progress
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAYS REMAINING',
                              style: AppTextStyles.labelUppercase,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_daysRemaining days',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress.clamp(0.0, 1.0),
                                backgroundColor: AppColors.divider,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: AppColors.divider),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'AMOUNT PAID',
                    value: '${subscription.amount.toStringAsFixed(2)} MAD',
                    valueStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _DetailRow(
                    icon: Icons.language_outlined,
                    label: 'CURRENCY',
                    value: subscription.currency,
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'NOTES',
                    value: 'First month subscription',
                    valueStyle: AppTextStyles.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/superadmin/assign-plan',
                  arguments: subscription,
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Renew / Change Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  textStyle: AppTextStyles.button,
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(Icons.close, size: 20, color: AppColors.error),
                label: const Text('Cancel Subscription'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  textStyle: AppTextStyles.button,
                ),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              'This will immediately cancel the subscription',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel the subscription for ${subscription.clientName}? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Cancel Now'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
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
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Subscription'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.textSecondary),
              title: const Text('View History'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Subscription',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Plan Header Card ──────────────────────────────────────────────────────

class _PlanHeaderCard extends StatelessWidget {
  final String planLabel;
  final Color planColor;
  final String statusLabel;
  final Color statusColor;
  final String clientName;
  final String clientEmail;
  final String initials;

  const _PlanHeaderCard({
    required this.planLabel,
    required this.planColor,
    required this.statusLabel,
    required this.statusColor,
    required this.clientName,
    required this.clientEmail,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          Text(
            planLabel,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: planColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(clientEmail, style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Detail Row ────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelUppercase),
            const SizedBox(height: 2),
            Text(
              value,
              style: valueStyle ??
                  AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}