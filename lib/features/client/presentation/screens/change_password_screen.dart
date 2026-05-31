/// -------------------------------------------------------
/// CHANGE PASSWORD SCREEN — Client Space
/// -------------------------------------------------------
/// PUT /api/client/profile/password
/// Body : { current_password, password, password_confirmation }
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/client_profile.dart';
import '../providers/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _currentCtrl    = TextEditingController();
  final _newCtrl        = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;

  // Strength indicator
  double _strength     = 0;
  String _strengthLabel = '';
  Color  _strengthColor = AppColors.divider;

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(_evaluateStrength);
  }

  @override
  void dispose() {
    _newCtrl.removeListener(_evaluateStrength);
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Password strength ─────────────────────────────────
  void _evaluateStrength() {
    final pw = _newCtrl.text;
    double score = 0;
    if (pw.length >= 8)                                score += 0.25;
    if (pw.contains(RegExp(r'[A-Z]')))                score += 0.25;
    if (pw.contains(RegExp(r'[0-9]')))                score += 0.25;
    if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}]'))) score += 0.25;

    String label;
    Color color;
    if (score <= 0.25) {
      label = 'Weak';
      color = AppColors.error;
    } else if (score <= 0.50) {
      label = 'Fair';
      color = AppColors.warning;
    } else if (score <= 0.75) {
      label = 'Good';
      color = const Color(0xFF3B82F6);
    } else {
      label = 'Strong';
      color = AppColors.success;
    }

    setState(() {
      _strength      = score;
      _strengthLabel = pw.isEmpty ? '' : label;
      _strengthColor = color;
    });
  }

  // ── Submit ────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(profileProvider.notifier).changePassword(
      ChangePasswordRequest(
        currentPassword:      _currentCtrl.text,
        password:             _newCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      ),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password changed successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else {
      final err = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Failed to change password. Check your current password.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Info banner ──────────────────────────
              _buildInfoBanner(),
              const SizedBox(height: 20),

              // ── Form card ────────────────────────────
              _buildFormCard(),
              const SizedBox(height: 24),

              // ── Submit button ────────────────────────
              _buildSubmitButton(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Change Password',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }

  // ── Info Banner ───────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'For a strong password, use at least 8 characters with uppercase, numbers and symbols.',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Card ─────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'SECURITY',
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Current password ─────────────────────────
          _PasswordField(
            label: 'CURRENT PASSWORD',
            controller: _currentCtrl,
            hint: 'Enter your current password',
            show: _showCurrent,
            onToggle: () =>
                setState(() => _showCurrent = !_showCurrent),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              return null;
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // ── New password ─────────────────────────────
          _PasswordField(
            label: 'NEW PASSWORD',
            controller: _newCtrl,
            hint: 'At least 8 characters',
            show: _showNew,
            onToggle: () => setState(() => _showNew = !_showNew),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 8)
                return 'Password must be at least 8 characters';
              if (v == _currentCtrl.text)
                return 'New password must differ from current';
              return null;
            },
          ),

          // Strength bar
          if (_newCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _StrengthBar(
              strength: _strength,
              label:    _strengthLabel,
              color:    _strengthColor,
            ),
          ],

          const SizedBox(height: 20),

          // ── Confirm password ─────────────────────────
          _PasswordField(
            label: 'CONFIRM NEW PASSWORD',
            controller: _confirmCtrl,
            hint: 'Re-enter your new password',
            show: _showConfirm,
            onToggle: () =>
                setState(() => _showConfirm = !_showConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v != _newCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────
  Widget _buildSubmitButton(bool loading) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.divider,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Update Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PASSWORD FIELD WIDGET
// ═══════════════════════════════════════════════════════

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.show,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelUppercase.copyWith(
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !show,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: show ? 0 : 2.0,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textHint,
              ),
              onPressed: onToggle,
            ),
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textHint, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// STRENGTH BAR WIDGET
// ═══════════════════════════════════════════════════════

class _StrengthBar extends StatelessWidget {
  final double strength;
  final String label;
  final Color color;

  const _StrengthBar({
    required this.strength,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 segments
        Row(
          children: List.generate(4, (i) {
            final filled = strength > i * 0.25;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? color : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}