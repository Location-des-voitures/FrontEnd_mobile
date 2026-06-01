/// -------------------------------------------------------
/// CLIENT HOME SCREEN — Connected to real API
/// -------------------------------------------------------
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String? ?? '').split(' ');
    return UserProfile(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ??
          (name.isNotEmpty ? name.first : ''),
      lastName: json['last_name'] as String? ??
          (name.length > 1 ? name.sublist(1).join(' ') : ''),
      email: json['email'] as String? ?? '',
    );
  }
}

class CarItem {
  final int id;
  final String brand;
  final String model;
  final String? imageUrl;
  final String fuelType;
  final String transmission;
  final double pricePerDay;
  final String status;
  final String? engineLabel;

  CarItem({
    required this.id,
    required this.brand,
    required this.model,
    this.imageUrl,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    required this.status,
    this.engineLabel,
  });

  String get fullName => '$brand $model';
  bool get isAvailable => status.toLowerCase() == 'available';

  factory CarItem.fromJson(Map<String, dynamic> json) {
    return CarItem(
      id: json['id'] as int,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      fuelType: json['fuel_type'] as String? ?? '',
      transmission: json['transmission'] as String? ?? '',
      pricePerDay:
          double.tryParse(json['price_per_day']?.toString() ?? '0') ?? 0,
      status: json['status'] as String? ?? 'available',
      engineLabel: json['engine_label'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────

class HomeApiService {
  static const String _baseUrl = 'https://YOUR_API_BASE_URL/api';

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<UserProfile> fetchProfile() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/client/profile'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return UserProfile.fromJson(data);
    }
    throw Exception('Profile fetch failed');
  }

  static Future<List<CarItem>> fetchCars({int perPage = 6}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/client/cars')
        .replace(queryParameters: {'per_page': perPage.toString()});
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final outer = body['data'];
      final List<dynamic> raw = outer is Map
          ? (outer['data'] as List<dynamic>? ?? [])
          : (outer as List<dynamic>? ?? []);
      return raw
          .map((e) => CarItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Cars fetch failed');
  }

  static Future<List<CarItem>> fetchTrending() async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/client/cars').replace(
      queryParameters: {'per_page': '4', 'sort': 'price_desc'},
    );
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final outer = body['data'];
      final List<dynamic> raw = outer is Map
          ? (outer['data'] as List<dynamic>? ?? [])
          : (outer as List<dynamic>? ?? []);
      return raw
          .map((e) => CarItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Trending fetch failed');
  }

  static Future<List<String>> fetchBrands() async {
    final cars = await fetchCars(perPage: 20);
    final brands = cars
        .map((c) => c.brand)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return brands.take(6).toList();
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _headerSolid = false;

  UserProfile? _profile;
  List<CarItem> _trending = [];
  List<String> _brands = [];
  bool _loadingProfile = true;
  bool _loadingCars = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final solid = _scrollCtrl.offset > 80;
      if (solid != _headerSolid) setState(() => _headerSolid = solid);
    });
    _loadData();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await HomeApiService.fetchProfile();
      if (mounted) setState(() { _profile = profile; _loadingProfile = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
    try {
      final results = await Future.wait([
        HomeApiService.fetchTrending(),
        HomeApiService.fetchBrands(),
      ]);
      if (mounted) {
        setState(() {
          _trending = results[0] as List<CarItem>;
          _brands = results[1] as List<String>;
          _loadingCars = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCars = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F8),
        // ✅ extendBody: true → le contenu passe sous la navbar du ClientShell
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            RefreshIndicator(
              color: const Color(0xFF264DD9),
              onRefresh: _loadData,
              child: ListView(
                controller: _scrollCtrl,
                padding: EdgeInsets.zero,
                children: [
                  _HeroSection(),
                  _SearchSection(),
                  _BrandsSection(brands: _brands, loading: _loadingCars),
                  _TrendingSection(cars: _trending, loading: _loadingCars),
                  _FeaturesBar(),
                  const SizedBox(height: 96), // espace sous la navbar
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final name = _profile?.firstName ?? 'Guest';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _headerSolid
          ? Colors.white.withValues(alpha: 0.9)
          : Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF264DD9).withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF264DD9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'WELCOME',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      color: _headerSolid
                          ? const Color(0xFF78716C)
                          : Colors.white60,
                    ),
                  ),
                  _loadingProfile
                      ? Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      : Text(
                          'Hello, $name',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _headerSolid
                                ? const Color(0xFF1C1B1B)
                                : Colors.white,
                          ),
                        ),
                ],
              ),
              const Spacer(),
              Text(
                'FlotTrack',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _headerSolid
                      ? const Color(0xFF1C1B1B)
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: _headerSolid
                        ? const Color(0xFF1C1B1B)
                        : Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF264DD9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDZq8YxgMcHPBzxfMIr7UImdiJS92O_N1sUZrxBESZvfNz8U_kRHr7FaKEasrnf53HLEYuqItGqmcOalBSyj1unimvu6xI-bMs6F45sR6RQSBFSNrXIUflF4EGdJnJSvkvfy6KzsTpqrP9FqIFdkE5Pb-cSIpJWpZ8L91k__MhPo6buzOH0Ix15TvJzVQ5moTELpd1DkHl-3u9OUsX97ekkbAxkWi-qsVZTXZoAmZcUXARgQ-cU_kYFByCpB0tyVnI2u3mkadUCHkWr',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1C1B1B),
              child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 80),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF1C1B1B)],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'EXCLUSIVE FLEET',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                    color: Color(0xFF264DD9),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Premium\nCar Rental',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SEARCH SECTION
// ═══════════════════════════════════════════════════════

class _SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 40,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              _SearchField(icon: Icons.location_on_outlined, hint: 'Pick up address'),
              const SizedBox(height: 4),
              _SearchField(icon: Icons.near_me_outlined, hint: 'Drop off address'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: _SearchField(icon: Icons.calendar_month_outlined, hint: 'Select Date')),
                  const SizedBox(width: 16),
                  Expanded(child: _SearchField(icon: Icons.schedule_outlined, hint: 'Select Time')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF264DD9), Color(0xFF4568F3)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF264DD9).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Search Fleet',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;
  const _SearchField({required this.icon, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Color(0xFF1C1B1B)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Color(0xFF9CA3AF)),
                border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC4C5D7), width: 0.5)),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC4C5D7), width: 0.5)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF264DD9), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BRANDS SECTION
