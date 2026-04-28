import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart' show AppColors;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image de fond ────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/WhatsApp Image 2026-04-20 at 23.20.59.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // ── Gradient sombre par-dessus ───────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A12).withValues(alpha: 0.4),
                    const Color(0xFF0A0A12).withValues(alpha: 0.15),
                    const Color(0xFF0A0A12).withValues(alpha: 0.4),
                    const Color(0xFF0A0A12).withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  // "ELITE CONCIERGE"
                  Text(
                    'ELITE CONCIERGE',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logo "rRw"
                 FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    'FlotTrack',
    style: GoogleFonts.roboto(
      fontSize: 80,
      fontWeight: FontWeight.w700,
      letterSpacing: -2,
      color: const Color(0xFFB8B8D4).withValues(alpha: 0.8),
      height: 0.9,
    ),
  ),
),

                  // "THE OBSIDIAN GALLERY"
                  Text(
                    'THE OBSIDIAN GALLERY',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(flex: 5),

                  // ── Bouton "GET STARTED" ─────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/onboarding');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'GET STARTED',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Footer ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gauche : PRECISION / Machined
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRECISION',
                            style: GoogleFonts.roboto(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Machined',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                      // Droite : EST. / MMXXIV
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EST.',
                            style: GoogleFonts.roboto(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'MMXXIV',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}