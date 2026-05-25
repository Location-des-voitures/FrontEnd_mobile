/// -------------------------------------------------------
/// ANALYTICS SCREEN — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(),
                  _FleetTab(),
                  _ClientsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text('Analytics',
              style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text('MAY 2026',
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Fleet'),
          Tab(text: 'Clients'),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KPI Row
          Row(
            children: const [
              Expanded(
                  child: _KpiCard(
                      label: 'Occupancy Rate',
                      value: '78%',
                      change: '+5%',
                      icon: Icons.percent,
                      color: AppColors.primary)),
              SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'Avg. Booking',
                      value: '4.2d',
                      change: '+0.8d',
                      icon: Icons.timelapse_outlined,
                      color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                  child: _KpiCard(
                      label: 'Cancellation',
                      value: '8%',
                      change: '-2%',
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      changePositive: true)),
              SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'Revenue/Car',
                      value: '1,240',
                      change: '+180 MAD',
                      icon: Icons.directions_car_outlined,
                      color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 20),

          // Booking trend
          _ChartCard(
            title: 'Booking Trend',
            subtitle: 'Last 7 days',
            child: _LineChartMock(),
          ),

          const SizedBox(height: 16),

          // Revenue vs Expenses
          _ChartCard(
            title: 'Revenue vs Expenses',
            subtitle: 'Monthly breakdown',
            child: _BarChartMock(),
          ),
        ],
      ),
    );
  }
}

// ── Fleet Tab ────────────────────────────────────────────
class _FleetTab extends StatelessWidget {
  final _data = const [
    _FleetStat('BMW i4 M50', 28, AppColors.primary),
    _FleetStat('Audi A7 S-Line', 22, Color(0xFF7C3AED)),
    _FleetStat('Mercedes C300', 18, AppColors.success),
    _FleetStat('Porsche Taycan', 15, AppColors.warning),
    _FleetStat('Tesla Model 3', 10, AppColors.error),
  ];

  const _FleetTab();

  @override
  Widget build(BuildContext context) {
    final total = _data.fold(0, (s, d) => s + d.bookings);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status pie mockup
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fleet Status Distribution',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _PieSegment('Available', '62%', AppColors.success),
                    _PieSegment('Rented', '28%', AppColors.warning),
                    _PieSegment('Maintenance', '10%', AppColors.error),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Top cars
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Most Booked Cars',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                ..._data.map((d) {
                  final pct = d.bookings / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(d.name,
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text('${d.bookings} bookings',
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: d.color,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AppColors.divider,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(d.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clients Tab ──────────────────────────────────────────
class _ClientsTab extends StatelessWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                  child: _KpiCard(
                      label: 'New Clients',
                      value: '24',
                      change: '+8 this month',
                      icon: Icons.person_add_outlined,
                      color: AppColors.primary)),
              SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'Returning',
                      value: '68%',
                      change: '+3%',
                      icon: Icons.repeat_outlined,
                      color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Client Growth',
            subtitle: 'New registrations per month',
            child: _BarChartMock(color: AppColors.success),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client Satisfaction',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _RatingRow('5 stars', 0.58, AppColors.success),
                const SizedBox(height: 8),
                _RatingRow('4 stars', 0.28, AppColors.success),
                const SizedBox(height: 8),
                _RatingRow('3 stars', 0.09, AppColors.warning),
                const SizedBox(height: 8),
                _RatingRow('≤ 2 stars', 0.05, AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label, value, change;
  final IconData icon;
  final Color color;
  final bool changePositive;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.changePositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: AppTextStyles.labelUppercase.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(change,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(subtitle,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LineChartMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final points = [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 0.75];
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(points.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: points[i] * 80,
                decoration: BoxDecoration(
                  color: i == points.length - 2
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BarChartMock extends StatelessWidget {
  final Color color;
  const _BarChartMock({this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) {
    final vals = [0.5, 0.65, 0.45, 0.8, 0.7, 0.9, 0.6];
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: vals.map((v) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: v * 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PieSegment extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PieSegment(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _RatingRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _FleetStat {
  final String name;
  final int bookings;
  final Color color;
  const _FleetStat(this.name, this.bookings, this.color);
}