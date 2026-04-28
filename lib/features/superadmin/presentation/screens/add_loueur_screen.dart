import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AddLoueurScreen extends StatefulWidget {
  const AddLoueurScreen({super.key});

  @override
  State<AddLoueurScreen> createState() => _AddLoueurScreenState();
}

class _AddLoueurScreenState extends State<AddLoueurScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _notifyMethod = 'password_reset'; // 'password_reset' | 'send_credentials'

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    _buildNotifySection(),
                    const SizedBox(height: 20),
                    _buildIllustration(),
                    const SizedBox(height: 24),
                    _buildCreateButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.only(top: 2),
          ),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New Loueur',
                  style: AppTextStyles.h2.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
              Text('Create a new fleet manager account',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Form Card ──────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'FULL NAME',
            hint: 'e.g. Sara Alami',
            controller: _nameCtrl,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 24),
          _FormField(
            label: 'EMAIL ADDRESS',
            hint: 'e.g. sara@flottrack.ma',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ── Notify Section ─────────────────────────────────────
  Widget _buildNotifySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('HOW TO NOTIFY',
              style: AppTextStyles.labelUppercase.copyWith(
                fontSize: 11, letterSpacing: 1.8, color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              )),
        ),
        _NotifyOption(
          value: 'password_reset',
          groupValue: _notifyMethod,
          icon: Icons.mail_outline_rounded,
          iconBg: const Color(0xFFE8EEFF),
          iconColor: AppColors.primary,
          title: 'Password Reset',
          badge: 'RECOMMENDED',
          description: 'Admin receives a 6-digit OTP by email to set their own password',
          onTap: () => setState(() => _notifyMethod = 'password_reset'),
        ),
        const SizedBox(height: 10),
        _NotifyOption(
          value: 'send_credentials',
          groupValue: _notifyMethod,
          icon: Icons.lock_outline_rounded,
          iconBg: AppColors.surfaceVariant,
          iconColor: AppColors.textSecondary,
          title: 'Send Credentials',
          description: 'You provide a temporary password. Admin receives OTP for email verification',
          onTap: () => setState(() => _notifyMethod = 'send_credentials'),
        ),
      ],
    );
  }

  // ── Illustration ───────────────────────────────────────
  Widget _buildIllustration() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: Container(
        height: 160,
        width: double.infinity,
        color: AppColors.surfaceVariant,
        child: Stack(
          children: [
            // Grey gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8E7E4), Color(0xFFD0CFCC)],
                ),
              ),
            ),
            // Laptop illustration placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.laptop_mac_outlined, size: 64, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 28,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
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
    );
  }

  // ── Create Button ──────────────────────────────────────
  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _handleCreate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Create Loueur',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.person_add_outlined, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  void _handleCreate() {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loueur "${_nameCtrl.text.trim()}" created!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
      ),
    );
    Navigator.pop(context);
  }

  // ── Bottom Nav ─────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      (Icons.directions_car_outlined, 'FLEET'),
      (Icons.calendar_today_outlined, 'RENTALS'),
      (Icons.badge_outlined, 'TEAM'),
      (Icons.settings_outlined, 'SETTINGS'),
    ];
    const activeIndex = 2;
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == activeIndex;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(items[i].$1, size: 22, color: active ? AppColors.primary : AppColors.textHint),
              const SizedBox(height: 3),
              Text(items[i].$2,
                  style: TextStyle(
                    fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.textHint,
                    letterSpacing: 0.5,
                  )),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelUppercase.copyWith(
              fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700,
            )),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _NotifyOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? badge;
  final String description;
  final VoidCallback onTap;

  const _NotifyOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.badge,
    required this.description,
    required this.onTap,
  });

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.divider,
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: _isSelected
              ? [BoxShadow(color: AppColors.primary.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(badge!,
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: AppColors.success, letterSpacing: 0.3,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 13, height: 1.4, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}