/// -------------------------------------------------------
/// APP CONSTANTS — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------

class AppConstants {
  AppConstants._();

  // ── Nom de l'app ─────────────────────────────────────
  static const String appName = 'rRw';

  // ── Rôles (3 rôles dans le système) ──────────────────
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleClient = 'client';

  // ── Clés de stockage sécurisé (FlutterSecureStorage) ─
  static const String tokenKey = 'auth_token';
  static const String tokenTypeKey = 'token_type';     // "bearer"
  static const String userKey = 'user_data';            // User JSON stringifié

  // ── Clés SharedPreferences ───────────────────────────
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // ── Token ────────────────────────────────────────────
  // Le token JWT expire après 3600 secondes (1h)
  // selon la doc API : "expires_in": 3600
  static const int tokenExpiresIn = 3600;

  // ── Pagination ───────────────────────────────────────
  // Valeur par défaut côté API : 15 items/page
  static const int defaultPageSize = 15;

  // ── Formats de date ──────────────────────────────────
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  // Format de date retourné par l'API Laravel
  static const String apiDateFormat = 'yyyy-MM-dd HH:mm:ss';

  // ── Devise ───────────────────────────────────────────
  static const String currency = 'DH';

  // ── Admin creation strategies ────────────────────────
  // POST /api/admins → notify_via
  static const String notifyPasswordReset = 'password_reset';
  static const String notifyCredentials = 'credentials';
}