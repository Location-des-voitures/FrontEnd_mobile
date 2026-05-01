import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_list_screen.dart';
import 'loueur_list_screen.dart';
import 'subscription_management_screen.dart';
import 'system_log_screen.dart';

/// -------------------------------------------------------
/// SUPER ADMIN DASHBOARD — version interactive
/// -------------------------------------------------------
/// Navbar fonctionnelle : Dashboard / Users / Loueurs / Subscriptions / Logs
/// -------------------------------------------------------

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _currentIndex = 0;

  // Les 5 pages de la navbar
  final List<Widget> _pages = const [
    _DashboardBody(),
    UsersListScreen(),
    LoueurListScreen(),
    SubscriptionManagementScreen(),
    SystemLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      // On laisse chaque page gérer son propre Scaffold si besoin,
      // mais pour Dashboard on embarque le body directement.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
      (Icons.people_outline, Icons.people_alt_rounded, 'Users'),
      (Icons.directions_car_outlined, Icons.directions_car_rounded, 'Loueurs'),
      (Icons.credit_card_outlined, Icons.credit_card_rounded, 'Plans'),
      (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Logs'),
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = _currentIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? items[i].$2 : items[i].$1,
                    size: 24,
                    color: isActive
                        ? const Color(0xFF3B5BDB)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$3,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.3,
                      color: isActive
                          ? const Color(0xFF3B5BDB)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 4 : 0,
                    height: isActive ? 4 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B5BDB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// DASHBOARD BODY (onglet 0)
// ══════════════════════════════════════════════════════════

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildWelcome(),
            const SizedBox(height: 24),
            _buildStatCards(context),
            const SizedBox(height: 32),
            _buildUserGrowthSection(),
            const SizedBox(height: 32),
            _buildLoueursOverview(),
            const SizedBox(height: 32),
            _buildRecentActivity(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.person,
                color: Color(0xFF3B5BDB), size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E))),
              Text('SUPER ADMIN CONTROL',
                  style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: const Color(0xFF6B7280))),
            ],
          ),
          const Spacer(),
          // Bouton alertes
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/superadmin/alerts'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.notifications_outlined,
                        color: Color(0xFF1A1A2E), size: 20),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('FlotTrack',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  // ── Welcome ───────────────────────────────────────────
  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, Super\nAdmin.',
              style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                  height: 1.15)),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Platform health at ',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                  height: 1.5),
              children: [
                TextSpan(
                    text: '99.2%',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B5BDB))),
                TextSpan(
                    text: ' — 14 loueurs active\nacross the network.',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ────────────────────────────────────────
  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_car_outlined,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL LOUEURS',
                  value: '14',
                  change: '+2 this month',
                  changeColor: const Color(0xFF3B5BDB),
                  // Tap → onglet Loueurs (index 2)
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<
                            _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 2);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL CLIENTS',
                  value: '1,248',
                  change: '+8.4%',
                  changeColor: const Color(0xFF3B5BDB),
                  // Tap → onglet Users (index 1)
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<
                            _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.approval_outlined,
                  iconBgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF59E0B),
                  label: 'PENDING APPROVALS',
                  value: '3',
                  change: 'requires action',
                  changeColor: const Color(0xFFF59E0B),
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<
                            _SuperAdminDashboardScreenState>();
                    state?.setState(() => state._currentIndex = 3);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _PlatformUsageCard()),
            ],
          ),
        ],
      ),
    );
  }

  // ── User Growth Chart ─────────────────────────────────
  Widget _buildUserGrowthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('User Growth',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E))),
                  Text('Last 30 days',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: const Color(0xFF9CA3AF))),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF2F1EE),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('MONTHLY',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color(0xFF6B7280))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 140, child: _buildBarChart()),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map((d) => Text(d,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final values = [0.3, 0.45, 0.35, 0.5, 0.65, 0.9, 0.55];
    final highlighted = [false, false, false, false, false, true, false];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (highlighted[i])
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('+42 users',
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                Container(
                  height: values[i] * 100,
                  decoration: BoxDecoration(
                    color: highlighted[i]
                        ? const Color(0xFF3B5BDB)
                        : const Color(0xFFE8E7E4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Loueurs Overview ──────────────────────────────────
  Widget _buildLoueursOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loueurs Overview',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 20),
          _loueurBar('Ahmed Rentals', 284, 1.0),
          const SizedBox(height: 18),
          _loueurBar('Casa Premium Cars', 196, 0.69),
          const SizedBox(height: 18),
          _loueurBar('Atlas Auto', 142, 0.50),
        ],
      ),
    );
  }

  Widget _loueurBar(String name, int clients, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E))),
            Text('$clients clients',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B5BDB))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8E7E4),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3B5BDB)),
          ),
        ),
      ],
    );
  }

  // ── Recent Activity ───────────────────────────────────
  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
              GestureDetector(
                onTap: () {
                  final state = context.findAncestorStateOfType<
                      _SuperAdminDashboardScreenState>();
                  state?.setState(() => state._currentIndex = 4);
                },
                child: Text('VIEW ALL',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B5BDB),
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActivityItem(
            icon: Icons.person_add_outlined,
            iconBgColor: const Color(0xFFF0F2FF),
            iconColor: const Color(0xFF3B5BDB),
            title: 'New loueur created',
            subtitle: 'Sara Gestionnaire • joined 2h ago',
            badgeText: 'ACTIVE',
            badgeColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.block_outlined,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            title: 'Account deactivated',
            subtitle: 'Client #1182 • 5h ago',
            badgeText: 'INACTIVE',
            badgeColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.verified_outlined,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            title: 'Email verified',
            subtitle: 'Ahmed Loueur • yesterday',
            badgeText: 'VERIFIED',
            badgeColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SUB-WIDGETS
// ══════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String change;
  final Color changeColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.change,
    required this.changeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: const Color(0xFF9CA3AF))),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(change,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: changeColor)),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 10, color: changeColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformUsageCard extends StatelessWidget {
  const _PlatformUsageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xFF3B5BDB),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text('PLATFORM USAGE',
              style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 6),
          Text('87%',
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.87,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;

  const _ActivityItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(badgeText,
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}