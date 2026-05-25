/// -------------------------------------------------------
///  APP ROUTER — FlotTrack
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';

// ── Auth screens ─────────────────────────────────────────
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';

// ── Admin screens ─────────────────────────────────────────
import '../../features/admin/presentation/widgets/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/car_list_screen.dart';
import '../../features/admin/presentation/screens/car_detail_screen.dart';
import '../../features/admin/presentation/screens/car_form_screen.dart';
import '../../features/admin/presentation/screens/reservation_list_screen.dart';
import '../../features/admin/presentation/screens/reservation_detail_screen.dart';
import '../../features/admin/presentation/screens/client_list_screen.dart';
import '../../features/admin/presentation/screens/client_detail_screen.dart';
import '../../features/admin/presentation/screens/finances_screen.dart';
import '../../features/admin/presentation/screens/analytics_screen.dart';
import '../../features/admin/presentation/screens/admin_profile_screen.dart';

// ── Super Admin screens ───────────────────────────────────
import '../../features/superadmin/presentation/screens/super_admin_dashboard_screen.dart';
import '../../features/superadmin/presentation/screens/user_list_screen.dart';
import '../../features/superadmin/presentation/screens/subscription_management_screen.dart';
import '../../features/superadmin/presentation/screens/system_log_screen.dart';
import '../../features/superadmin/presentation/screens/fleet_alerts_screen.dart';

// ── Client screens ────────────────────────────────────────
import '../../features/dashboard/presentation/screens/client_home_screen.dart';

// ═══════════════════════════════════════════════════════
// ROUTE PATHS
// ═══════════════════════════════════════════════════════

class AppRoutes {
  AppRoutes._();

  // ── Public ────────────────────────────────────────────
  static const String splash          = '/';
  static const String onboarding      = '/onboarding';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String verifyEmail     = '/verify-email';
  static const String forgotPassword  = '/forgot-password';
  static const String resetPassword   = '/reset-password';

  // ── Admin ─────────────────────────────────────────────
  static const String adminDashboard    = '/admin/dashboard';
  static const String adminCars         = '/admin/cars';
  static const String adminCarAdd       = '/admin/cars/add';
  static const String adminReservations = '/admin/reservations';
  static const String adminClients      = '/admin/clients';
  static const String adminProfile      = '/admin/profile';
  static const String adminSmartPricing = '/admin/pricing';
  static const String adminAlerts       = '/admin/alerts';
  static const String adminMaintenance  = '/admin/maintenance';
  static const String adminFinances     = '/admin/finances';
  static const String adminAnalytics    = '/admin/analytics';
  static const String adminSettings     = '/admin/settings';
  static const String adminAutoPilot    = '/admin/auto-pilot';
  static const String adminHelp         = '/admin/help';

  // ── Client ────────────────────────────────────────────
  static const String clientExplore       = '/client/explore';
  static const String clientSearch        = '/client/search';
  static const String clientBookings      = '/client/bookings';
  static const String clientProfile       = '/client/profile';

  // ── Super Admin ───────────────────────────────────────
  static const String superAdminDashboard = '/superadmin/dashboard';
  static const String superAdminUsers     = '/superadmin/users';
  static const String superAdminPlans     = '/superadmin/plans';
  static const String superAdminLog       = '/superadmin/log';
  static const String superAdminAlerts    = '/superadmin/alerts';
}

