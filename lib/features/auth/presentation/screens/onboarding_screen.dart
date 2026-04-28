import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// -------------------------------------------------------
/// ONBOARDING SCREEN — 3 pages swipables
/// -------------------------------------------------------
/// Page 1 : "Premium Car Rental"
///   - Header : rRw (gauche) + SKIP (droite)
///   - Image voiture bleue sur fond noir (coins arrondis)
///   - Tag "PREMIER SELECTION"
///   - Titre + description
///   - Dots (barre active) + bouton "NEXT →" à droite
///
/// Page 2 : "Easy Booking in Seconds"
///   - Header : ← (retour) + rRw (centre) + SKIP (droite)
///   - Fond gris avec voiture en arrière-plan
///   - Carte blanche avec icône chrono "10"
///   - Titre centré + description centrée
///   - Dots centrés + bouton "Next" pleine largeur
///
/// Page 3 : "Track Your Reservations"
///   - Header : ← + rRw + SKIP (grisé)
///   - Carte avec "ACTIVE TRACKING", pin map,
///     card "Porsche Taycan / Electric Performance"
///     progress bar + "12 MIN AWAY" + "2.4 MILES"
///   - Titre + description
///   - Dots + bouton "Get Started" pleine largeur
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
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ← retour (page > 0)
                  if (_page > 0)
                    GestureDetector(
                      onTap: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: Color(0xFF3B5BDB),
                      ),
                    )
                  else
                    // Page 1 : logo rRw à gauche
                    const Text(
                      'FlotTrack',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B5BDB),
                        letterSpacing: -0.5,
                      ),
                    ),

                  // rRw centré (pages 2 et 3)
                  if (_page > 0)
                    const Text(
                      'FlotTrack',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B5BDB),
                        letterSpacing: -0.5,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // SKIP
                  GestureDetector(
                    onTap: _goToLogin,
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _page == 2
                            ? const Color(0xFF3B5BDB).withValues(alpha: 0.4)
                            : const Color(0xFF3B5BDB),
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
  // PAGE 1 — Premium Car Rental
  // ═══════════════════════════════════════════════════════
  Widget _page1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Image voiture sur fond noir
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A12),
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

          // Tag
          Text(
            'PREMIER SELECTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),

          // Titre
          const Text(
            'Premium Car\nRental',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Experience the best fleet in the city with our curated collection of high-end performance vehicles.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAGE 2 — Easy Booking in Seconds
  // ═══════════════════════════════════════════════════════
  Widget _page2() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Zone visuelle avec fond gris voiture
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E7E4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // TODO: Image voiture en arrière-plan
                  // Positioned.fill(
                  //   child: Image.asset('assets/images/onboarding_bg.png',
                  //     fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3)),
                  // ),

                  // Petite icône rRw en haut à gauche
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: const Color(0xFF3B5BDB).withValues(alpha: 0.3),
                    ),
                  ),

                  // Petite icône éclair en bas à droite
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Icon(
                      Icons.bolt,
                      size: 24,
                      color: const Color(0xFF9CA3AF).withValues(alpha: 0.4),
                    ),
                  ),

                  // Carte blanche avec icône chrono au centre
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        size: 48,
                        color: Color(0xFF3B5BDB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Titre centré
        const Text(
          'Easy Booking in\nSeconds',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Description centrée
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Select, book, and drive away. Our streamlined process puts the keys in your hands faster than ever.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAGE 3 — Track Your Reservations
  // ═══════════════════════════════════════════════════════
  Widget _page3() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Zone visuelle avec carte map
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F1EE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Badge "ACTIVE TRACKING"
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B5BDB),
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
                              color: const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pin map au centre
                  Center(
                    child: Icon(
                      Icons.location_on,
                      size: 80,
                      color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                    ),
                  ),

                  // Carte info "Porsche Taycan" en bas
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
                          // Nom + icône voiture
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Porsche Taycan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Electric Performance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.directions_car,
                                size: 24,
                                color: const Color(0xFF3B5BDB).withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 3,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B5BDB),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // "12 MIN AWAY" + "2.4 MILES"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '12 MIN AWAY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                '2.4 MILES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
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

        // Titre centré
        const Text(
          'Track Your\nReservations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Description centrée
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Real-time updates on your luxury ride. Experience precision engineering meets editorial design.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // BOTTOM — Page 1 (dots à gauche + NEXT → à droite)
  // ═══════════════════════════════════════════════════════
  Widget _bottomPage1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dots
        _buildDots(),

        // Bouton "NEXT →"
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: const Color(0xFF3B5BDB).withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(horizontal: 36),
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
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
  // BOTTOM — Pages 2 et 3 (dots centrés + bouton full width)
  // ═══════════════════════════════════════════════════════
  Widget _bottomPages2and3() {
    final isLast = _page == 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots centrés
        _buildDots(centered: true),
        const SizedBox(height: 24),

        // Bouton pleine largeur
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              elevation: isLast ? 6 : 4,
              shadowColor: const Color(0xFF3B5BDB).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Next',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // DOTS INDICATOR
  // ═══════════════════════════════════════════════════════
  Widget _buildDots({bool centered = false}) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: List.generate(3, (i) {
        final isActive = _page == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8),
          height: 4,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF3B5BDB)
                : const Color(0xFF3B5BDB).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}