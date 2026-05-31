/// -------------------------------------------------------
/// EDIT PROFILE SCREEN — Client Space
/// -------------------------------------------------------
/// PUT /api/client/profile
/// Body : { first_name, last_name, phone, address }
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/client_profile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _formKey        = GlobalKey<FormState>();

  bool _initialised = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Pré-remplit le formulaire avec les données existantes (une seule fois)
  void _prefill(ClientProfile profile) {
    if (_initialised) return;
    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text  = profile.lastName;
    _phoneCtrl.text     = profile.phone   ?? '';
    _addressCtrl.text   = profile.address ?? '';
    _initialised = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(profileProvider.notifier).update(
      UpdateProfileRequest(
        firstName: _firstNameCtrl.text.trim(),
        lastName:  _lastNameCtrl.text.trim(),
        phone:     _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
        address:   _addressCtrl.text.trim().isNotEmpty
            ? _addressCtrl.text.trim()
            : null,
      ),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context, true);
    } else {
      final err = ref.read(profileProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Update failed. Please try again.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    // Pré-remplissage dès que le profil est disponible
    if (state.profile != null) _prefill(state.profile!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state.isLoading),
      body: state.profile == null && state.isLoading
          // ── Loading initial ───────────────────────────
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar compact ───────────────────
                    if (state.profile != null) _buildAvatarRow(state.profile!),
                    const SizedBox(height: 24),

                    // ── Form card ────────────────────────
                    _buildFormCard(),
                    const SizedBox(height: 24),

                    // ── Submit button ────────────────────
                    _buildSaveButton(state.isLoading),
                  ],
                ),
              ),
            ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool loading) {
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
        'Edit Profile',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      // Bouton Save rapide dans l'AppBar
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }

  // ── Avatar row (compact) ──────────────────────────────────
  Widget _buildAvatarRow(ClientProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          // Email verified badge
          if (profile.emailVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: const Text(
                'VERIFIED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Form Card ─────────────────────────────────────────────
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
              const Icon(Icons.person_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'PERSONAL INFO',
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // First name
          _FormField(
            label: 'FIRST NAME',
            controller: _firstNameCtrl,
            icon: Icons.badge_outlined,
            hint: 'e.g. Hamza',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),

          // Last name
          _FormField(
            label: 'LAST NAME',
            controller: _lastNameCtrl,
            icon: Icons.badge_outlined,
            hint: 'e.g. Lalami',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // Contact section header
          Row(
            children: [
              const Icon(Icons.contact_mail_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'CONTACT',
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone
          _FormField(
            label: 'PHONE',
            controller: _phoneCtrl,
            icon: Icons.phone_outlined,
            hint: 'e.g. 0612345678',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // Address
          _FormField(
            label: 'ADDRESS',
            controller: _addressCtrl,
            icon: Icons.location_on_outlined,
            hint: 'e.g. Casablanca, Maroc',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────
  Widget _buildSaveButton(bool loading) {
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
                'Save Changes',
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
// REUSABLE FORM FIELD WIDGET
// ═══════════════════════════════════════════════════════

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            contentPadding: maxLines > 1
                ? const EdgeInsets.symmetric(vertical: 14, horizontal: 16)
                : null,
          ),
        ),
      ],
    );
  }
}