/// -------------------------------------------------------
/// CAR LIST SCREEN — FlotTrack Loueur
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// ✅ Import des vraies entités du domaine (plus de doublons locaux)
import '../../domain/entities/car.dart';

// ══════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  CarStatus? _activeFilter; // null = ALL
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data — remplacer par CarProvider (Riverpod)
  // ✅ Utilise Car du domaine : brand/model/licensePlate/pricePerDay/status
  static final _allCars = [
    Car(
      id: 1,
      name: 'Porsche 911 Carrera',
      brand: 'Porsche',
      model: '911 Carrera',
      year: 2023,
      licensePlate: 'DE-992-GT',
      color: 'GT Silver',
      pricePerDay: 450,
      status: CarStatus.available,
      seats: 2,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.gasoline,
      images: [],
      isActive: true,
    ),
    Car(
      id: 2,
      name: 'BMW M4 Competition',
      brand: 'BMW',
      model: 'M4 Competition',
      year: 2023,
      licensePlate: 'NY-882-CP',
      color: 'Frozen Black',
      pricePerDay: 280,
      status: CarStatus.rented,
      seats: 4,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.gasoline,
      images: [],
      isActive: true,
    ),
    Car(
      id: 3,
      name: 'Audi RS7 Sportback',
      brand: 'Audi',
      model: 'RS7 Sportback',
      year: 2022,
      licensePlate: 'RS-007-AU',
      color: 'Nardo Grey',
      pricePerDay: 320,
      status: CarStatus.maintenance,
      seats: 5,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.gasoline,
      images: [],
      isActive: true,
    ),
    Car(
      id: 4,
      name: 'Mercedes G63 AMG',
      brand: 'Mercedes',
      model: 'G63 AMG',
      year: 2023,
      licensePlate: 'G-633-MB',
      color: 'Obsidian Black',
      pricePerDay: 600,
      status: CarStatus.available,
      seats: 5,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.gasoline,
      images: [],
      isActive: true,
    ),
    Car(
      id: 5,
      name: 'Tesla Model S Plaid',
      brand: 'Tesla',
      model: 'Model S Plaid',
      year: 2023,
      licensePlate: 'TS-001-EV',
      color: 'Pearl White',
      pricePerDay: 350,
      status: CarStatus.available,
      seats: 5,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.electric,
      images: [],
      isActive: true,
    ),
    Car(
      id: 6,
      name: 'Ferrari Roma',
      brand: 'Ferrari',
      model: 'Roma',
      year: 2022,
      licensePlate: 'FR-488-IT',
      color: 'Rosso Corsa',
      pricePerDay: 890,
      status: CarStatus.rented,
      seats: 2,
      transmission: TransmissionType.automatic,
      fuelType: FuelType.gasoline,
      images: [],
      isActive: true,
    ),
  ];

  List<Car> get _filtered {
    return _allCars.where((c) {
      final matchStatus = _activeFilter == null || c.status == _activeFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.licensePlate.toLowerCase().contains(q); // ✅ licensePlate (pas plate)
      return matchStatus && matchSearch;
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
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            Expanded(child: _buildCarList()),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fleet',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
              Text(
                '${_filtered.length} VEHICLES',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.sort_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              // TODO: navigate to add car screen
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search by model or plate...',
            hintStyle: GoogleFonts.outfit(fontSize: 15, color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 18),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────
  Widget _buildFilterChips() {
    // ✅ Utilise CarStatus du domaine directement
    final filters = <({String label, CarStatus? value})>[
      (label: 'ALL', value: null),
      (label: 'AVAILABLE', value: CarStatus.available),
      (label: 'RENTED', value: CarStatus.rented),
      (label: 'MAINTENANCE', value: CarStatus.maintenance),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final f = filters[i];
          final isActive = _activeFilter == f.value;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                f.label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Car List ───────────────────────────────────────────
  Widget _buildCarList() {
    final cars = _filtered;

    if (cars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 56, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text('Try adjusting your filters', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _CarCard(car: cars[i]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// CAR CARD WIDGET
// ══════════════════════════════════════════════════════════

class _CarCard extends StatelessWidget {
  final Car car;
  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(car.status);

    return GestureDetector(
      onTap: () {
        // TODO: context.push('/admin/cars/${car.id}')
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceVariant),
              child: ClipOval(
                child: Icon(Icons.directions_car_rounded, size: 36, color: AppColors.primary.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          car.name,
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(label: badge.label, textColor: badge.textColor, bgColor: badge.bgColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // ✅ licensePlate au lieu de plate
                  Text(
                    car.licensePlate,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              // ✅ pricePerDay au lieu de dailyPrice
                              text: '\$${car.pricePerDay.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: ' /day',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        car.status == CarStatus.maintenance ? Icons.settings_outlined : Icons.chevron_right_rounded,
                        color: car.status == CarStatus.maintenance ? AppColors.textHint : AppColors.primary,
                        size: 22,
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

  ({String label, Color textColor, Color bgColor}) _statusBadge(CarStatus status) {
    // ✅ Utilise CarStatus du domaine
    return switch (status) {
      CarStatus.available => (
          label: 'AVAILABLE',
          textColor: const Color(0xFF166534),
          bgColor: const Color(0xFFDCFCE7),
        ),
      CarStatus.rented => (
          label: 'RENTED',
          textColor: const Color(0xFF9A3412),
          bgColor: const Color(0xFFFFF7ED),
        ),
      CarStatus.maintenance => (
          label: 'MAINTENANCE',
          textColor: const Color(0xFF991B1B),
          bgColor: const Color(0xFFFEF2F2),
        ),
    };
  }
}

// ══════════════════════════════════════════════════════════
// STATUS BADGE WIDGET
// ══════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;

  const _StatusBadge({required this.label, required this.textColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.4),
      ),
    );
  }
}