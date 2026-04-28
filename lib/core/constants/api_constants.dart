/// -------------------------------------------------------
/// API CONSTANTS — FlotTrack API v1.0
/// -------------------------------------------------------
/// Aligné sur la documentation officielle de l'API.
/// Base URL : http://localhost:8000/api
/// Auth : Bearer JWT (60 minutes)
/// -------------------------------------------------------
library;

class ApiConstants {
  ApiConstants._();

  // ── URL de base ──────────────────────────────────────
  static const String baseUrl = 'http://localhost:8000/api';

  // ── Timeout ──────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════
  // AUTH (Public)
  // ═══════════════════════════════════════════════════════
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';

  // ── Auth Google ──────────────────────────────────────
  static const String googleRedirect = '/auth/google/redirect';
  static const String googleMobile = '/auth/google/mobile';

  // ── Auth (Protected) ────────────────────────────────
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // ═══════════════════════════════════════════════════════
  // SUPER ADMIN — User Management
  // ═══════════════════════════════════════════════════════
  static const String users = '/admin/users';
  static String userById(int id) => '/admin/users/$id';
  static String activateUser(int id) => '/admin/users/$id/activate';
  static String deactivateUser(int id) => '/admin/users/$id/deactivate';
  static String deleteUser(int id) => '/admin/users/$id';

  // ═══════════════════════════════════════════════════════
  // SUPER ADMIN — Admin Management (Loueurs)
  // ═══════════════════════════════════════════════════════
  static const String admins = '/admin/admins';
  static String adminById(int id) => '/admin/admins/$id';
  static const String createAdmin = '/admin/admins';
  static String activateAdmin(int id) => '/admin/admins/$id/activate';
  static String suspendAdmin(int id) => '/admin/admins/$id/suspend';
  static String deleteAdmin(int id) => '/admin/admins/$id';

  // ═══════════════════════════════════════════════════════
  // SUPER ADMIN — Subscription Management
  // ═══════════════════════════════════════════════════════
  static const String subscriptionStats = '/admin/subscriptions/stats';
  static const String subscriptions = '/admin/subscriptions';
  static String subscriptionById(int id) => '/admin/subscriptions/$id';
  static const String createSubscription = '/admin/subscriptions';
  static String renewSubscription(int id) => '/admin/subscriptions/$id/renew';
  static String cancelSubscription(int id) => '/admin/subscriptions/$id/cancel';

  // ═══════════════════════════════════════════════════════
  // SUPER ADMIN — System Monitoring
  // ═══════════════════════════════════════════════════════
  static const String systemHealth = '/admin/monitoring/health';
  static const String loginLogs = '/admin/monitoring/login-logs';
  static const String loginStats = '/admin/monitoring/login-stats';
  static const String activityLogs = '/admin/monitoring/activity-logs';

  // ═══════════════════════════════════════════════════════
  // SUPER ADMIN — Dashboard
  // ═══════════════════════════════════════════════════════
  static const String dashboard = '/admin/dashboard';
  static const String dashboardKpis = '/admin/dashboard/kpis';
  static const String dashboardAlerts = '/admin/dashboard/alerts';
  static const String dashboardCharts = '/admin/dashboard/charts';
}