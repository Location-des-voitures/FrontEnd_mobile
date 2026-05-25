import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../providers/user_management_provider.dart';
import 'add_loueur_screen.dart';

class LoueurListScreen extends ConsumerStatefulWidget {
  const LoueurListScreen({super.key});

  @override
  ConsumerState<LoueurListScreen> createState() => _LoueurListScreenState();
}

class _LoueurListScreenState extends ConsumerState<LoueurListScreen> {
  String _filter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminListProvider.notifier).loadAdmins();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reloadAdmins() {
    bool? isActive;
    if (_filter == 'Active') isActive = true;
    if (_filter == 'Suspended') isActive = false;

    ref.read(adminListProvider.notifier).applyFilters(
          UserFilters(
            search: _searchCtrl.text.trim().isEmpty
                ? null
                : _searchCtrl.text.trim(),
            isActive: isActive,
            perPage: 20,
          ),
        );
  }

  Future<void> _openAddLoueur() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLoueurScreen()),
    );
    if (mounted) {
      ref.read(adminListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminListProvider);
    final activeCount = state.users.where((u) => u.isActive).length;
    final suspendedCount = state.users.where((u) => !u.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(adminListProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildStatsRow(
                        total: state.totalUsers,
                        active: activeCount,
                        suspended: suspendedCount,
                      ),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      if (state.isLoading && state.users.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.hasError)
                        _StateMessage(
                          icon: Icons.error_outline,
                          message: state.errorMessage!,
                          actionLabel: 'Retry',
                          onAction: () =>
                              ref.read(adminListProvider.notifier).refresh(),
                        )
                      else if (state.users.isEmpty)
                        _StateMessage(
                          icon: Icons.badge_outlined,
                          message: 'No loueurs found.',
                          actionLabel: 'Add Loueur',
                          onAction: _openAddLoueur,
                        )
                      else
                        ...state.users.map(
                          (admin) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LoueurCard(admin: admin),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddLoueur,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Loueurs',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'FLEET MANAGERS',
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _openAddLoueur,
            child: const Text(
              'Add Loueur',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int total,
    required int active,
    required int suspended,
  }) {
    return Row(
      children: [
        _StatCard(value: '$total', label: 'Total', accentColor: null),
        const SizedBox(width: 10),
        _StatCard(value: '$active', label: 'Active', accentColor: AppColors.success),
        const SizedBox(width: 10),
        _StatCard(
          value: '$suspended',
          label: 'Suspended',
          accentColor: const Color(0xFFC0392B),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textHint, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(
                  const Duration(milliseconds: 350),
                  _reloadAdmins,
                );
              },
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Search loueurs by name or email...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['All', 'Active', 'Suspended'];
    return Row(
      children: filters.map((f) {
        final selected = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              setState(() => _filter = f);
              _reloadAdmins();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? accentColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: accentColor ?? AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (accentColor != null)
              Positioned(
                top: 0,
                bottom: 0,
                left: -14,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusLG),
                      bottomLeft: Radius.circular(AppSizes.radiusLG),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoueurCard extends StatelessWidget {
  final User admin;

  const _LoueurCard({required this.admin});

  String get _initials {
    final parts = admin.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (admin.name.length >= 2) return admin.name.substring(0, 2).toUpperCase();
    return admin.email.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isSuspended = !admin.isActive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isSuspended
                  ? const Color(0xFFFAD4CC)
                  : const Color(0xFFD4DCF5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                  color: isSuspended ? const Color(0xFFC0392B) : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        admin.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(isSuspended: isSuspended),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  admin.email,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      admin.emailVerified
                          ? Icons.verified_outlined
                          : Icons.mark_email_unread_outlined,
                      size: 14,
                      color: admin.emailVerified
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      admin.emailVerified ? 'Verified' : 'Pending verification',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: admin.emailVerified
                            ? AppColors.success
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppColors.textHint.withAlpha(180), size: 20),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isSuspended;

  const _StatusBadge({required this.isSuspended});

  @override
  Widget build(BuildContext context) {
    final color = isSuspended ? const Color(0xFFC0392B) : AppColors.success;
    final bg = isSuspended
        ? const Color(0xFFFAD4CC)
        : AppColors.success.withAlpha(25);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        isSuspended ? 'SUSPENDED' : 'ACTIVE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 42, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
