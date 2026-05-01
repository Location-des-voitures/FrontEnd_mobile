import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'user_detail_screen.dart';
import 'user_profile_screen.dart';

// ─── Models ─────────────────────────────────────────────
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

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  String get fullName => '$firstName $lastName';
}

// ─── Dummy Data ──────────────────────────────────────────
const List<UserModel> _dummyUsers = [
  UserModel(
    id: '1', firstName: 'Ahmed', lastName: 'Benali',
    email: 'ahmed@flottrack.ma', role: UserRole.loueur,
    status: UserStatus.active, subtitle: 'Manages 284 vehicles',
  ),
  UserModel(
    id: '2', firstName: 'Sara', lastName: 'Gestionnaire',
    email: 'sara@flottrack.ma', role: UserRole.loueur,
    status: UserStatus.active, subtitle: 'Manages 196 vehicles',
  ),
  UserModel(
    id: '3', firstName: 'Youssef', lastName: 'Tazi',
    email: 'youssef@mail.com', role: UserRole.client,
    status: UserStatus.active, subtitle: '12 active bookings',
  ),
  UserModel(
    id: '4', firstName: 'Fatima', lastName: 'Zahra',
    email: 'fatima@mail.com', role: UserRole.client,
    status: UserStatus.inactive, subtitle: 'No recent activity',
  ),
  UserModel(
    id: '5', firstName: 'Karim', lastName: 'Idrissi',
    email: 'karim@flottrack.ma', role: UserRole.superAdmin,
    status: UserStatus.active, subtitle: 'Platform owner',
  ),
];

// ─── Screen ─────────────────────────────────────────────
class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  String _selectedType = 'ALL';
  String _selectedStatus = 'All Status';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _typeFilters = ['ALL', 'CLIENTS', 'ADMINS'];
  final List<String> _statusFilters = ['All Status', 'Active', 'Inactive', 'Email Verified'];

  List<UserModel> get _filtered {
    return _dummyUsers.where((u) {
      if (_selectedType == 'CLIENTS' && u.role != UserRole.client) return false;
      if (_selectedType == 'ADMINS' &&
          u.role != UserRole.admin &&
          u.role != UserRole.superAdmin &&
          u.role != UserRole.loueur) return false;
      if (_selectedStatus == 'Active' && u.status != UserStatus.active) return false;
      if (_selectedStatus == 'Inactive' && u.status != UserStatus.inactive) return false;
      final q = _searchController.text.toLowerCase();
      if (q.isNotEmpty &&
          !u.fullName.toLowerCase().contains(q) &&
          !u.email.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
     
    );
  }

  // ── Header ─────────────────────────────────────────────
  // Modifié : supprimé l'icône recherche en haut à droite
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
              Text('Users',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  )),
              Row(
                children: [
                  const Icon(Icons.cloud_sync_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text('FLEET NETWORK\nDIRECTORY',
                      style: AppTextStyles.labelUppercase.copyWith(fontSize: 9, height: 1.15)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Avatar seulement — pas d'icône recherche
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textHint, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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

  // ── Type Filters ───────────────────────────────────────
  Widget _buildTypeFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _typeFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _typeFilters[i];
          final sel = _selectedType == f;
          final icon = f == 'CLIENTS'
              ? Icons.groups_outlined
              : f == 'ADMINS'
                  ? Icons.build_outlined
                  : null;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 13, color: sel ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 4),
                  ],
                  Text(f,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Status Filters ─────────────────────────────────────
  Widget _buildStatusFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _statusFilters[i];
          final sel = _selectedStatus == f;
          Color? dot = f == 'Active' ? AppColors.success : f == 'Inactive' ? AppColors.error : null;
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withAlpha(18) : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 1.5 : 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot != null) ...[
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                  ],
                  Text(f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? AppColors.primary : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── User List ──────────────────────────────────────────
  Widget _buildUserList() {
    final users = _filtered;
    if (users.isEmpty) {
      return Center(
        child: Text('No users found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _UserCard(
        user: users[i],
        onTap: () {
          if (users[i].role == UserRole.loueur) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: users[i])));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailsScreen(user: users[i])));
          }
        },
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────
  // Modifié : Dashboard / Users / Loueurs / Plans / Logs
  Widget _buildBottomNav() {
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      (Icons.people_alt_outlined, Icons.people_alt, 'Users'),
      (Icons.directions_car_outlined, Icons.directions_car, 'Loueurs'),
      (Icons.credit_card_outlined, Icons.credit_card, 'Plans'),
      (Icons.receipt_long_outlined, Icons.receipt_long, 'Logs'),
    ];
    const activeIndex = 1; // Users est actif

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
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(active ? items[i].$2 : items[i].$1,
                    size: 22, color: active ? AppColors.primary : AppColors.textHint),
                const SizedBox(height: 3),
                Text(items[i].$3,
                    style: TextStyle(
                      fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.primary : AppColors.textHint,
                      letterSpacing: 0.5,
                    )),
                const SizedBox(height: 2),
                if (active)
                  Container(
                    width: 4, height: 4,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── User Card ───────────────────────────────────────────
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
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
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
                        child: Text(user.fullName,
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      UserRoleBadge(role: user.role),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(user.subtitle ?? '',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 12, color: AppColors.textHint)),
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

// ─── Shared Widgets (exported for reuse) ─────────────────

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;

  const UserAvatar({super.key, required this.user, this.size = 52});

  Color get _bgColor => switch (user.role) {
    UserRole.loueur => AppColors.primary,
    UserRole.superAdmin => Colors.deepPurple,
    UserRole.admin => AppColors.primaryLight,
    UserRole.client => Colors.grey.shade400,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: _bgColor, shape: BoxShape.circle),
      child: Center(
        child: Text(user.initials,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.34)),
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
          Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2)),
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
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(isActive ? 'ACTIVE' : 'INACTIVE',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}