// ═══════════════════════════════════════════════════════
// ROUTER PROVIDER
// ═══════════════════════════════════════════════════════

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,

    // ── Redirect logic ──────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final userRole   = authNotifier.role;
      final location   = state.matchedLocation;

      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.verifyEmail,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ];

      // Non connecté → login
      if (!isLoggedIn && !publicRoutes.contains(location)) {
        return AppRoutes.login;
      }

      // Connecté + route publique → home selon rôle
      if (isLoggedIn &&
          publicRoutes.contains(location) &&
          location != AppRoutes.splash) {
        if (userRole == 'super_admin') return AppRoutes.superAdminDashboard;
        if (userRole == 'admin')       return AppRoutes.adminDashboard;
        return AppRoutes.clientExplore;
      }

      // Client → ne peut pas accéder à /admin
      if (isLoggedIn && userRole == 'client' &&
          location.startsWith('/admin')) {
        return AppRoutes.clientExplore;
      }

      // Super admin → redirige vers /superadmin
      if (isLoggedIn && userRole == 'super_admin' &&
          !location.startsWith('/superadmin')) {
        return AppRoutes.superAdminDashboard;
      }

      // Admin/superadmin → ne peut pas accéder à /client
      if (isLoggedIn &&
          (userRole == 'admin' || userRole == 'super_admin') &&
          location.startsWith('/client')) {
        return AppRoutes.adminDashboard;
      }

      return null;
    },

    routes: [

      // ════════════════════════════════════════════════
      // PUBLIC ROUTES
      // ════════════════════════════════════════════════

      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forgot Password')),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Reset Password')),
        ),
      ),

      // ════════════════════════════════════════════════
      // ADMIN — SHELL (tabs avec bottom nav)
      // ════════════════════════════════════════════════

      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminCars,
            builder: (context, state) => const CarListScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminReservations,
            builder: (context, state) => const ReservationListScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminClients,
            builder: (context, state) => const ClientListScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (context, state) => const AdminProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminFinances,
            builder: (context, state) => const FinancesScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminAnalytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminAutoPilot,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Auto-Pilot — coming soon')),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminHelp,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Help — coming soon')),
            ),
          ),
        ],
      ),

      // ════════════════════════════════════════════════
      // ADMIN — DETAIL ROUTES (hors shell)
      // ════════════════════════════════════════════════

      GoRoute(
        path: AppRoutes.adminCarAdd,
        builder: (context, state) => const CarFormScreen(),
      ),
      GoRoute(
        path: '/admin/cars/:id/edit',
        builder: (context, state) {
          // Passe la voiture via state.extra si besoin
          // final car = state.extra as Car?;
          return const CarFormScreen();
        },
      ),
      GoRoute(
        path: '/admin/cars/:id',
        builder: (context, state) {
          final carId = int.parse(state.pathParameters['id']!);
          return CarDetailScreen(carId: carId);
        },
      ),
      GoRoute(
        path: '/admin/reservations/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReservationDetailScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: '/admin/clients/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ClientDetailScreen(clientId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.adminSmartPricing,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Smart Pricing — coming soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminAlerts,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Alerts — coming soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminMaintenance,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Maintenance — coming soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings — coming soon')),
        ),
      ),

      // ════════════════════════════════════════════════
      // CLIENT — SHELL
      // ════════════════════════════════════════════════

      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: AppRoutes.clientExplore,
            builder: (context, state) => const ClientHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.clientSearch,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Search — coming soon')),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientBookings,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Bookings — coming soon')),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientProfile,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Profile — coming soon')),
            ),
          ),
        ],
      ),

      // ════════════════════════════════════════════════
      // CLIENT — DETAIL ROUTES (hors shell)
      // ════════════════════════════════════════════════

      GoRoute(
        path: '/client/cars/:id',
        builder: (context, state) {
          final carId = int.parse(state.pathParameters['id']!);
          return Scaffold(body: Center(child: Text('Car Detail $carId')));
        },
      ),
      GoRoute(
        path: '/client/bookings/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return Scaffold(body: Center(child: Text('Booking $id')));
        },
      ),

      // ════════════════════════════════════════════════
      // SUPER ADMIN
      // ════════════════════════════════════════════════

      GoRoute(
        path: AppRoutes.superAdminDashboard,
        builder: (context, state) => const SuperAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.superAdminUsers,
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.superAdminPlans,
        builder: (context, state) => const SubscriptionManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.superAdminLog,
        builder: (context, state) => const SystemLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.superAdminAlerts,
        builder: (context, state) => const FleetAlertsScreen(),
      ),
    ],

    // ── 404 ─────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
          ],
        ),
      ),
    ),
  );
});