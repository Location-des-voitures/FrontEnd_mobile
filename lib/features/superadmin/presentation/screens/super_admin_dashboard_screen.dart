import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// -------------------------------------------------------
/// SUPER ADMIN DASHBOARD
/// -------------------------------------------------------
/// Maquette : Dashboard Super Admin avec :
/// - Header : avatar + Dashboard/SUPER ADMIN CONTROL + bell + rRw
/// - Welcome, Super Admin. + Platform health
/// - 4 stat cards (Total Loueurs, Total Clients, Pending Approvals, Platform Usage)
/// - User Growth bar chart
/// - Loueurs Overview (progress bars)
/// - Recent Activity list
/// - Bottom nav : Dashboard / Users / Loueurs / Clients / More
/// -------------------------------------------------------

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 24),

              // ── Welcome ────────────────────────────────
              _buildWelcome(),
              const SizedBox(height: 24),

              // ── Stat Cards (2x2 grid) ──────────────────
              _buildStatCards(),
              const SizedBox(height: 32),

              // ── User Growth Chart ──────────────────────
              _buildUserGrowthSection(),
              const SizedBox(height: 32),

              // ── Loueurs Overview ───────────────────────
              _buildLoueursOverview(),
              const SizedBox(height: 32),

              // ── Recent Activity ────────────────────────
              _buildRecentActivity(),
              const SizedBox(height: 100), // space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: const Icon(
                Icons.person,
                color: Color(0xFF3B5BDB),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'SUPER ADMIN CONTROL',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Bell icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A2E),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // rRw logo
          Text(
            'rRw',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // WELCOME SECTION
  // ═══════════════════════════════════════════════════════
  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Super\nAdmin.',
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Platform health at ',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '99.2%',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B5BDB),
                  ),
                ),
                TextSpan(
                  text: ' — 14 loueurs active\nacross the network.',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STAT CARDS (2x2 grid)
  // ═══════════════════════════════════════════════════════
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1 : Total Loueurs + Total Clients
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.directions_car_outlined,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL LOUEURS',
                  value: '14',
                  change: '+2 this month',
                  changeColor: const Color(0xFF3B5BDB),
                  isHighlighted: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  icon: Icons.people_outline,
                  iconBgColor: const Color(0xFFF0F2FF),
                  iconColor: const Color(0xFF3B5BDB),
                  label: 'TOTAL CLIENTS',
                  value: '1,248',
                  change: '+8.4%',
                  changeColor: const Color(0xFF3B5BDB),
                  isHighlighted: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2 : Pending Approvals + Platform Usage
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.approval_outlined,
                  iconBgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF59E0B),
                  label: 'PENDING APPROVALS',
                  value: '3',
                  change: 'requires action',
                  changeColor: const Color(0xFFF59E0B),
                  isHighlighted: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _platformUsageCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required String change,
    required Color changeColor,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),

          // Label
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),

          // Value
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),

          // Change
          Text(
            change,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Platform Usage card — highlighted in blue
  Widget _platformUsageCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3B5BDB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Label
          Text(
            'PLATFORM USAGE',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),

          // Value
          Text(
            '87%',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.87,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // USER GROWTH CHART
  // ═══════════════════════════════════════════════════════
  Widget _buildUserGrowthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Monthly badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Growth',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last 30 days',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F1EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MONTHLY',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bar chart
            SizedBox(
              height: 140,
              child: _buildBarChart(),
            ),
            const SizedBox(height: 12),

            // Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map((d) => Text(
                        d,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final values = [0.3, 0.45, 0.35, 0.5, 0.65, 0.9, 0.55];
    final isHighlighted = [false, false, false, false, false, true, false];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // +42 users tooltip on SAT
                if (isHighlighted[i])
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+42 users',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Bar
                Container(
                  height: values[i] * 100,
                  decoration: BoxDecoration(
                    color: isHighlighted[i]
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

  // ═══════════════════════════════════════════════════════
  // LOUEURS OVERVIEW
  // ═══════════════════════════════════════════════════════
  Widget _buildLoueursOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loueurs Overview',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
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
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '$clients clients',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B5BDB),
              ),
            ),
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
              Color(0xFF3B5BDB),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // RECENT ACTIVITY
  // ═══════════════════════════════════════════════════════
  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'VIEW ALL',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B5BDB),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity items
          _activityItem(
            icon: Icons.person_add_outlined,
            iconBgColor: const Color(0xFFF0F2FF),
            iconColor: const Color(0xFF3B5BDB),
            title: 'New loueur created',
            subtitle: 'Sara Gestionnaire • joined 2h ago',
            badgeText: 'ACTIVE',
            badgeColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _activityItem(
            icon: Icons.block_outlined,
            iconBgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            title: 'Account deactivated',
            subtitle: 'Client #1182 • 5h ago',
            badgeText: 'INACTIVE',
            badgeColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          _activityItem(
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

  Widget _activityItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM NAVIGATION BAR
  // ═══════════════════════════════════════════════════════
  Widget _buildBottomNav() {
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
        children: [
          _navItem(Icons.dashboard_outlined, 'Dashboard', true),
          _navItem(Icons.people_outline, 'Users', false),
          _navItem(Icons.directions_car_outlined, 'Loueurs', false),
          _navItem(Icons.person_outline, 'Clients', false),
          _navItem(Icons.more_horiz, 'More', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive
              ? const Color(0xFF3B5BDB)
              : const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.3,
            color: isActive
                ? const Color(0xFF3B5BDB)
                : const Color(0xFF9CA3AF),
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF3B5BDB),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}