// ═══════════════════════════════════════════════════════

class _BrandsSection extends StatelessWidget {
  final List<String> brands;
  final bool loading;
  const _BrandsSection({required this.brands, required this.loading});

  static const _fallbackBrands = ['Mercedes', 'Audi', 'BMW', 'Porsche', 'Toyota', 'Renault'];

  @override
  Widget build(BuildContext context) {
    final displayBrands = brands.isNotEmpty ? brands : (loading ? <String>[] : _fallbackBrands);

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('Top Brands', style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1B), letterSpacing: -0.5)),
                Text('VIEW ALL', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Color(0xFF264DD9))),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: loading
                ? _BrandsShimmer()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: displayBrands.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _BrandCard(brandName: displayBrands[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BrandsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 128,
        decoration: BoxDecoration(color: const Color(0xFFF0EDEC), borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final String brandName;
  const _BrandCard({required this.brandName});

  Color get _brandColor {
    final colors = [
      const Color(0xFF264DD9), const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF06B6D4),
    ];
    return colors[brandName.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF6F3F2), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: _brandColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  brandName.isNotEmpty ? brandName[0].toUpperCase() : '?',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w800, color: _brandColor),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(brandName,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1B)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF264DD9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// TRENDING SECTION
// ═══════════════════════════════════════════════════════

class _TrendingSection extends StatelessWidget {
  final List<CarItem> cars;
  final bool loading;
  const _TrendingSection({required this.cars, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trending Now', style: TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1B), letterSpacing: -0.5)),
          const SizedBox(height: 24),
          if (loading)
            ...[1, 2].map((_) => _CarShimmer())
          else if (cars.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No cars available', style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF9CA3AF)))),
            )
          else
            ...cars.map((car) => Padding(padding: const EdgeInsets.only(bottom: 36), child: _CarCard(car: car))),
        ],
      ),
    );
  }
}

class _CarShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 192, decoration: BoxDecoration(color: const Color(0xFFF0EDEC), borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 16),
          Container(width: 160, height: 20, color: const Color(0xFFF0EDEC)),
          const SizedBox(height: 8),
          Container(width: 100, height: 14, color: const Color(0xFFF0EDEC)),
        ],
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarItem car;
  const _CarCard({required this.car});

  IconData _fuelIcon(String fuel) {
    switch (fuel.toLowerCase()) {
      case 'electric': return Icons.bolt;
      case 'hybrid':   return Icons.local_gas_station;
      default:         return Icons.local_gas_station_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 192, width: double.infinity,
            child: car.imageUrl != null
                ? Image.network(car.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePh())
                : _imagePh(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.fullName, style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1B), letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _SpecBadge(icon: _fuelIcon(car.fuelType), label: car.fuelType),
                    const SizedBox(width: 16),
                    _SpecBadge(icon: Icons.settings_outlined, label: car.transmission),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '\$${car.pricePerDay.round()}', style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1B))),
                  const TextSpan(text: '/day', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: Color(0xFF78716C))),
                ])),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: car.isAvailable ? () {} : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    side: BorderSide(color: car.isAvailable ? const Color(0xFFC4C5D7) : const Color(0xFFE5E2E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    car.isAvailable ? 'BOOK NOW' : 'UNAVAILABLE',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                        color: car.isAvailable ? const Color(0xFF1C1B1B) : const Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _imagePh() => Container(
    color: const Color(0xFFF0EDEC),
    child: const Center(child: Icon(Icons.directions_car_outlined, size: 64, color: Color(0xFF9CA3AF))),
  );
}

class _SpecBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFF78716C))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// FEATURES BAR
// ═══════════════════════════════════════════════════════

class _FeaturesBar extends StatelessWidget {
  static const _features = [
    _Feature(Icons.verified_user_outlined, 'Seamless Booking', 'Experience a fully digital, 5-minute checkout process.'),
    _Feature(Icons.diamond_outlined, 'Premium Privileges', 'Priority support and airport lounge access included.'),
    _Feature(Icons.event_repeat_outlined, 'Change/Cancel', 'Free cancellation up to 24h before pick-up.'),
    _Feature(Icons.electric_car_outlined, 'No Recharging', 'Return at any battery level at no extra cost.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1B1B),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 32,
        mainAxisSpacing: 40,
        childAspectRatio: 1.0,
        children: _features.map((f) => _FeatureItem(feature: f)).toList(),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  const _Feature(this.icon, this.title, this.description);
}

class _FeatureItem extends StatelessWidget {
  final _Feature feature;
  const _FeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(feature.icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 14),
        Text(feature.title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text(feature.description, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: Color(0xFF9CA3AF), height: 1.6)),
      ],
    );
  }
}