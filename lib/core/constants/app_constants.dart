/// -------------------------------------------------------
/// APP CONSTANTS — FlotTrack
/// -------------------------------------------------------
library;

class AppConstants {
  AppConstants._();

  // ── Nom de l'app ─────────────────────────────────────
  static const String appName = 'FlotTrack';

  // ── Rôles ────────────────────────────────────────────
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleClient = 'client';

  // ── Clés de stockage sécurisé ────────────────────────
  static const String tokenKey = 'flottrack_token';
  static const String refreshTokenKey = 'flottrack_refresh_token';
  static const String userKey = 'flottrack_user_data';

  // ── Clés SharedPreferences ───────────────────────────
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // ── Token ────────────────────────────────────────────
  static const int tokenLifetimeSeconds = 3600; // 60 minutes

  // ── OTP ──────────────────────────────────────────────
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int otpMaxAttempts = 5;

  // ── Pagination ───────────────────────────────────────
  static const int defaultPageSize = 15;
  static const int maxPageSize = 100;

  // ── Formats de date ──────────────────────────────────
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // ── Devise ───────────────────────────────────────────
  static const String currency = 'MAD';

  // ── Plans d'abonnement ───────────────────────────────
  static const String planFree = 'free';
  static const String planPro = 'pro';
  static const String planPremium = 'premium';

  static const Map<String, double> planPrices = {
    'free': 0.0,
    'pro': 99.0,
    'premium': 199.0,
  };

  // ── Subscription statuts ─────────────────────────────
  static const String subscriptionActive = 'active';
  static const String subscriptionExpired = 'expired';
  static const String subscriptionCancelled = 'cancelled';
}