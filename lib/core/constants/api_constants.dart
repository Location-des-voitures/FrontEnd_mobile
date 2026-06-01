class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Auth (Public) ─────────────────────────────────────
  static const String register        = '/auth/register';
  static const String verifyOtp       = '/auth/verify-otp';
  static const String resendOtp       = '/auth/resend-otp';
  static const String login           = '/auth/login';
  static const String forgotPassword  = '/auth/forgot-password';
  static const String verifyResetOtp  = '/auth/verify-reset-otp';
  static const String resetPassword   = '/auth/reset-password';
  static const String googleRedirect  = '/auth/google/redirect';
  static const String googleMobile    = '/auth/google/mobile';

  // ── Auth (Protected) ──────────────────────────────────
  static const String logout          = '/auth/logout';
  static const String refreshToken    = '/auth/refresh';
  static const String me              = '/auth/me';

  // ── Super Admin — Users ───────────────────────────────
  static const String users                   = '/super-admin/users';
  static String userById(int id)              => '/super-admin/users/$id';
  static String activateUser(int id)          => '/super-admin/users/$id/activate';
  static String deactivateUser(int id)        => '/super-admin/users/$id/deactivate';
  static String deleteUser(int id)            => '/super-admin/users/$id';

  // ── Super Admin — Admins (Loueurs) ────────────────────
  static const String admins                  = '/super-admin/admins';
  static String adminById(int id)             => '/super-admin/admins/$id';
  static const String createAdmin             = '/super-admin/admins';
  static String activateAdmin(int id)         => '/super-admin/admins/$id/activate';
  static String suspendAdmin(int id)          => '/super-admin/admins/$id/suspend';
  static String deleteAdmin(int id)           => '/super-admin/admins/$id';

  // ── Super Admin — Subscriptions ───────────────────────
  static const String subscriptionStats       = '/super-admin/subscriptions/stats';
  static const String subscriptions           = '/super-admin/subscriptions';
  static String subscriptionById(int id)      => '/super-admin/subscriptions/$id';
  static String renewSubscription(int id)     => '/super-admin/subscriptions/$id/renew';
  static String cancelSubscription(int id)    => '/super-admin/subscriptions/$id/cancel';

  // ── Super Admin — Monitoring ──────────────────────────
  static const String systemHealth            = '/super-admin/monitoring/health';
  static const String loginLogs               = '/super-admin/monitoring/login-logs';
  static const String activityLogs            = '/super-admin/monitoring/activity-logs';
  static const String loginStats              = '/super-admin/monitoring/login-stats';

  // ── Super Admin — Dashboard ───────────────────────────
  static const String dashboard               = '/super-admin/dashboard';
  static const String dashboardKpis           = '/super-admin/dashboard/kpis';
  static const String dashboardAlerts         = '/super-admin/dashboard/alerts';
  static const String dashboardCharts         = '/super-admin/dashboard/charts';

  // ── Admin (Loueur) — Cars ─────────────────────────────
  static const String cars                    = '/admin/cars';
  static String carById(int id)               => '/admin/cars/$id';
  static String carStatus(int id)             => '/admin/cars/$id/status';

  // ── Admin (Loueur) — Reservations ─────────────────────
  static const String reservations            = '/admin/reservations';
  static String reservationById(int id)       => '/admin/reservations/$id';
  static String approveReservation(int id)    => '/admin/reservations/$id/approve';
  static String rejectReservation(int id)     => '/admin/reservations/$id/reject';
  static String cancelReservation(int id)     => '/admin/reservations/$id/cancel';
  static String verifyPayment(int pid)        => '/admin/reservations/payments/$pid/verify';
  static String paymentReceipt(int pid)       => '/admin/reservations/payments/$pid/receipt';
  static String invoicePdf(int id)            => '/admin/invoices/$id/pdf';
  static String contractPdf(int id)           => '/admin/contracts/$id/pdf';

  // ── Admin (Loueur) — Dashboard ────────────────────────
  static const String adminDashboard          = '/admin/dashboard';
  static const String adminDashboardKpis      = '/admin/dashboard/kpis';
}