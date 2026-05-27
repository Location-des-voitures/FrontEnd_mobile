/// -------------------------------------------------------
/// CAR DETAIL SCREEN — FlotTrack Loueur
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// ✅ Import des vraies entités du domaine (suppression des doublons locaux)
import '../../domain/entities/car.dart';
import '../../domain/entities/reservation.dart';

// ══════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════

class CarDetailScreen extends StatefulWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  // Mock data — remplacer par CarProvider (Riverpod)
  // ✅ Utilise Car du domaine : brand/model/licensePlate/pricePerDay/status/fuelType/transmission
  final Car _car = Car(
    id: 1,
    name: 'Mercedes C-Class',
    brand: 'Mercedes',
    model: 'C-Class 220',
    year: 2023,
    licensePlate: 'ABC-1234',      // ✅ licensePlate (pas plate)
    color: 'Obsidian Black',
    pricePerDay: 120,              // ✅ pricePerDay (pas dailyPrice)
    status: CarStatus.available,
    seats: 5,
    transmission: TransmissionType.automatic,
    fuelType: FuelType.gasoline,   // ✅ FuelType.gasoline (pas 'Gas')
    images: [],
    isActive: true,
  );

  // ✅ Utilise Reservation du domaine
  final List<Reservation> _reservations = [
    Reservation(
      id: 101,
      carId: 1,
      carName: 'Mercedes C-Class',
      carLicensePlate: 'ABC-1234',
      clientId: 1,
      clientName: 'Julian Alexander',
      clientEmail: 'julian@example.com',
      startDate: DateTime(2024, 12, 12),
      endDate: DateTime(2024, 12, 15),
      totalPrice: 360.00,
      status: ReservationStatus.completed,
    ),
    Reservation(
      id: 102,
      carId: 1,
      carName: 'Mercedes C-Class',
      carLicensePlate: 'ABC-1234',
      clientId: 2,
      clientName: 'Sophia Martinez',
      clientEmail: 'sophia@example.com',
      startDate: DateTime(2024, 11, 28),
      endDate: DateTime(2024, 11, 30),
      totalPrice: 240.00,
      status: ReservationStatus.completed,
    ),
  ];

  late CarStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = _car.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHero(context)),
              SliverToBoxAdapter(child: _buildBody()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDeleteBar(context),
          ),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1628), Color(0xFF020617), Color(0xFF101828)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 90,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(Icons.directions_car_rounded, size: 140, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF020617)],
                ),
              ),
            ),
          ),
          // ✅ Chips : year / fuelType.name / pricePerDay
          Positioned(
            bottom: 60,
            left: 20,
            child: Row(
              children: [
                _HeroChip(label: 'YEAR', value: '${_car.year}'),
                const SizedBox(width: 10),
                // ✅ fuelType.name retourne 'gasoline', 'electric', etc.
                _HeroChip(label: 'FUEL', value: _car.fuelType.name.toUpperCase()),
                const SizedBox(width: 10),
                _HeroChip(label: '/DAY', value: '\$${_car.pricePerDay.toInt()}'),
              ],
            ),
          ),
          Positioned(
            bottom: 18,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _car.name,
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                ),
                const SizedBox(height: 3),
                // ✅ licensePlate
                Text(
                  _car.licensePlate,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.55), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop()),
                    Text('Vehicle Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    _NavButton(icon: Icons.edit_outlined, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────
  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusControl(),
            const SizedBox(height: 28),
            _buildSpecifications(),
            const SizedBox(height: 28),
            _buildRecentReservations(),
          ],
        ),
      ),
    );
  }

  // ── Status Control ─────────────────────────────────────
  Widget _buildStatusControl() {
    // ✅ Utilise CarStatus du domaine directement
    final statuses = [
      (status: CarStatus.available, label: 'Available'),
      (status: CarStatus.rented, label: 'Rented'),
      (status: CarStatus.maintenance, label: 'Maintenance'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: statuses.map((s) {
          final isActive = _currentStatus == s.status;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentStatus = s.status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.label,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Specifications ─────────────────────────────────────
  Widget _buildSpecifications() {
    // ✅ Toutes les propriétés viennent du domaine Car
    final specs = [
      (icon: Icons.business_outlined, label: 'Brand', value: _car.brand),
      (icon: Icons.directions_car_outlined, label: 'Model', value: _car.model),
      (icon: Icons.pin_outlined, label: 'Plate', value: _car.licensePlate),
      (icon: Icons.palette_outlined, label: 'Color', value: _car.color),
      (icon: Icons.airline_seat_recline_normal_outlined, label: 'Seats', value: '${_car.seats}'),
      (icon: Icons.settings_outlined, label: 'Transmission', value: _car.transmission.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Specifications', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: List.generate(specs.length, (i) {
              final s = specs[i];
              final isLast = i == specs.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(s.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Text(s.label,
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        const Spacer(),
                        Text(s.value,
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, thickness: 0.8, indent: 70, endIndent: 16, color: AppColors.divider),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Recent Reservations ────────────────────────────────
  Widget _buildRecentReservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Reservations',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            GestureDetector(
              onTap: () {},
              child: Text('View All',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_reservations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('No reservations yet',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint)),
            ),
          )
        else
          ...List.generate(_reservations.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i < _reservations.length - 1 ? 14 : 0),
              child: _ReservationCard(reservation: _reservations[i]),
            );
          }),
      ],
    );
  }

  // ── Delete Bar ─────────────────────────────────────────
  Widget _buildDeleteBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: GestureDetector(
        onTap: () => _showDeleteConfirmation(context),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(color: AppColors.deleteButton, width: 1.5),
          ),
          child: Center(
            child: Text('Delete Vehicle',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.deleteButton)),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Delete Vehicle?',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone. All data\nassociated with this vehicle will be lost.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
                      child: Center(
                        child: Text('Cancel',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: call DeleteCarUsecase via provider
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text('Delete',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// HERO CHIP
// ══════════════════════════════════════════════════════════

class _HeroChip extends StatelessWidget {
  final String label;
  final String value;
  const _HeroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// NAV BUTTON
// ══════════════════════════════════════════════════════════

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// RESERVATION CARD
// ══════════════════════════════════════════════════════════

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  // ✅ initials vient de l'entité Reservation directement
                  child: Text(
                    reservation.initials,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ clientName
                    Text(reservation.clientName,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    // ✅ Construit la plage de dates depuis startDate/endDate
                    Text(
                      '${_formatDate(reservation.startDate)} - ${_formatDate(reservation.endDate)}',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              _ReservationBadge(status: reservation.status),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
              // ✅ totalPrice
              Text(
                '\$${reservation.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ══════════════════════════════════════════════════════════
// RESERVATION BADGE — utilise ReservationStatus du domaine
// ══════════════════════════════════════════════════════════

class _ReservationBadge extends StatelessWidget {
  final ReservationStatus status;
  const _ReservationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, String label) = switch (status) {
      ReservationStatus.completed     => (const Color(0xFFFEF2F2), const Color(0xFFEF4444), 'COMPLETED'),
      ReservationStatus.confirmed     => (const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'CONFIRMED'),
      ReservationStatus.pending       => (const Color(0xFFFFFBEB), const Color(0xFFF59E0B), 'PENDING'),
      ReservationStatus.awaitingPayment => (const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'AWAITING'),
      ReservationStatus.cancelled     => (AppColors.surfaceVariant, AppColors.textSecondary, 'CANCELLED'),
      ReservationStatus.rejected      => (const Color(0xFFFEF2F2), const Color(0xFFEF4444), 'REJECTED'),
      _                               => (AppColors.surfaceVariant, AppColors.textSecondary, 'ACTIVE'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: text, letterSpacing: 0.3)),
    );
  }
}