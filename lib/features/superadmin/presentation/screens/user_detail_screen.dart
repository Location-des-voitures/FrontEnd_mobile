import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import 'user_list_screen.dart';


// ─── Model ────────────────────────────────────────────────────────────────────

class UserDetail {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? emailVerifiedAt;
  final String? createdAt;

  const UserDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerifiedAt,
    this.createdAt,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        isActive: json['is_active'] == true || json['is_active'] == 1,
        emailVerifiedAt: json['email_verified_at'],
        createdAt: json['created_at'],
      );

  bool get isEmailVerified => emailVerifiedAt != null;

  String get roleLabel => switch (role) {
        'super_admin' => 'Super Admin',
        'admin'       => 'Admin',
        'client'      => 'Client',
        _             => role,
      };

  String get joinedDate {
    if (createdAt == null) return '—';
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return '—';
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class UserService {
  static const _baseUrl = 'http://localhost:8000/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'flottrack_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<UserDetail> fetchUser(int id) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/super-admin/users/$id'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return UserDetail.fromJson(body['data']);
    }
    throw Exception('Failed to load user (${res.statusCode})');
  }

  static Future<void> activateUser(int id) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/super-admin/users/$id/activate'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Activation failed');
    }
  }

  static Future<void> deactivateUser(int id) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/super-admin/users/$id/deactivate'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Deactivation failed');
    }
  }

  static Future<void> deleteUser(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/super-admin/users/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Delete failed');
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class UserDetailsScreen extends StatefulWidget {
  /// Passe soit [userId] pour charger depuis l'API,
  /// soit [user] (UserModel existant) pour afficher directement.
  final int userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<UserDetail> _userFuture;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.fetchUser(widget.userId);
  }

  void _reload() => setState(() {
        _userFuture = UserService.fetchUser(widget.userId);
      });

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _toggleActive(UserDetail user) async {
    final confirm = await _showConfirmDialog(
      title: user.isActive ? 'Deactivate Account' : 'Activate Account',
      message: user.isActive
          ? 'Are you sure you want to deactivate ${user.name}?'
          : 'Are you sure you want to activate ${user.name}?',
      confirmLabel: user.isActive ? 'Deactivate' : 'Activate',
      isDestructive: user.isActive,
    );
    if (!confirm) return;

    setState(() => _actionLoading = true);
    try {
      if (user.isActive) {
        await UserService.deactivateUser(user.id);
      } else {
        await UserService.activateUser(user.id);
      }
      _showSnack(user.isActive ? 'Account deactivated' : 'Account activated');
      _reload();
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  Future<void> _deleteUser(UserDetail user) async {
    final confirm = await _showConfirmDialog(
      title: 'Delete Account',
      message: 'This will permanently delete ${user.name}. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirm) return;

    setState(() => _actionLoading = true);
    try {
      await UserService.deleteUser(user.id);
      _showSnack('Account deleted');
      if (mounted) Navigator.pop(context, true); // retourne true = liste à rafraichir
    } catch (e) {
      _showSnack(e.toString(), isError: true);
      setState(() => _actionLoading = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmLabel,
                  style: TextStyle(
                    color: isDestructive ? const Color(0xFFC0392B) : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFC0392B) : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<UserDetail>(
          future: _userFuture,
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              );
            }

            final user = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildAvatar(user),
                      const SizedBox(height: 16),
                      _buildName(user),
                      const SizedBox(height: 24),
                      _buildInfoCard(user),
                      const SizedBox(height: 24),
                      _buildManagementCard(user),
                      const SizedBox(height: 32),
                      _buildFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Overlay loader pendant une action
                if (_actionLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x55000000),
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
            child: Text(
              'User Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
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

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatar(UserDetail user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.primary.withAlpha(30),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        if (user.isActive)
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

  // ── Name block ────────────────────────────────────────────────────────────

  Widget _buildName(UserDetail user) {
    return Column(
      children: [
        Text(
          user.name,
          style: AppTextStyles.h2.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(user.email, style: AppTextStyles.bodySmall.copyWith(fontSize: 14)),
        const SizedBox(height: 12),
        _RoleTag(roleLabel: user.roleLabel),
      ],
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(UserDetail user) {
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
            trailing: user.isEmailVerified ? _VerifiedBadge() : _UnverifiedBadge(),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.check_circle_outline,
            label: 'STATUS',
            value: '',
            trailing: _StatusDot(isActive: user.isActive),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.shield_outlined,
            label: 'ROLE',
            value: user.roleLabel,
          ),
          _divider(),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'JOINED DATE',
            value: user.joinedDate,
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.divider);

  // ── Management Card ───────────────────────────────────────────────────────

  Widget _buildManagementCard(UserDetail user) {
    // Les super_admin ne peuvent pas être gérés
    if (user.role == 'super_admin') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'MANAGEMENT',
              style: AppTextStyles.labelUppercase.copyWith(fontSize: 12, letterSpacing: 1.5),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Activate / Deactivate toggle
                _ActionButton(
                  icon: user.isActive ? Icons.block_outlined : Icons.check_circle_outline,
                  label: user.isActive ? 'Deactivate Account' : 'Activate Account',
                  filled: true,
                  color: user.isActive ? const Color(0xFFC0392B) : AppColors.success,
                  onTap: () => _toggleActive(user),
                ),
                const SizedBox(height: 10),
                // Delete
                _ActionButton(
                  icon: Icons.close_rounded,
                  label: 'Delete Account',
                  filled: false,
                  color: const Color(0xFFC0392B),
                  onTap: () => _deleteUser(user),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 8),
        Text(
          'FLEET OPS SECURITY',
          style: AppTextStyles.labelUppercase.copyWith(fontSize: 10, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _RoleTag extends StatelessWidget {
  final String roleLabel;
  const _RoleTag({required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        roleLabel.toUpperCase(),
        style: AppTextStyles.labelUppercase.copyWith(
          fontSize: 11, letterSpacing: 1.5, color: AppColors.textSecondary,
        ),
      ),
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
            width: 36,
            height: 36,
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
      child: Text(
        'VERIFIED',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success, letterSpacing: 0.5),
      ),
    );
  }
}

class _UnverifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: const Text(
        'UNVERIFIED',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.orange, letterSpacing: 0.5),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;
  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
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
    required this.icon,
    required this.label,
    required this.filled,
    required this.color,
    required this.onTap,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}