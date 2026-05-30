/// -------------------------------------------------------
/// CLIENT HOME SCREEN — FlotTrack
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _scrollController = ScrollController();
  bool _headerSolid = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final solid = _scrollController.offset > 80;
      if (solid != _headerSolid) setState(() => _headerSolid = solid);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F8),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          children: [
            _HeroSection(),
            _SearchSection(),
            _BrandsSection(),
            _TrendingSection(),
            _FeaturesBar(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _headerSolid
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // Avatar + greeting
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE5E2E1),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA-_8rinL0FKB4Au8eg-OhSqQjrfljPeUVmcJuGhLoGUpwpvWkJFbf1Eqo_iAITg1uhkMhVJ0H-mQX6YyIXWrqbRVL35ctMUnBZVzHoN2Rvy-Ecate2HjmKi64WtAfv7KJFB1RXYhVdqqCs-v6IqK-Vafdnuo3XsJiBI5GBX8nbPA6EQDjEUK2_kkrHGRlfcYSEi-myhntE9EGpzhAOZ1f6JnMZzTcszbqvhjxaPy5fh3pzfKre14ksNqE81q53O1HUNc7q3wXVo-NA',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WELCOME',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: _headerSolid
                            ? const Color(0xFF78716C)
                            : Colors.white60,
                      ),
                    ),
                    Text(
                      'Hello, Alexander',
                      style: GoogleFonts.inter(
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
                // Brand
                Text(
                  'FlotTrack',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: _headerSolid
                        ? const Color(0xFF1C1B1B)
                        : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Notification
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
          // Background image
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDZq8YxgMcHPBzxfMIr7UImdiJS92O_N1sUZrxBESZvfNz8U_kRHr7FaKEasrnf53HLEYuqItGqmcOalBSyj1unimvu6xI-bMs6F45sR6RQSBFSNrXIUflF4EGdJnJSvkvfy6KzsTpqrP9FqIFdkE5Pb-cSIpJWpZ8L91k__MhPo6buzOH0Ix15TvJzVQ5moTELpd1DkHl-3u9OUsX97ekkbAxkWi-qsVZTXZoAmZcUXARgQ-cU_kYFByCpB0tyVnI2u3mkadUCHkWr',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1C1B1B),
              child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 80),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF1C1B1B),
                ],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXCLUSIVE FLEET',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                    color: const Color(0xFF264DD9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium\nCar Rental',
                  style: GoogleFonts.manrope(
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
              // Pick up
              _SearchField(
                icon: Icons.location_on_outlined,
                hint: 'Pick up address',
              ),
              const SizedBox(height: 4),
              // Drop off
              _SearchField(
                icon: Icons.near_me_outlined,
                hint: 'Drop off address',
              ),
              const SizedBox(height: 4),
              // Date + Time
              Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      icon: Icons.calendar_month_outlined,
                      hint: 'Select Date',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SearchField(
                      icon: Icons.schedule_outlined,
                      hint: 'Select Time',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search button
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
                    child: Text(
                      'Search Fleet',
                      style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF1C1B1B)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF9CA3AF)),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFFC4C5D7), width: 0.5),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFFC4C5D7), width: 0.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xFF264DD9), width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
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
  static const _brands = [
    _Brand('Mercedes', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDSc_bCCPIvPwBm4bYvA5h8Bj6lfz0E_s-jOMRIrlbtf4uuTxlz1Xqr1nt0W0JZN2rQIXb9SA6dd3Iy1QnvAqS_XanzhdOrpduKtMkSyptzR9b_JD4BWnQsWZdBBfAXTV9roudKbb9jPsg11gjh_qHqqSc7JEgmh867CN-mF-MZ3KyjlA4bzsXtxIs63R0zNHHk8Otzzrotv3gFaMwvUmJwXAd7pTTRW_AG2UC01QtyZj49iCdomxOMY-Df5C59BZ_7rbM4d7LQAeaR'),
    _Brand('Audi',     'https://lh3.googleusercontent.com/aida-public/AB6AXuD7ZXKgwgBw6iSz51oE9fg4rhRjxzplGgC9RRP9988eIjE1CqMg3_4WXFFpLnQbsKfr3lkkFZSklYvwPZJN-Tq4tbXyI9cj8ehsW3rJ6Aj75owa4I7PhoRSsSgjWJClrzkFSps4_Lg44Ax1WFaLMwiUN8uKCMe23qXierWAPlilDbZ8_jpbyZY_ihSfLwZ1JkeyK9z4hRHpzvcLk4YmUkw5KCgLDzM4F3Zp15D5barlIcCncbzBbwdeoWQhOpvTvQsQ3km-bpLLGKsg'),
    _Brand('BMW',      'https://lh3.googleusercontent.com/aida-public/AB6AXuBFzgvMMnP3bWDVrLNVEtTmTuLUaRo3eG8X8kjj_JxZPt-e19gCXErktGQk0fB7GFeZ7dgrMU9X1LP0JqO5t6Exqk7_VzZrZE1egdJoRNSBvygjtE3hfsKW5BzaQwcFjxiq859wTKaKQSVdSdTfKGROFY7r8HRxA7YZEqV9Vc80goVj9doGdxJB4CfjrdnuF66L6sp6MAcZiuxGODgQcxWojgc7Rv7-YjJzQgQPzwdzheRm62x7NZikhkyS0Gvf-qWBMD3XNErz3Ihf'),
    _Brand('Porsche',  'https://lh3.googleusercontent.com/aida-public/AB6AXuC9BekhhO3N_jisVDxi6w3joR9MGNfDoJ79Rus1w16DFIcc9U6HewI2dbiKDWULjoHCpZ6HeBC1T--h_pvO8YlUZ2_sKLd4igTaMmrjrKjwc0HhEthBhERKRoU5MzrzxZb1tUZ1oYw5HXHctgzZp_4klDpfhY-MeTyiydRoeHWuvgVdfE7ZKGiMWCYcj8kGdVOHG7EM_ygmTzZxv2w_YctHc9Pl7_7Bwk-5wtRHZWb80KeJCOfzqXuD020-Q63se4D8Uve6lJHshXlS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Top Brands',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1C1B1B),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'VIEW ALL',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: const Color(0xFF264DD9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _BrandCard(brand: _brands[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand {
  final String name;
  final String logoUrl;
  const _Brand(this.name, this.logoUrl);
}

class _BrandCard extends StatelessWidget {
  final _Brand brand;
  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3F2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Image.network(
                brand.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_car_outlined,
                    size: 24,
                    color: Color(0xFF9CA3AF)),
              ),
            ),
            // Name + Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  brand.name,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1B1B),
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    size: 16, color: Color(0xFF264DD9)),
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
  static final _cars = [
    _CarData(
      name: 'BMW i4 M50',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAWAosPt_fWZykhH77K9UcnvEePACH5vvAPlywAOi_ww0aqC7SVff5uzbTMD-8g_rEDDvYSFMOX0N87VnInKiXAk-t1fEVHHEDPmVQ_83bTxzB-tgl4p0tp7XNSUw9myKiTAqVn5-d6xm5s3xySdyGv3MWyN6XdWsdJvGGqAgR65YBKsny_u6RRmY8QsTYF9_M0NUXxdQMth10-CATujgKcEQYX2oJ7gpAW6ygXjSaandtLK6hO8siYZBxt9ccA1iF0xT3iAFWMtedr',
      spec1Icon: Icons.bolt,
      spec1: 'Electric',
      spec2Icon: Icons.speed,
      spec2: '536 HP',
      price: 250,
    ),
    _CarData(
      name: 'Audi A7 S-Line',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5zS6Q3AKiQWYsoEwJ_PFGa3fJTHJtmBTUFsWlkf0vcJxiuTzrqRNzwrnGNiLWqtSbC18aMlbba5PCsNWpyi5EXBVw0jc0rLtRGTlbGIWpKGusQLS48PEQq8UasEnAUxloRZLBbyHX3_wduW_bycVAQfCxlvmPeIROayTkzh4c_uxazVDDUbgQUmPEG5wDqYxjN24kzSQiaPgV_7eX1cTzJ6kLpgbKtbsNG1DPsfnJXtEAnfR1-qw3Z2sd9JP2IB1iyjZXFJKl5fy0',
      spec1Icon: Icons.local_gas_station,
      spec1: 'Hybrid',
      spec2Icon: Icons.event_seat_outlined,
      spec2: '5 Seats',
      price: 185,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Now',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1B1B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          ..._cars.map((car) => Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: _CarCard(car: car),
              )),
        ],
      ),
    );
  }
}

