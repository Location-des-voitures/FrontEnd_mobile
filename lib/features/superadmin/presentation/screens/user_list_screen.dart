import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart' as domain;
import '../../domain/repositories/user_management_repository.dart';
import '../providers/user_management_provider.dart';
import 'user_detail_screen.dart';
import 'user_profile_screen.dart';
import 'admin_detail_screen.dart';

enum UserRole { loueur, client, superAdmin, admin }
enum UserStatus { active, inactive }

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final UserStatus status;
  final String? subtitle;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    this.subtitle,
  });

  factory UserModel.fromDomain(domain.User user) {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first
        : user.email.split('@').first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return UserModel(
      id: user.id.toString(),
      firstName: firstName,
      lastName: lastName,
      email: user.email,
      role: switch (user.role) {
        'super_admin' => UserRole.superAdmin,
        'admin' => UserRole.loueur,
        _ => UserRole.client,
      },
      status: user.isActive ? UserStatus.active : UserStatus.inactive,
      subtitle: user.emailVerified ? 'Email verified' : 'Email not verified',
    );
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : email[0];
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get fullName => [firstName, lastName].where((p) => p.isNotEmpty).join(' ');
}

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  String _selectedType = 'ALL';
  String _selectedStatus = 'All Status';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final List<String> _typeFilters = ['ALL', 'CLIENTS', 'ADMINS'];
  final List<String> _statusFilters = [
    'All Status',
    'Active',
    'Inactive',
    'Email Verified',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadUsers);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    String? role;
    if (_selectedType == 'CLIENTS') role = 'client';
    if (_selectedType == 'ADMINS') role = 'admin';

    bool? isActive;
    bool? emailVerified;
    if (_selectedStatus == 'Active') isActive = true;
    if (_selectedStatus == 'Inactive') isActive = false;
    if (_selectedStatus == 'Email Verified') emailVerified = true;

    ref.read(userListProvider.notifier).applyFilters(
          UserFilters(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            role: role,
            isActive: isActive,
            emailVerified: emailVerified,
            perPage: 30,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 2),
            _buildTypeFilters(),
            _buildStatusFilters(),
            const SizedBox(height: 4),
            Expanded(child: _buildUserList(state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUsers,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 26),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Users',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.cloud_sync_outlined,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'LIVE NETWORK\nDIRECTORY',
                    style: AppTextStyles.labelUppercase.copyWith(
                      fontSize: 9,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
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
              controller: _searchController,
              onChanged: (_) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(
                  const Duration(milliseconds: 350),
                  _loadUsers,
                );
              },
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Search members...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(7),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: const Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _typeFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = _typeFilters[i];
          final selected = _selectedType == filter;
          final icon = filter == 'CLIENTS'
              ? Icons.groups_outlined
              : filter == 'ADMINS'
                  ? Icons.build_outlined
                  : null;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = filter);
              _loadUsers();
            },
            child: _FilterChip(label: filter, selected: selected, icon: icon),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = _statusFilters[i];
          final selected = _selectedStatus == filter;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedStatus = filter);
              _loadUsers();
            },
            child: _StatusFilterChip(label: filter, selected: selected),
          );
        },
      ),
    );
  }

  Widget _buildUserList(UserListState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _StateMessage(
        icon: Icons.error_outline,
        message: state.errorMessage!,
        actionLabel: 'Retry',
        onAction: _loadUsers,
      );
    }

    final users = state.users.map(UserModel.fromDomain).toList();
    if (users.isEmpty) {
      return _StateMessage(
        icon: Icons.people_outline,
        message: 'No users found',
        actionLabel: 'Refresh',
        onAction: _loadUsers,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(userListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _UserCard(
          user: users[i],
          onTap: () {
  if (users[i].role == UserRole.loueur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDetailScreen(user: users[i]),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailsScreen(userId: int.parse(users[i].id)),
      ),
    );
  }
},
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;

  const _FilterChip({required this.label, required this.selected, this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _StatusFilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final dot = label == 'Active'
        ? AppColors.success
        : label == 'Inactive'
            ? AppColors.error
            : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withAlpha(18) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isInactive = user.status == UserStatus.inactive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isInactive ? const Color(0xFFF5F4F1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
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
            UserAvatar(user: user, size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      UserRoleBadge(role: user.role),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.subtitle ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      UserStatusBadge(status: user.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;

  const UserAvatar({super.key, required this.user, this.size = 52});

  Color get _bgColor => switch (user.role) {
        UserRole.loueur => AppColors.primary,
        UserRole.superAdmin => Colors.deepPurple,
        UserRole.admin => AppColors.primaryLight,
        UserRole.client => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _bgColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.34,
          ),
        ),
      ),
    );
  }
}

class UserRoleBadge extends StatelessWidget {
  final UserRole role;
  const UserRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (role) {
      UserRole.loueur => ('LOUEUR', Icons.storefront_outlined, AppColors.primary),
      UserRole.client => ('CLIENT', Icons.person_outline, AppColors.textSecondary),
      UserRole.superAdmin => ('SUPER ADMIN', Icons.shield_outlined, Colors.deepPurple),
      UserRole.admin => ('ADMIN', Icons.manage_accounts_outlined, AppColors.primaryLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class UserStatusBadge extends StatelessWidget {
  final UserStatus status;
  const UserStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == UserStatus.active;
    final color = isActive ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
