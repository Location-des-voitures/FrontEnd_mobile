import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  // ── Données mock ──────────────────────────────────────────
  static const _brands = [
    _BrandData('Mercedes', 'M'),
    _BrandData('Audi', 'A'),
    _BrandData('BMW', 'B'),
  ];

  static const _cars = [
    _CarData(
      name: 'BMW i4 M50',
      tag1Icon: Icons.bolt,
      tag1: 'ELECTRIC',
      tag2Icon: Icons.settings,
      tag2: '536 HP',
      price: 250,
      imagePath: 'assets/images/pexels-pixelazteca-12418700.jpg',
    ),
    _CarData(
      name: 'Audi A7 S-Line',
      tag1Icon: Icons.battery_charging_full,
      tag1: 'HYBRID',
      tag2Icon: Icons.person_outline,
      tag2: '5 SEATS',
      price: 185,
      imagePath: 'assets/images/josh-berquist-gCTHNfpeLiQ-unsplash.jpg',
    ),
  ];

  static const _features = [
    _FeatureData(Icons.shield_outlined, 'Seamless Booking',
        'Experience a fully digital, 5-minute checkout process.'),
    _FeatureData(Icons.diamond_outlined, 'Premium Privileges',
        'Priority support and airport lounge access included.'),
    _FeatureData(Icons.event_repeat_outlined, 'Change/Cancel',
        'Free cancellation up to 24h before pick-up.'),
    _FeatureData(Icons.battery_full_outlined, 'No Recharging',
        'Return at any battery level at no extra cost.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(child: _buildScrollBody()),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SCROLL BODY
  // ═══════════════════════════════════════════════════════

  Widget _buildScrollBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero + search card (avec overlap)
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(height: 340, child: _buildHero()),
              Positioned(
                top: 270,
                left: 20,
                right: 20,
                child: _buildSearchCard(),
              ),
            ],
          ),
          const SizedBox(height: 250),

          // Top Brands
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildTopBrands(),
          ),

          const SizedBox(height: 32),

          // Trending Now
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Text(
              'Trending Now',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ..._cars.map(
            (car) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _buildCarCard(car),
            ),
          ),

          const SizedBox(height: 16),

          // Features
          _buildFeaturesSection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/josh-berquist-gCTHNfpeLiQ-unsplash.jpg',
          fit: BoxFit.cover,
        ),
        // Gradient sombre
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xBB0A0A18), Color(0xDD0A0A18)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 28),
                Text(
                  'EXCLUSIVE FLEET',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium\nCar Rental',
                  style: GoogleFonts.roboto(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + greeting
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WELCOME',
                  style: GoogleFonts.roboto(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'Hello, Alexander',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Logo
        Text(
          'rRw',
          style: GoogleFonts.roboto(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        // Cloche
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
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
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // SEARCH CARD
  // ═══════════════════════════════════════════════════════

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: Column(
        children: [
          _searchRow(Icons.location_on_outlined, 'Pick up address'),
          _divider(),
          _searchRow(Icons.navigation_outlined, 'Drop off address'),
          _divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child:
                      _searchRow(Icons.calendar_today_outlined, 'Select Date'),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.divider,
                  indent: 8,
                  endIndent: 8,
                ),
                Expanded(
                  child: _searchRow(Icons.access_time_outlined, 'Select Time'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Search Fleet',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchRow(IconData icon, String hint) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textHint),
            const SizedBox(width: 10),
            Text(
              hint,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: AppColors.divider);

  // ═══════════════════════════════════════════════════════
  // TOP BRANDS
  // ═══════════════════════════════════════════════════════

  Widget _buildTopBrands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Brands',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'VIEW ALL',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: _brands
              .map((b) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildBrandItem(b),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBrandItem(_BrandData brand) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  brand.letter,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  bottom: 7,
                  right: 7,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brand.name,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // CAR CARD
  // ═══════════════════════════════════════════════════════

  Widget _buildCarCard(_CarData car) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 185,
                width: double.infinity,
                child: Image.asset(car.imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildTag(car.tag1Icon, car.tag1),
                            const SizedBox(width: 14),
                            _buildTag(car.tag2Icon, car.tag2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$${car.price}',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '/day',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'BOOK NOW',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.primary,
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

  Widget _buildTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // FEATURES SECTION
  // ═══════════════════════════════════════════════════════

  Widget _buildFeaturesSection() {
    return Container(
      color: const Color(0xFF111122),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 24,
        mainAxisSpacing: 28,
        childAspectRatio: 1.2,
        children: _features.map(_buildFeatureItem).toList(),
      ),
    );
  }

  Widget _buildFeatureItem(_FeatureData f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(f.icon, color: AppColors.primaryLight, size: 22),
        ),
        const SizedBox(height: 12),
        Text(
          f.title,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          f.description,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.45),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'HOME'),
      (Icons.search_rounded, 'SEARCH'),
      (Icons.calendar_month_rounded, 'BOOKINGS'),
      (Icons.person_rounded, 'PROFILE'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == _currentIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        size: 23,
                        color:
                            isActive ? AppColors.primary : AppColors.textHint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: GoogleFonts.roboto(
                          fontSize: 9,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.5,
                          color:
                              isActive ? AppColors.primary : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 16 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────

class _BrandData {
  const _BrandData(this.name, this.letter);
  final String name, letter;
}

class _CarData {
  const _CarData({
    required this.name,
    required this.tag1Icon,
    required this.tag1,
    required this.tag2Icon,
    required this.tag2,
    required this.price,
    required this.imagePath,
  });
  final String name, tag1, tag2, imagePath;
  final IconData tag1Icon, tag2Icon;
  final int price;
}

class _FeatureData {
  const _FeatureData(this.icon, this.title, this.description);
  final IconData icon;
  final String title, description;
}