class _CarData {
  final String name;
  final String imageUrl;
  final IconData spec1Icon;
  final String spec1;
  final IconData spec2Icon;
  final String spec2;
  final int price;

  const _CarData({
    required this.name,
    required this.imageUrl,
    required this.spec1Icon,
    required this.spec1,
    required this.spec2Icon,
    required this.spec2,
    required this.price,
  });
}

class _CarCard extends StatelessWidget {
  final _CarData car;
  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 192,
            width: double.infinity,
            child: Image.network(
              car.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF0EDEC),
                child: const Center(
                  child: Icon(Icons.directions_car_outlined,
                      size: 64, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name + specs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C1B1B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _SpecBadge(icon: car.spec1Icon, label: car.spec1),
                      const SizedBox(width: 16),
                      _SpecBadge(icon: car.spec2Icon, label: car.spec2),
                    ],
                  ),
                ],
              ),
            ),
            // Price + button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${car.price}',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1B1B),
                        ),
                      ),
                      TextSpan(
                        text: '/day',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF78716C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    side: const BorderSide(
                        color: Color(0xFFC4C5D7), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'BOOK NOW',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: const Color(0xFF1C1B1B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
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
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: const Color(0xFF78716C),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// FEATURES BAR (dark section)
// ═══════════════════════════════════════════════════════

class _FeaturesBar extends StatelessWidget {
  static const _features = [
    _Feature(Icons.verified_user_outlined, 'Seamless Booking',
        'Experience a fully digital, 5-minute checkout process.'),
    _Feature(Icons.diamond_outlined, 'Premium Privileges',
        'Priority support and airport lounge access included.'),
    _Feature(Icons.event_repeat_outlined, 'Change/Cancel',
        'Free cancellation up to 24h before pick-up.'),
    _Feature(Icons.electric_car_outlined, 'No Recharging',
        'Return at any battery level at no extra cost.'),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(feature.icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 14),
        Text(
          feature.title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          feature.description,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF9CA3AF),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}