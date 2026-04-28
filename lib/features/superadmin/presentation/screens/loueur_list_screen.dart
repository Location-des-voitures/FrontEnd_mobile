import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'add_loueur_screen.dart';

// ─── Models ─────────────────────────────────────────────
enum LoueurStatus { active, suspended }

class LoueurModel {
  final String id;
  final String name;
  final String email;
  final LoueurStatus status;
  final int clientsCount;
  final String joinedDate;

  const LoueurModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.clientsCount,
    required this.joinedDate,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}

// ─── Dummy Data ──────────────────────────────────────────
const List<LoueurModel> _dummyLoueurs = [
  LoueurModel(id: '1', name: 'Ahmed Rentals', email: 'ahmed@flottrack.ma',
      status: LoueurStatus.active, clientsCount: 284, joinedDate: 'Joined Mar 2026'),
  LoueurModel(id: '2', name: 'Sara Alami', email: 'sara@flottrack.ma',
      status: LoueurStatus.active, clientsCount: 196, joinedDate: 'Joined Apr 2026'),
  LoueurModel(id: '3', name: 'Atlas Auto', email: 'atlas@flottrack.ma',
      status: LoueurStatus.active, clientsCount: 142, joinedDate: 'Joined Feb 2026'),
  LoueurModel(id: '4', name: 'Karim Motors', email: 'karim@flottrack.ma',
      status: LoueurStatus.suspended, clientsCount: 0, joinedDate: 'Joined Apr 2026'),
];

// ─── Screen ─────────────────────────────────────────────
class LoueurListScreen extends StatefulWidget {
  const LoueurListScreen({super.key});

  @override
  State<LoueurListScreen> createState() => _LoueurListScreenState();
}

class _LoueurListScreenState extends State<LoueurListScreen> {
  String _filter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  int get _total => _dummyLoueurs.length;
  int get _activeCount => _dummyLoueurs.where((l) => l.status == LoueurStatus.active).length;
  int get _suspendedCount => _dummyLoueurs.where((l) => l.status == LoueurStatus.suspended).length;

  List<LoueurModel> get _filtered {
    return _dummyLoueurs.where((l) {
      if (_filter == 'Active' && l.status != LoueurStatus.active) return false;
      if (_filter == 'Suspended' && l.status != LoueurStatus.suspended) return false;
      final q = _searchCtrl.text.toLowerCase();
      if (q.isNotEmpty && !l.name.toLowerCase().contains(q) && !l.email.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    ..._filtered.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LoueurCard(loueur: l),
                    )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AddLoueurScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Loueurs',
                  style: AppTextStyles.h2.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
              Text('FLEET MANAGERS',
                  style: AppTextStyles.labelUppercase.copyWith(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddLoueurScreen())),
            child: const Text('Add Loueur',
                style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(value: '$_total', label: 'Total', accentColor: null),
        const SizedBox(width: 10),
        _StatCard(value: '$_activeCount', label: 'Active', accentColor: AppColors.success),
        const SizedBox(width: 10),
        _StatCard(value: '$_suspendedCount', label: 'Suspended', accentColor: const Color(0xFFC0392B)),
      ],
    );
  }

  // ── Search ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textHint, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
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

  // ── Filter Chips ───────────────────────────────────────
  Widget _buildFilterChips() {
    const filters = ['All', 'Active', 'Suspended'];
    return Row(
      children: filters.map((f) {
        final sel = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider),
              ),
              child: Text(f,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSecondary,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'HOME'),
      (Icons.directions_car_outlined, Icons.directions_car, 'FLEET'),
      (Icons.badge_outlined, Icons.badge, 'LOUEURS'),
      (Icons.calendar_today_outlined, Icons.calendar_today, 'BOOKINGS'),
      (Icons.person_outline, Icons.person, 'PROFILE'),
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
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (active)
                  Container(
                    width: 52, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Icon(items[i].$2, size: 22, color: Colors.white),
                  )
                else
                  Icon(items[i].$1, size: 22, color: AppColors.textHint),
                const SizedBox(height: 3),
                if (!active)
                  Text(items[i].$3,
                      style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w500,
                        color: AppColors.textHint, letterSpacing: 0.5,
                      )),
                if (active)
                  Text(items[i].$3,
                      style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: AppColors.primary, letterSpacing: 0.5,
                      )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? accentColor;

  const _StatCard({required this.value, required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: accentColor ?? AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(label,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            if (accentColor != null)
              Positioned(
                top: 0, bottom: 0, left: -14,
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

// ─── Loueur Card ─────────────────────────────────────────
class _LoueurCard extends StatelessWidget {
  final LoueurModel loueur;

  const _LoueurCard({required this.loueur});

  Color get _avatarBg => loueur.status == LoueurStatus.suspended
      ? const Color(0xFFFAD4CC)
      : const Color(0xFFD4DCF5);

  Color get _avatarText => loueur.status == LoueurStatus.suspended
      ? const Color(0xFFC0392B)
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isSuspended = loueur.status == LoueurStatus.suspended;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: _avatarBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Center(
              child: Text(loueur.initials,
                  style: TextStyle(color: _avatarText, fontWeight: FontWeight.w700, fontSize: 18)),
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
                      child: Text(loueur.name,
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(isSuspended: isSuspended),
                  ],
                ),
                const SizedBox(height: 2),
                Text(loueur.email,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14,
                        color: isSuspended ? AppColors.textHint : AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${loueur.clientsCount} clients',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSuspended ? AppColors.textHint : AppColors.primary,
                        )),
                    const SizedBox(width: 8),
                    Text(loueur.joinedDate,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
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
    final bg = isSuspended ? const Color(0xFFFAD4CC) : AppColors.success.withAlpha(25);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        isSuspended ? 'SUSPENDED' : 'ACTIVE',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3),
      ),
    );
  }
}