import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// MODEL — données issues de la réponse API POST /reservations
// ─────────────────────────────────────────────────────────────

class BookingConfirmation {
  final int reservationId;
  final String reference;       // ex: "#RRW-98234"
  final String carName;         // ex: "Mercedes-Benz GLE"
  final String? carImageUrl;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String? pickupTime;     // ex: "10:00 AM"
  final String? returnTime;     // ex: "10:00 AM"
  final String? location;       // ex: "Lax International Airport"
  final double totalAmount;
  final String status;          // "pending" | "confirmed" | "approved"

  BookingConfirmation({
    required this.reservationId,
    required this.reference,
    required this.carName,
    this.carImageUrl,
    required this.pickupDate,
    required this.returnDate,
    this.pickupTime,
    this.returnTime,
    this.location,
    required this.totalAmount,
    required this.status,
  });

  /// Build from the API response data object (POST /api/client/reservations → 201)
  factory BookingConfirmation.fromApiResponse({
    required Map<String, dynamic> data,
    required String carName,
    String? carImageUrl,
    String? location,
  }) {
    final id = data['id'] as int;
    // Generate a display reference from id if none returned
    final ref = data['reference'] as String? ?? '#RRW-${id.toString().padLeft(5, '0')}';

    return BookingConfirmation(
      reservationId: id,
      reference: ref,
      carName: carName,
      carImageUrl: carImageUrl,
      pickupDate: DateTime.parse(data['start_date'] as String),
      returnDate: DateTime.parse(data['end_date'] as String),
      pickupTime: data['pickup_time'] as String?,
      returnTime: data['return_time'] as String?,
      location: location,
      totalAmount: double.tryParse(data['total_amount'].toString()) ?? 0,
      status: data['status'] as String? ?? 'pending',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class BookingConfirmationScreen extends StatefulWidget {
  final BookingConfirmation booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _checkScale = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _contentFade = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    ));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────

  String _fmtDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: Text(
          'CONFIRMATION',
          style: AppTextStyles.labelUppercase.copyWith(
            fontSize: 12,
            color: AppColors.textPrimary,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // ── Animated check icon ───────────────────
            ScaleTransition(
              scale: _checkScale,
              child: _buildCheckIcon(),
            ),

            const SizedBox(height: 28),

            // ── Title + subtitle ──────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _buildTitle(b),
              ),
            ),

            const SizedBox(height: 28),

            // ── Booking card ──────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBookingCard(b),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Actions ───────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildActions(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Car image decoration ──────────────────
            FadeTransition(
              opacity: _contentFade,
              child: _buildCarDecoration(b),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // CHECK ICON
  // ─────────────────────────────────────────────────────

  Widget _buildCheckIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // TITLE
  // ─────────────────────────────────────────────────────

  Widget _buildTitle(BookingConfirmation b) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'Booking Confirmed!',
            style: AppTextStyles.h1.copyWith(fontSize: 26),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your luxury ride is ready. We\'ve sent a\nconfirmation email to your inbox.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BOOKING CARD
  // ─────────────────────────────────────────────────────

  Widget _buildBookingCard(BookingConfirmation b) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle
            Text(
              'VEHICLE',
              style: AppTextStyles.labelUppercase.copyWith(
                fontSize: 10,
                color: AppColors.textHint,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(b.carName, style: AppTextStyles.h2.copyWith(fontSize: 22)),

            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 18),

            // Pick up + Return row
            Row(
              children: [
                Expanded(
                  child: _dateBlock(
                    label: 'PICK UP',
                    date: _fmtDate(b.pickupDate),
                    time: b.pickupTime ?? '10:00 AM',
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _dateBlock(
                    label: 'RETURN',
                    date: _fmtDate(b.returnDate),
                    time: b.returnTime ?? '10:00 AM',
                  ),
                ),
              ],
            ),

            if (b.location != null) ...[
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 16),
              Text(
                'LOCATION',
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b.location!,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 18),

            // Reference + Total
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFERENCE',
                      style: AppTextStyles.labelUppercase.copyWith(
                        fontSize: 10,
                        color: AppColors.textHint,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.reference,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL PAID',
                      style: AppTextStyles.labelUppercase.copyWith(
                        fontSize: 10,
                        color: AppColors.textHint,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${b.totalAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(fontSize: 26),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBlock({required String label, required String date, required String time}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelUppercase.copyWith(
            fontSize: 10,
            color: AppColors.textHint,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          date,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────────────

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to bookings list screen
              // Navigator.pushReplacementNamed(context, '/bookings');
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
            child: const Text(
              'View My Bookings',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // CAR DECORATION (bottom)
  // ─────────────────────────────────────────────────────

  Widget _buildCarDecoration(BookingConfirmation b) {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Ellipse shadow under car
          Positioned(
            bottom: 0,
            child: Container(
              width: 240,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          // Car image (grayscale + low opacity for decoration)
          if (b.carImageUrl != null)
            Positioned(
              bottom: 10,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      0.25, 0,
                ]),
                child: Image.network(
                  b.carImageUrl!,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            )
          else
            Positioned(
              bottom: 10,
              child: Opacity(
                opacity: 0.18,
                child: const Icon(
                  Icons.directions_car,
                  size: 110,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}