import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 6,
                      color: const Color(0xFFB8B0FF).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logo "rRw"
                  Text(
                    'rRw',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 96,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -3,
                      color: const Color(0xFFCBC4FF),
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // "THE OBSIDIAN GALLERY"
                  Text(
                    'THE OBSIDIAN GALLERY',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),

                  const Spacer(flex: 5),

                  // ── Bouton "GET STARTED" ─────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/onboarding');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        minimumSize: const Size(double.infinity, 52),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'GET STARTED',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                          color: Colors.white.withValues(alpha: 0.9),
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
                            style: GoogleFonts.outfit(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Machined',
                            style: GoogleFonts.cormorantGaramond(
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
                            style: GoogleFonts.outfit(
                              fontSize: 7,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'MMXXIV',
                            style: GoogleFonts.outfit(
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