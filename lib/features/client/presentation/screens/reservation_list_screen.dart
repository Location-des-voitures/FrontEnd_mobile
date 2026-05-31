import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
// import 'reservation_detail_screen.dart'; // à décommenter quand prêt

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class ReservationItem {
  final int id;
  final String carName;
  final String? carImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String status; // pending | approved | confirmed | active | completed | cancelled | rejected

  ReservationItem({
    required this.id,
    required this.carName,
    this.carImageUrl,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested car object
    final carObj = json['car'] as Map<String, dynamic>?;
    final carName = carObj != null
        ? '${carObj['brand'] ?? ''} ${carObj['model'] ?? ''}'.trim()
        : (json['car_name'] as String? ?? 'Unknown Car');
    final carImage = carObj?['image_url'] as String? ?? json['car_image_url'] as String?;

    return ReservationItem(
      id: json['id'] as int,
      carName: carName,
      carImageUrl: carImage,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────

class ReservationListService {
  static const String _baseUrl = 'https://YOUR_API_BASE_URL/api';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/client/reservations?status=pending,approved,confirmed
  static Future<List<ReservationItem>> fetchActive({int perPage = 20}) async {
    final headers = await _headers();
    final uri = Uri.parse('$_baseUrl/client/reservations').replace(
      queryParameters: {'per_page': perPage.toString()},
    );
    final response = await http.get(uri, headers: headers);
    return _parse(response);
  }

  /// GET /api/client/reservations/history
  static Future<List<ReservationItem>> fetchHistory({
    String? status,   // completed | cancelled | rejected
    String? from,     // yyyy-MM-dd
    String? to,       // yyyy-MM-dd
    int perPage = 20,
    int page = 1,
  }) async {
    final headers = await _headers();
    final params = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
      if (status != null && status != 'all') 'status': status,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    final uri = Uri.parse('$_baseUrl/client/reservations/history')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    return _parse(response);
  }

  static List<ReservationItem> _parse(http.Response response) {
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      // Support both paginated { data: { data: [...] } } and flat { data: [...] }
      final outer = body['data'];
      final List<dynamic> raw = outer is Map
          ? (outer['data'] as List<dynamic>? ?? [])
          : (outer as List<dynamic>? ?? []);
      return raw
          .map((e) => ReservationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur ${response.statusCode}');
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _ActiveTab(),
          _HistoryTab(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'My Bookings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: TabBar(
        controller: _tabCtrl,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'History'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        dividerColor: AppColors.divider,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ACTIVE TAB
// ─────────────────────────────────────────────────────────────

class _ActiveTab extends StatefulWidget {
  const _ActiveTab();

  @override
  State<_ActiveTab> createState() => _ActiveTabState();
}

class _ActiveTabState extends State<_ActiveTab>
    with AutomaticKeepAliveClientMixin {
  List<ReservationItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
      final items = await ReservationListService.fetchActive();
      setState(() {
        _items = items;
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
    super.build(context);
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return _ErrorState(onRetry: _load);
    }
    if (_items.isEmpty) {
      return _EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No active bookings',
        subtitle: 'Your current reservations will appear here.',
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _BookingCard(item: _items[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HISTORY TAB
// ─────────────────────────────────────────────────────────────

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab>
    with AutomaticKeepAliveClientMixin {
  List<ReservationItem> _items = [];
  bool _loading = true;
  String? _error;

  // ── Filters ──────────────────────────────────────────
  String _statusFilter = 'all'; // all | completed | cancelled | rejected
  DateTime? _fromDate;
  DateTime? _toDate;

  static const _statusOptions = [
    {'value': 'all', 'label': 'All'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
    {'value': 'rejected', 'label': 'Rejected'},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _fmtApi(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
  String _fmtDisplay(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ReservationListService.fetchHistory(
        status: _statusFilter == 'all' ? null : _statusFilter,
        from: _fromDate != null ? _fmtApi(_fromDate!) : null,
        to: _toDate != null ? _fmtApi(_toDate!) : null,
      );
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) _toDate = null;
      } else {
        _toDate = picked;
      }
    });
    _load();
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'all';
      _fromDate = null;
      _toDate = null;
    });
    _load();
  }

  bool get _hasActiveFilters =>
      _statusFilter != 'all' || _fromDate != null || _toDate != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // ── Filter bar ──────────────────────────────────
        _buildFilterBar(),

        // ── Content ─────────────────────────────────────
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Status chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((opt) {
                final selected = _statusFilter == opt['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _statusFilter = opt['value']!);
                      _load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        opt['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Date range row
          Row(
            children: [
              Expanded(
                child: _datePicker(
                  label: _fromDate != null ? _fmtDisplay(_fromDate!) : 'From',
                  icon: Icons.calendar_today_rounded,
                  active: _fromDate != null,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 8),
              Expanded(
                child: _datePicker(
                  label: _toDate != null ? _fmtDisplay(_toDate!) : 'To',
                  icon: Icons.event_rounded,
                  active: _toDate != null,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.error, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: active ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: active ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return _ErrorState(onRetry: _load);
    }
    if (_items.isEmpty) {
      return _EmptyState(
        icon: Icons.history_rounded,
        title: 'No history yet',
        subtitle: 'Your past reservations will appear here.',
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _BookingCard(item: _items[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BOOKING CARD — matches the mockup exactly
// ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final ReservationItem item;

  const _BookingCard({required this.item});

  String _fmtDate(DateTime dt) => DateFormat('MMM dd, yyyy').format(dt);

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return AppColors.statusActive;
      case 'confirmed':
      case 'approved':
      case 'reserved':
        return AppColors.statusConfirmed;
      case 'pending':
        return AppColors.statusPending;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
      case 'rejected':
        return AppColors.statusCancelled;
      default:
        return AppColors.textHint;
    }
  }

  Color _statusBg(String s) => _statusColor(s).withValues(alpha: 0.12);

  String _statusLabel(String s) => s.toUpperCase();

  /// Active / Confirmed → elevated card with shadow
  /// Pending / History  → flat card without shadow
  bool _isElevated(String s) =>
      s == 'active' || s == 'confirmed' || s == 'approved';

  @override
  Widget build(BuildContext context) {
    final elevated = _isElevated(item.status);

    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => ReservationDetailScreen(reservationId: item.id),
        // ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          // Flat cards get a subtle border
          border: elevated
              ? null
              : Border.all(color: AppColors.divider, width: 0.8),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Car image ────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              child: SizedBox(
                width: 100,
                height: 100,
                child: item.carImageUrl != null
                    ? Image.network(
                        item.carImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePh(),
                      )
                    : _imagePh(),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.carName,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 17,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusBg(item.status),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text(
                          _statusLabel(item.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(item.status),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Dates
                  Text(
                    '${_fmtDate(item.startDate)} - ${_fmtDate(item.endDate)}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),

                  // Price + arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL PRICE',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              letterSpacing: 1.2,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${item.totalAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.price.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Arrow button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: item.status == 'cancelled' ||
                                  item.status == 'rejected'
                              ? AppColors.textHint
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePh() => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.directions_car,
              size: 36, color: AppColors.textHint),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// SHARED STATES
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: Icon(icon, size: 36, color: AppColors.textHint),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les réservations.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}