import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import 'reservation_form_screen.dart'; 

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

class CarDetail {
  final int id;
  final String brand;
  final String model;
  final String fuelType;
  final String transmission;
  final double pricePerDay;
  final String? imageUrl;
  final String status;
  final String? engineLabel;
  // Extended fields
  final int? horsepower;
  final String? acceleration;
  final String? drivetrain;
  final String? torque;
  final int? seats;
  final String? weight;
  final String? location;

  CarDetail({
    required this.id,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    this.imageUrl,
    required this.status,
    this.engineLabel,
    this.horsepower,
    this.acceleration,
    this.drivetrain,
    this.torque,
    this.seats,
    this.weight,
    this.location,
  });

  factory CarDetail.fromJson(Map<String, dynamic> json) {
    return CarDetail(
      id: json['id'] as int,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      fuelType: json['fuel_type'] as String? ?? '',
      transmission: json['transmission'] as String? ?? '',
      pricePerDay: double.tryParse(json['price_per_day'].toString()) ?? 0,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'available',
      engineLabel: json['engine_label'] as String?,
      horsepower: json['horsepower'] as int?,
      acceleration: json['acceleration'] as String?,
      drivetrain: json['drivetrain'] as String?,
      torque: json['torque'] as String?,
      seats: json['seats'] as int?,
      weight: json['weight'] as String?,
      location: json['location'] as String?,
    );
  }

  bool get isAvailable => status.toLowerCase() == 'available';
  String get fullName => '$brand $model';
}

class PriceCalcResult {
  final double pricePerDay;
  final int totalDays;
  final double totalAmount;
  final bool isAvailable;

  PriceCalcResult({
    required this.pricePerDay,
    required this.totalDays,
    required this.totalAmount,
    required this.isAvailable,
  });

