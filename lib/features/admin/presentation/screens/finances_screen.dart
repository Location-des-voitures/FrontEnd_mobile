/// -------------------------------------------------------
/// FINANCES SCREEN — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  String _period = 'This Month';
  final _periods = ['This Week', 'This Month', 'This Year'];

  // Mock data — remplacer par API
  final _monthlyData = [
    _RevenueBar('Jan', 0.4),
    _RevenueBar('Feb', 0.6),
    _RevenueBar('Mar', 0.5),
    _RevenueBar('Apr', 0.75),
    _RevenueBar('May', 0.9),
    _RevenueBar('Jun', 0.65),
    _RevenueBar('Jul', 0.8),
  ];

  final _transactions = [
    _Transaction('Youssef Tazi', 'BMW i4 M50', 1500, '14 May 2026',
        TransactionType.income),
    _Transaction('Fatima Zahra', 'Audi A7', 850, '12 May 2026',
        TransactionType.income),
    _Transaction('Oil change — BMW i4', '', 200, '10 May 2026',
        TransactionType.expense),
    _Transaction('Atlas Auto', 'Mercedes C300', 1200, '8 May 2026',
        TransactionType.income),
    _Transaction('Tire replacement', '', 350, '5 May 2026',
        TransactionType.expense),
  ];

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _netProfit => _totalIncome - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildRevenueChart(),
              const SizedBox(height: 20),
              _buildTransactionsList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Finances',
                  style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text('REVENUE & EXPENSES',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          // Period selector
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _period,
                isDense: true,
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                items: _periods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _period = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Cards ──────────────────────────────────────
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Net Profit (hero card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF2B44A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NET PROFIT',
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '${_netProfit.toInt()} MAD',
                  style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('+18.2% vs last month',
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.arrow_downward_rounded,
                  label: 'INCOME',
                  amount: _totalIncome,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.arrow_upward_rounded,
                  label: 'EXPENSES',
                  amount: _totalExpenses,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Revenue Chart ──────────────────────────────────────
  Widget _buildRevenueChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Overview',
                style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _monthlyData.map((bar) {
                  final isMax = bar.value ==
                      _monthlyData
                          .map((b) => b.value)
                          .reduce((a, b) => a > b ? a : b);
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMax)
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(bar.value * 100).toInt()}%',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: bar.value * 100,
                            decoration: BoxDecoration(
                              color: isMax
                                  ? AppColors.primary
                                  : AppColors.primary
                                      .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(bar.month,
                              style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Transactions List ──────────────────────────────────
  Widget _buildTransactionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () {},
                  child: Text('VIEW ALL',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Column(
              children: List.generate(_transactions.length, (i) {
                final t = _transactions[i];
                final isIncome = t.type == TransactionType.income;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isIncome
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isIncome
                              ? AppColors.success
                              : AppColors.error,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        t.name,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        t.subtitle.isNotEmpty ? t.subtitle : t.date,
                        style: AppTextStyles.bodySmall
                            .copyWith(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}${t.amount.toInt()} MAD',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isIncome
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          Text(t.date,
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    if (i < _transactions.length - 1)
                      const Divider(
                          height: 1,
                          indent: 72,
                          color: AppColors.divider),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  const _SummaryCard(
      {required this.icon,
      required this.label,
      required this.amount,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelUppercase.copyWith(
                      fontSize: 9, color: AppColors.textSecondary)),
              Text('${amount.toInt()} MAD',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueBar {
  final String month;
  final double value; // 0.0 → 1.0
  const _RevenueBar(this.month, this.value);
}

enum TransactionType { income, expense }

class _Transaction {
  final String name, subtitle, date;
  final double amount;
  final TransactionType type;
  const _Transaction(
      this.name, this.subtitle, this.amount, this.date, this.type);
}