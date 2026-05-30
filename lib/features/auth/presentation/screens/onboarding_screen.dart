import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart'; // ✅ Import AppColors

/// -------------------------------------------------------
/// ONBOARDING SCREEN — 3 pages swipables
/// -------------------------------------------------------

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() => context.go('/login');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // ✅ était Color(0xFFF8F7F4)
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_page > 0)
                    GestureDetector(
                      onTap: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: AppColors.primary, // ✅ était Color(0xFF3B5BDB)
                      ),
                    )
                  else
                    Text(
                      'FlotTrack',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary, // ✅ était Color(0xFF3B5BDB)
                        letterSpacing: -0.5,
                      ),
                    ),

                  if (_page > 0)
                    Text(
                      'FlotTrack',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary, // ✅ était Color(0xFF3B5BDB)
                        letterSpacing: -0.5,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  GestureDetector(
                    onTap: _goToLogin,
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        // ✅ était Color(0xFF3B5BDB).withValues(alpha: 0.4)
                        color: _page == 2
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ──────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _page1(),
                  _page2(),
                  _page3(),
                ],
              ),
            ),

            // ── Bottom : Dots + Button ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: _page == 0 ? _bottomPage1() : _bottomPages2and3(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAGE 1
  // ═══════════════════════════════════════════════════════
  Widget _page1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.textPrimary, // ✅ était Color(0xFF0A0A12) ≈ textPrimary
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/splash.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'PREMIER SELECTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppColors.primary.withValues(alpha: 0.7), // ✅
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Premium Car\nRental',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, // ✅ était Color(0xFF1A1A2E)
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the best fleet in the city with our curated collection of high-end performance vehicles.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary.withValues(alpha: 0.5), // ✅
              height: 1.6,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAGE 2
  // ═══════════════════════════════════════════════════════
  Widget _page2() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant, // ✅ était Color(0xFFE8E7E4)
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.3), // ✅
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Icon(
                      Icons.bolt,
                      size: 24,
                      color: AppColors.textSecondary.withValues(alpha: 0.4), // ✅ était Color(0xFF9CA3AF)
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15), // ✅ était Color(0xFFF0F2FF)
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.timer_outlined,
                        size: 48,
                        color: AppColors.primary, // ✅
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Easy Booking in\nSeconds',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, // ✅ était Color(0xFF1A1A2E)
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Select, book, and drive away. Our streamlined process puts the keys in your hands faster than ever.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary.withValues(alpha: 0.5), // ✅
              height: 1.6,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAGE 3
  // ═══════════════════════════════════════════════════════
  Widget _page3() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant, // ✅ était Color(0xFFF2F1EE)
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary, // ✅
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ACTIVE TRACKING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.textPrimary.withValues(alpha: 0.7), // ✅
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.location_on,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.5), // ✅ était Color(0xFF9CA3AF)
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Porsche Taycan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary, // ✅
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Electric Performance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary, // ✅ était Color(0xFF6B7280)
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.directions_car,
                                size: 24,
                                color: AppColors.primary.withValues(alpha: 0.7), // ✅
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 3,
                              backgroundColor: AppColors.divider, // ✅ était Color(0xFFE5E7EB)
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary), // ✅
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '12 MIN AWAY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: AppColors.textPrimary.withValues(alpha: 0.5), // ✅
                                ),
                              ),
                              Text(
                                '2.4 MILES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: AppColors.textPrimary.withValues(alpha: 0.5), // ✅
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Track Your\nReservations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, // ✅
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Real-time updates on your luxury ride. Experience precision engineering meets editorial design.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary.withValues(alpha: 0.5), // ✅
              height: 1.6,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM — Page 1
  // ═══════════════════════════════════════════════════════
  Widget _bottomPage1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDots(),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // ✅
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.35), // ✅
              padding: const EdgeInsets.symmetric(horizontal: 36),
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM — Pages 2 et 3
  // ═══════════════════════════════════════════════════════
  Widget _bottomPages2and3() {
    final isLast = _page == 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDots(centered: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // ✅
              foregroundColor: Colors.white,
              elevation: isLast ? 6 : 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.3), // ✅
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Next',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // DOTS
  // ═══════════════════════════════════════════════════════
  Widget _buildDots({bool centered = false}) {
    return Row(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: List.generate(3, (i) {
        final isActive = _page == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8),
          height: 4,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            // ✅ AppColors.primary au lieu de Color(0xFF3B5BDB)
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}