  factory PriceCalcResult.fromJson(Map<String, dynamic> json) {
    return PriceCalcResult(
      pricePerDay: double.tryParse(json['price_per_day'].toString()) ?? 0,
      totalDays: json['total_days'] as int? ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────

class CarDetailApiService {
  static const String _baseUrl = 'https://YOUR_API_BASE_URL/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Map<String, String> get _headers => {'Accept': 'application/json'};

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/client/cars/{id}
  static Future<CarDetail> fetchCarDetail(int carId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/client/cars/$carId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return CarDetail.fromJson(data);
    }
    throw Exception('Erreur ${response.statusCode}');
  }

  /// POST /api/client/cars/calculate-price
  static Future<PriceCalcResult> calculatePrice({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/client/cars/calculate-price'),
      headers: headers,
      body: json.encode({
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return PriceCalcResult.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('Erreur calcul prix');
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class CarDetailScreen extends StatefulWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  // ── Data ─────────────────────────────────────────────────
  CarDetail? _car;
  bool _loading = true;
  String? _error;

  // ── Dates ────────────────────────────────────────────────
  DateTime? _pickupDate;
  DateTime? _returnDate;

  // ── Price calc ───────────────────────────────────────────
  PriceCalcResult? _priceResult;
  bool _calcLoading = false;

  // ── Calendar state ───────────────────────────────────────
  DateTime _calendarMonth = DateTime.now();
  DateTime? _calStart;
  DateTime? _calEnd;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  // ─────────────────────────────────────────────────────────
  // API CALLS
  // ─────────────────────────────────────────────────────────

  Future<void> _loadCar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final car = await CarDetailApiService.fetchCarDetail(widget.carId);
      setState(() {
        _car = car;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _calculatePrice() async {
    if (_car == null || _calStart == null || _calEnd == null) return;
    setState(() => _calcLoading = true);
    try {
      final result = await CarDetailApiService.calculatePrice(
        carId: _car!.id,
        startDate: DateFormat('yyyy-MM-dd').format(_calStart!),
        endDate: DateFormat('yyyy-MM-dd').format(_calEnd!),
      );
      setState(() {
        _priceResult = result;
        _pickupDate = _calStart;
        _returnDate = _calEnd;
        _calcLoading = false;
      });
    } catch (_) {
      setState(() => _calcLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // CALENDAR LOGIC
  // ─────────────────────────────────────────────────────────

  void _onDayTap(DateTime day) {
    final now = DateTime.now();
    if (day.isBefore(DateTime(now.year, now.month, now.day))) return;

    setState(() {
      if (_calStart == null || (_calStart != null && _calEnd != null)) {
        _calStart = day;
        _calEnd = null;
        _priceResult = null;
      } else {
        if (day.isBefore(_calStart!)) {
          _calStart = day;
        } else {
          _calEnd = day;
          _calculatePrice();
        }
      }
    });
  }

  bool _isInRange(DateTime day) {
    if (_calStart == null || _calEnd == null) return false;
    return day.isAfter(_calStart!) && day.isBefore(_calEnd!);
  }

  bool _isStart(DateTime day) => _calStart != null && _isSameDay(day, _calStart!);
  bool _isEnd(DateTime day) => _calEnd != null && _isSameDay(day, _calEnd!);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ─────────────────────────────────────────────────────────
  // NAVIGATE TO BOOKING  👈 MODIFIÉ
  // ─────────────────────────────────────────────────────────

  void _goToReservation() {
    if (_car == null || _calStart == null || _calEnd == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationFormScreen(
          car: CarSummary(
            id: _car!.id,
            brand: _car!.brand,
            model: _car!.model,
            pricePerDay: _car!.pricePerDay,
            imageUrl: _car!.imageUrl,
          ),
          startDate: _calStart!,
          endDate: _calEnd!,
          priceSummary: _priceResult != null
              ? PriceSummary(
                  pricePerDay: _priceResult!.pricePerDay,
                  totalDays: _priceResult!.totalDays,
                  totalAmount: _priceResult!.totalAmount,
                )
              : null,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy').format(dt);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.statusActive;
      case 'rented':
        return AppColors.statusRented;
      case 'maintenance':
        return AppColors.statusMaintenance;
      default:
        return AppColors.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'AVAILABLE';
      case 'rented':
        return 'RENTED';
      case 'maintenance':
        return 'MAINTENANCE';
      default:
        return status.toUpperCase();
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _car == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Impossible de charger la voiture.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _loadCar, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final car = _car!;
    final canBook = car.isAvailable && _calStart != null && _calEnd != null;
    final totalPrice = _priceResult?.totalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(car),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(car),
            _buildHeader(car),
            if (car.horsepower != null || car.acceleration != null || car.drivetrain != null)
              _buildSpecStrip(car),
            _buildTechTable(car),
            _buildCalendar(),
            if (_calStart != null) _buildDateSummary(),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingBar(car, canBook, totalPrice),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(CarDetail car) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
          ),
          child: IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // HERO IMAGE
  // ─────────────────────────────────────────────────────────

  Widget _buildHero(CarDetail car) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          car.imageUrl != null
              ? Image.network(
                  car.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _heroPh(),
                )
              : _heroPh(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.background, AppColors.background.withOpacity(0)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(active: true),
                const SizedBox(width: 4),
                _dot(),
                const SizedBox(width: 4),
                _dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPh() => Container(
        color: AppColors.surfaceVariant,
        child: const Center(child: Icon(Icons.directions_car, size: 72, color: AppColors.textHint)),
      );

  Widget _dot({bool active = false}) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: active ? 24 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      );

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────

  Widget _buildHeader(CarDetail car) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor(car.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _statusLabel(car.status),
                style: AppTextStyles.labelUppercase.copyWith(
                  color: _statusColor(car.status),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(car.fullName, style: AppTextStyles.h1),
          const SizedBox(height: 6),
          if (car.engineLabel != null)
            Text(
              '${car.engineLabel} • ${car.transmission}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 8),
          Text(
            'Precision engineering meets executive comfort. '
            '${car.brand} delivers an uncompromising driving experience with cutting-edge technology.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SPEC STRIP
  // ─────────────────────────────────────────────────────────

  Widget _buildSpecStrip(CarDetail car) {
    final specs = <Map<String, String>>[];
    if (car.horsepower != null) specs.add({'label': 'POWER OUTPUT', 'value': '${car.horsepower} hp'});
    if (car.acceleration != null) specs.add({'label': '0-100 KM/H', 'value': car.acceleration!});
    if (car.drivetrain != null) specs.add({'label': 'DRIVETRAIN', 'value': car.drivetrain!});

    if (specs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: specs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final s = specs[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s['label']!, style: AppTextStyles.labelUppercase.copyWith(fontSize: 9)),
                  const SizedBox(height: 4),
                  Text(
                    s['value']!,
                    style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TECH TABLE
  // ─────────────────────────────────────────────────────────

  Widget _buildTechTable(CarDetail car) {
    final rows = <Map<String, String>>[];
    if (car.engineLabel != null) rows.add({'label': 'Engine', 'value': car.engineLabel!});
    if (car.torque != null) rows.add({'label': 'Torque', 'value': car.torque!});
    rows.add({'label': 'Transmission', 'value': car.transmission});
    rows.add({'label': 'Fuel Type', 'value': car.fuelType});
    if (car.seats != null) rows.add({'label': 'Capacity', 'value': '${car.seats} passengers'});
    if (car.weight != null) rows.add({'label': 'Curb Weight', 'value': car.weight!});

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Technical Specs', style: AppTextStyles.h3),
              Text(
                'FULL SPECS',
                style: AppTextStyles.labelUppercase.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: Column(
              children: List.generate(rows.length, (i) {
                final isLast = i == rows.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              rows[i]['label']!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            rows[i]['value']!,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(color: AppColors.divider, height: 0.5, thickness: 0.5),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CALENDAR
  // ─────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_calendarMonth.year, _calendarMonth.month);
    final startWeekday = firstDayOfMonth.weekday % 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Dates', style: AppTextStyles.h3),
                      Text(
                        'Tap start date, then end date',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    'LIVE',
                    style: AppTextStyles.labelUppercase.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_calendarMonth).toUpperCase(),
                  style: AppTextStyles.labelUppercase,
                ),
                const Spacer(),
                _calNavBtn(Icons.chevron_left, () {
                  setState(() => _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month - 1,
                      ));
                }),
                const SizedBox(width: 4),
                _calNavBtn(Icons.chevron_right, () {
                  setState(() => _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month + 1,
                      ));
                }),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.labelUppercase.copyWith(fontSize: 10, color: AppColors.textHint),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (_, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final dayNum = index - startWeekday + 1;
                final date = DateTime(_calendarMonth.year, _calendarMonth.month, dayNum);
                final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                final isStart = _isStart(date);
                final isEnd = _isEnd(date);
                final inRange = _isInRange(date);
                final isToday = _isSameDay(date, now);

                Color bgColor = Colors.transparent;
                Color textColor = isPast ? AppColors.textHint : AppColors.textPrimary;
                FontWeight fontWeight = FontWeight.w400;
                BorderRadius radius = BorderRadius.circular(AppSizes.radiusFull);

                if (isStart || isEnd) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                  fontWeight = FontWeight.w700;
                } else if (inRange) {
                  bgColor = AppColors.primary.withOpacity(0.12);
                  textColor = AppColors.primaryDark;
                  fontWeight = FontWeight.w500;
                  radius = BorderRadius.zero;
                } else if (isToday) {
                  textColor = AppColors.primary;
                  fontWeight = FontWeight.w700;
                }

                return GestureDetector(
                  onTap: isPast ? null : () => _onDayTap(date),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: radius,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: fontWeight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // DATE SUMMARY
  // ─────────────────────────────────────────────────────────

  Widget _buildDateSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PICK UP', style: AppTextStyles.labelUppercase.copyWith(fontSize: 9)),
                  const SizedBox(height: 4),
                  Text(_fmtDate(_calStart), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.primary.withOpacity(0.20)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RETURN', style: AppTextStyles.labelUppercase.copyWith(fontSize: 9)),
                    const SizedBox(height: 4),
                    Text(
                      _calEnd != null ? _fmtDate(_calEnd) : 'Select...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _calEnd != null ? AppColors.textPrimary : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_calcLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BOOKING BAR
  // ─────────────────────────────────────────────────────────

  Widget _buildBookingBar(CarDetail car, bool canBook, double? totalPrice) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${car.pricePerDay.round()}', style: AppTextStyles.price),
                  Text(' / day', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 11, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text(
                    'Incl. insurance & fees',
                    style: AppTextStyles.caption.copyWith(fontSize: 10, letterSpacing: 0.3),
                  ),
                ],
              ),
              if (totalPrice != null) ...[
                const SizedBox(height: 3),
                Text(
                  'Est. Total: \$${totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: canBook ? _goToReservation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canBook ? AppColors.primary : AppColors.divider,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                minimumSize: Size.zero,
                elevation: 0,
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(
                canBook ? 'Reserve' : 'Select Dates',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}