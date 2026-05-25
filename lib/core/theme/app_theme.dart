/// -------------------------------------------------------
/// APP THEME — Aligné sur les maquettes rRw
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════
// COULEURS (corrigées selon les maquettes)
// ═══════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── Couleurs principales ─────────────────────────────
  // Bleu vif des boutons, liens, bottom nav active
  static const Color primary = Color(0xFF3B5BDB);        // Bleu vif (boutons, CTA)
  static const Color primaryLight = Color(0xFF5B7CF7);    // Bleu clair (hover, badges)
  static const Color primaryDark = Color(0xFF2B44A8);     // Bleu foncé (pressed state)

  // ── Couleurs de fond ─────────────────────────────────
  // Fond crème/beige léger visible dans toutes les maquettes
  static const Color background = Color(0xFFF8F7F4);      // Crème très léger
  static const Color surface = Color(0xFFFFFFFF);          // Blanc (cards, modals)
  static const Color card = Color(0xFFFFFFFF);             // Blanc
  static const Color surfaceVariant = Color(0xFFF2F1EE);   // Crème pour les sections

  // ── Texte ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);     // Titres, texte principal
  static const Color textSecondary = Color(0xFF6B7280);   // Sous-titres, labels
  static const Color textHint = Color(0xFF9CA3AF);        // Placeholders, hints

  // ── Statuts ──────────────────────────────────────────
  static const Color success = Color(0xFF10B981);         // Vert (ACTIVE, AVAILABLE)
  static const Color warning = Color(0xFFF59E0B);         // Jaune/Or (PENDING, DUE SOON)
  static const Color error = Color(0xFFEF4444);           // Rouge (REFUSED, CANCELLED, OVERDUE)
  static const Color info = Color(0xFF3B82F6);            // Bleu info (RESERVED, CONFIRMED)

  // ── Statuts de réservation ───────────────────────────
  static const Color statusPending = Color(0xFFF59E0B);   // Jaune/Or — PENDING
  static const Color statusConfirmed = Color(0xFF3B82F6); // Bleu — CONFIRMED/RESERVED
  static const Color statusActive = Color(0xFF10B981);    // Vert — ACTIVE
  static const Color statusCompleted = Color(0xFF6B7280); // Gris — COMPLETED
  static const Color statusCancelled = Color(0xFFEF4444); // Rouge — CANCELLED/REFUSED
  static const Color statusRented = Color(0xFFF59E0B);    // Jaune/Or — RENTED (cars)
  static const Color statusMaintenance = Color(0xFFEF4444); // Rouge — MAINTENANCE (cars)

  // ── Alertes spéciales ────────────────────────────────
  // Orange/brun foncé pour les bannières d'alerte
  // (Double Booking, Overlapping schedule)
  static const Color alertBanner = Color(0xFFC4621A);     // Orange brun (bannière alerte)
  static const Color alertBannerBg = Color(0xFFE8751F);   // Fond bannière alerte

  // ── Boutons Accept/Refuse ────────────────────────────
  static const Color acceptButton = Color(0xFF10B981);    // Vert — Accept
  static const Color refuseButton = Color(0xFFEF4444);    // Rouge — Refuse
  static const Color editButton = Color(0xFF3B5BDB);      // Bleu — Edit
  static const Color deleteButton = Color(0xFFDC2626);    // Rouge foncé — Delete

  // ── Divers ───────────────────────────────────────────
  static const Color divider = Color(0xFFE8E7E4);         // Beige/gris léger
  static const Color shadow = Color(0x0D000000);           // Ombre très légère
  static const Color starRating = Color(0xFFF59E0B);       // Étoiles dorées (clients)
}

// ═══════════════════════════════════════════════════════
// STYLES DE TEXTE
// ═══════════════════════════════════════════════════════

class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ── Body ─────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Labels ───────────────────────────────────────────
  // Labels en UPPERCASE tracking élevé (comme dans les maquettes)
  static const TextStyle labelUppercase = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
    height: 1.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ── Prix ─────────────────────────────────────────────
  static const TextStyle price = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ── Prix en vert (revenue, total paid) ───────────────
  static const TextStyle priceGreen = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );
}

// ═══════════════════════════════════════════════════════
// DIMENSIONS & ESPACEMENTS
// ═══════════════════════════════════════════════════════

class AppSizes {
  AppSizes._();

  // ── Padding ──────────────────────────────────────────
  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 16;
  static const double paddingLG = 24;
  static const double paddingXL = 32;

  // ── Border Radius ────────────────────────────────────
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 100;

  // ── Tailles d'icônes ─────────────────────────────────
  static const double iconSM = 18;
  static const double iconMD = 24;
  static const double iconLG = 32;

  // ── Hauteur des boutons ──────────────────────────────
  static const double buttonHeight = 52;
  static const double inputHeight = 52;

  // ── Bottom Navigation Bar ────────────────────────────
  static const double bottomNavHeight = 64;
}

// ═══════════════════════════════════════════════════════
// THÈME MATERIAL (à passer dans MaterialApp)
// ═══════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  /// Thème clair (principal) — aligné sur les maquettes rRw
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.roboto().fontFamily,

      // ── Color Scheme ─────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ───────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // ── Boutons ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      // ── Input Fields ─────────────────────────────────
      // Style "underline" comme dans les maquettes signup/login
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: AppSizes.paddingMD,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.labelUppercase,
        floatingLabelStyle: AppTextStyles.labelUppercase.copyWith(
          color: AppColors.primary,
        ),
      ),

      // ── Cards ────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingSM),
      ),

      // ── Bottom Nav ───────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // ── Chips (filtres brand, status) ────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divider ──────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Snackbar ─────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      ),

      // ── Tab Bar (Active/Completed/Cancelled) ─────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}