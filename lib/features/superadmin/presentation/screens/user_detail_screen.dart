import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'user_list_screen.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildAvatar(),
              const SizedBox(height: 16),
              _buildName(),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildManagementCard(),
              const SizedBox(height: 32),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('User Details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withAlpha(30),
              child: const Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar + Online dot ────────────────────────────────
  Widget _buildAvatar() {
    final isActive = user.status == UserStatus.active;
    return Stack(
      children: [
        UserAvatar(user: user, size: 90),
        if (isActive)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
      ],
    );
  }

  // ── Name + email + role tag ────────────────────────────
  Widget _buildName() {
    return Column(
      children: [
        Text(user.fullName,
            style: AppTextStyles.h2.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(user.email, style: AppTextStyles.bodySmall.copyWith(fontSize: 14)),
        const SizedBox(height: 12),
        _RoleTag(role: user.role),
      ],
    );
  }

  // ── Info Card ──────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.mail_outline,
            label: 'EMAIL',
            value: user.email,
            trailing: _VerifiedBadge(),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'STATUS',
            value: '',
            trailing: _StatusDot(status: user.status),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.shield_outlined,
            label: 'ROLE',
            value: _roleLabel(user.role),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'JOINED DATE',
            value: 'January 12, 2024',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.history_outlined,
            label: 'LAST LOGIN',
            value: '2 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.divider);

  String _roleLabel(UserRole role) => switch (role) {
    UserRole.loueur => 'Loueur',
    UserRole.client => 'Client',
    UserRole.superAdmin => 'Super Admin',
    UserRole.admin => 'Admin',
  };

  // ── Management Card ────────────────────────────────────
  Widget _buildManagementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text('MANAGEMENT',
                style: AppTextStyles.labelUppercase.copyWith(fontSize: 12, letterSpacing: 1.5)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Deactivate Button
                _ActionButton(
                  icon: Icons.block_outlined,
                  label: 'Deactivate Account',
                  filled: true,
                  color: const Color(0xFFC0392B),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                // Delete Button
                _ActionButton(
                  icon: Icons.close_rounded,
                  label: 'Delete Account',
                  filled: false,
                  color: const Color(0xFFC0392B),
                  onTap: () {},
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 8),
        Text('FLEET OPS SECURITY',
            style: AppTextStyles.labelUppercase.copyWith(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────

class _RoleTag extends StatelessWidget {
  final UserRole role;
  const _RoleTag({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.loueur => 'LOUEUR',
      UserRole.client => 'CLIENT',
      UserRole.superAdmin => 'SUPER ADMIN',
      UserRole.admin => 'ADMIN',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(label,
          style: AppTextStyles.labelUppercase.copyWith(
            fontSize: 11, letterSpacing: 1.5, color: AppColors.textSecondary)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.icon, required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelUppercase.copyWith(fontSize: 10)),
                if (value.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Text('VERIFIED',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success, letterSpacing: 0.5)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final UserStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == UserStatus.active;
    final color = isActive ? AppColors.success : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(isActive ? 'Active' : 'Inactive',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label, required this.filled,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        height: 52,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: filled ? null : Border.all(color: color.withAlpha(100), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: filled ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : color,
                )),
          ],
        ),
      ),
    );
  }
}