/// -------------------------------------------------------
/// PROFILE SCREEN — Client Space
/// -------------------------------------------------------
/// GET  /api/client/profile        → affiche les infos
/// Liens vers EditProfileScreen et ChangePasswordScreen
/// -------------------------------------------------------
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class ClientProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final bool emailVerified;
  final String? createdAt;

  const ClientProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    required this.emailVerified,
    this.createdAt,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested structures
    final name = json['name'] as String? ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = json['first_name'] as String? ??
        (parts.isNotEmpty ? parts.first : '');
    final lastName = json['last_name'] as String? ??
        (parts.length > 1 ? parts.sublist(1).join(' ') : '');

    return ClientProfile(
      id: json['id'] as int,
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      emailVerified: json['email_verified_at'] != null ||
          json['email_verified'] == true,
      createdAt: json['created_at'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String get memberSince {
    if (createdAt == null) return '—';
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return '—';
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────

class ProfileService {
  static const _baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/client/profile
  static Future<ClientProfile> fetchProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/client/profile'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = (body['data'] ?? body['user'] ?? body) as Map<String, dynamic>;
      return ClientProfile.fromJson(data);
    }
    throw Exception('Failed to load profile (${response.statusCode})');
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ClientProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.fetchProfile();
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                'Unable to load profile.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar hero ───────────────────────────
            _buildAvatarHero(p),
            const SizedBox(height: 24),

            // ── Personal Info ─────────────────────────
            _buildSection(
              title: 'Personal Info',
              icon: Icons.person_outline_rounded,
              child: _buildPersonalInfo(p),
            ),
            const SizedBox(height: 16),

            // ── Contact ───────────────────────────────
            _buildSection(
              title: 'Contact',
              icon: Icons.contact_mail_outlined,
              child: _buildContact(p),
            ),
            const SizedBox(height: 16),

            // ── Account ───────────────────────────────
            _buildSection(
              title: 'Account',
              icon: Icons.shield_outlined,
              child: _buildAccount(p),
            ),
            const SizedBox(height: 16),

            // ── Actions ───────────────────────────────
            _buildSection(
              title: 'Settings',
              icon: Icons.settings_outlined,
              child: _buildActions(context),
            ),
            const SizedBox(height: 24),

            // ── Logout ────────────────────────────────
            _buildLogoutButton(),
          ],
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
        'My Profile',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          onPressed: () => _navigateTo(context, const EditProfileScreen()),
          tooltip: 'Edit Profile',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }

  // ── Avatar Hero ───────────────────────────────────────

  Widget _buildAvatarHero(ClientProfile p) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar circle
            Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      p.initials,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                // Verified dot
                if (p.emailVerified)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Name
            Text(
              p.fullName,
              style: AppTextStyles.h2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              p.email,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Member since badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(
                    'Member since ${p.memberSince}',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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

  // ── Personal Info ─────────────────────────────────────

  Widget _buildPersonalInfo(ClientProfile p) {
    return Column(
      children: [
        _infoRow(
          icon: Icons.badge_outlined,
          label: 'FIRST NAME',
          value: p.firstName.isNotEmpty ? p.firstName : '—',
        ),
        _divider(),
        _infoRow(
          icon: Icons.badge_outlined,
          label: 'LAST NAME',
          value: p.lastName.isNotEmpty ? p.lastName : '—',
        ),
      ],
    );
  }

  // ── Contact ───────────────────────────────────────────

  Widget _buildContact(ClientProfile p) {
    return Column(
      children: [
        _infoRow(
          icon: Icons.mail_outline_rounded,
          label: 'EMAIL',
          value: p.email,
          trailing: p.emailVerified
              ? _badge('VERIFIED', AppColors.success)
              : _badge('UNVERIFIED', AppColors.warning),
        ),
        _divider(),
        _infoRow(
          icon: Icons.phone_outlined,
          label: 'PHONE',
          value: p.phone ?? '—',
        ),
        _divider(),
        _infoRow(
          icon: Icons.location_on_outlined,
          label: 'ADDRESS',
          value: p.address ?? '—',
        ),
      ],
    );
  }

  // ── Account ───────────────────────────────────────────

  Widget _buildAccount(ClientProfile p) {
    return Column(
      children: [
        _infoRow(
          icon: Icons.shield_outlined,
          label: 'ROLE',
          value: 'Client',
        ),
        _divider(),
        _infoRow(
          icon: Icons.tag_outlined,
          label: 'CLIENT ID',
          value: '#${p.id.toString().padLeft(5, '0')}',
        ),
        _divider(),
        _infoRow(
          icon: Icons.calendar_month_outlined,
          label: 'MEMBER SINCE',
          value: p.memberSince,
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionTile(
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          label: 'Edit Profile',
          subtitle: 'Update your name, phone and address',
          onTap: () => _navigateTo(context, const EditProfileScreen()),
        ),
        _divider(),
        _actionTile(
          icon: Icons.lock_outline_rounded,
          color: AppColors.warning,
          label: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => _navigateTo(context, const ChangePasswordScreen()),
        ),
      ],
    );
  }

  // ── Logout Button ─────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
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
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.3,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.divider),
      );

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Sign Out?', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'You will be logged out of your account.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      // TODO: navigate to login screen
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN
// ─────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.fetchProfile();
      _firstNameCtrl.text = profile.firstName;
      _lastNameCtrl.text = profile.lastName;
      _phoneCtrl.text = profile.phone ?? '';
      _addressCtrl.text = profile.address ?? '';
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty) {
      _showSnack('First name and last name are required.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/client/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSnack('Profile updated successfully!', isError: false);
          Navigator.pop(context, true);
        }
      } else {
        final body = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(body['message'] ?? 'Update failed');
      }
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.divider),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildFormCard(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        children: [
          _field(
            label: 'FIRST NAME',
            controller: _firstNameCtrl,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 20),
          _field(
            label: 'LAST NAME',
            controller: _lastNameCtrl,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 20),
          _field(
            label: 'PHONE',
            controller: _phoneCtrl,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _field(
            label: 'ADDRESS',
            controller: _addressCtrl,
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, size: 18, color: AppColors.primary),
            hintText: label,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHANGE PASSWORD SCREEN
// ─────────────────────────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _saving = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentCtrl.text.isEmpty ||
        _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      _showSnack('Please fill all fields.', isError: true);
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      _showSnack('Passwords do not match.', isError: true);
      return;
    }
    if (_newCtrl.text.length < 8) {
      _showSnack('Password must be at least 8 characters.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/client/profile/password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': _currentCtrl.text,
          'password': _newCtrl.text,
          'password_confirmation': _confirmCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSnack('Password changed successfully!', isError: false);
          Navigator.pop(context);
        }
      } else {
        final body = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(body['message'] ?? 'Update failed');
      }
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Info banner
            Container(
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
                      'Your password must be at least 8 characters.',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                children: [
                  _pwField(
                    label: 'CURRENT PASSWORD',
                    controller: _currentCtrl,
                    show: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                  ),
                  const SizedBox(height: 20),
                  _pwField(
                    label: 'NEW PASSWORD',
                    controller: _newCtrl,
                    show: _showNew,
                    onToggle: () =>
                        setState(() => _showNew = !_showNew),
                  ),
                  const SizedBox(height: 20),
                  _pwField(
                    label: 'CONFIRM NEW PASSWORD',
                    controller: _confirmCtrl,
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pwField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
  }) {
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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !show,
          style: AppTextStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppColors.primary),
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
            hintText: '••••••••',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}