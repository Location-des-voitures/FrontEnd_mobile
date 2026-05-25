/// -------------------------------------------------------
/// ADMIN PROFILE SCREEN — FlotTrack Loueur
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/core_providers.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authNotifier.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Hero header ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _initials(user?.name ?? 'A'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Admin',
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        'FLEET MANAGER',
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Stats rapides ──────────────────────
                    Row(
                      children: const [
                        Expanded(
                            child: _QuickStat(
                                '12', 'Cars', Icons.directions_car_outlined)),
                        SizedBox(width: 12),
                        Expanded(
                            child: _QuickStat(
                                '48', 'Bookings', Icons.calendar_month_outlined)),
                        SizedBox(width: 12),
                        Expanded(
                            child: _QuickStat(
                                '24K', 'MAD', Icons.payments_outlined)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Menu sections ──────────────────────
                    _MenuSection(
                      title: 'ACCOUNT',
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          trailing: Switch(
                            value: true,
                            onChanged: (_) {},
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _MenuSection(
                      title: 'FLEET SETTINGS',
                      items: [
                        _MenuItem(
                          icon: Icons.attach_money,
                          label: 'Pricing Rules',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.build_outlined,
                          label: 'Maintenance Alerts',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.schedule_outlined,
                          label: 'Availability Hours',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _MenuSection(
                      title: 'SUPPORT',
                      items: [
                        _MenuItem(
                          icon: Icons.help_outline,
                          label: 'Help Center',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          label: 'About FlotTrack',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Logout ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context),
                        icon: const Icon(Icons.logout,
                            color: AppColors.error, size: 20),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMD),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'FlotTrack v1.0.0',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?'),
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
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      authNotifier.logout();
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _QuickStat(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: AppTextStyles.labelUppercase),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  items[i],
                  if (i < items.length - 1)
                    const Divider(
                        height: 1,
                        indent: 56,
                        color: AppColors.divider),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}