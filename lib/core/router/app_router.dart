/// --------------------------------------------------
///  APP ROUTER — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------
/// Routes basées sur la Role Access Matrix de l'API :
///   - Super Admin → /api/users, /api/admins
///   - Admin       → /api/admin/dashboard, /api/admin/clients
///   - Client      → /api/client/profile, /api/client/cars, /api/client/reservations
///   - Public      → /api/auth/*, /api/email/verify/*
/// -------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/core_providers.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/dashboard/presentation/screens/client_home_screen.dart';

// ═══════════════════════════════════════════════════════
// PATHS DES ROUTES
// ═══════════════════════════════════════════════════════

class AppRoutes {
  AppRoutes._();

  // ── Onboarding & Auth (Public) ───────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ── Admin (role = admin) ─────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCars = '/admin/cars';
  static const String adminCarAdd = '/admin/cars/add';
  static const String adminCarEdit = '/admin/cars/:id/edit';
  static const String adminCarDetail = '/admin/cars/:id';
  static const String adminReservations = '/admin/reservations';
  static const String adminReservationDetail = '/admin/reservations/:id';
  static const String adminClients = '/admin/clients';
  static const String adminClientDetail = '/admin/clients/:id';
  static const String adminSmartPricing = '/admin/pricing';
  static const String adminAlerts = '/admin/alerts';
  static const String adminMaintenance = '/admin/maintenance';
  static const String adminFinances = '/admin/finances';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminProfile = '/admin/profile';
  static const String adminSettings = '/admin/settings';
  static const String adminAutoPilot = '/admin/auto-pilot';
  static const String adminHelp = '/admin/help';

  // ── Client (role = client) ───────────────────────────
  static const String clientExplore = '/client/explore';
  static const String clientSearch = '/client/search';
  static const String clientCarDetail = '/client/cars/:id';
  static const String clientBookings = '/client/bookings';
  static const String clientBookingDetail = '/client/bookings/:id';
  static const String clientBookingComplete = '/client/bookings/:id/complete';
  static const String clientProfile = '/client/profile';
}

// ═══════════════════════════════════════════════════════
// ROUTER PROVIDER (avec Riverpod)
// ═══════════════════════════════════════════════════════
// Clean Architecture : Le routeur est stateless et utilise Riverpod
// pour lire l'état de l'authentification depuis les providers.
// TODO: Remplacer isLoggedIn/userRole par authProvider.watch()
// ═══════════════════════════════════════════════════════

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final userRole   = authNotifier.role;

      final location = state.matchedLocation;

      // ── Listes de routes publiques (accessibles sans connexion) ──
      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.verifyEmail,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ];

      // ── Si pas connecté et essaie d'accéder à une zone protégée ──
      if (!isLoggedIn && !publicRoutes.contains(location)) {
        return AppRoutes.login;
      }

      // ── Si connecté et sur une route publique (auth) → rediriger ──
      if (isLoggedIn &&
          publicRoutes.contains(location) &&
          location != AppRoutes.splash) {
        return userRole == 'admin' || userRole == 'super_admin'
            ? AppRoutes.adminDashboard
            : AppRoutes.clientExplore;
      }

      // ── Permissions par rôle ──
      if (isLoggedIn && userRole == 'client' && location.startsWith('/admin')) {
        return AppRoutes.clientExplore;
      }

      if (isLoggedIn &&
          (userRole == 'admin' || userRole == 'super_admin') &&
          location.startsWith('/client')) {
        return AppRoutes.adminDashboard;
      }

      return null;
    },

    routes: [
      // ── Splash ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ───────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth ─────────────────────────────────────────
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
          body: Center(child: Text('Forgot Password')), // ← Remplacer
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Reset Password')), // ← Remplacer
        ),
      ),

      // ── Admin Shell (avec bottom nav) ────────────────
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
          ); // ← Remplacer par AdminShell(child: child)
        },
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Dashboard'))),
          ),
          GoRoute(
            path: AppRoutes.adminCars,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Cars'))),
          ),
          GoRoute(
            path: AppRoutes.adminReservations,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Reservations'))),
          ),
          GoRoute(
            path: AppRoutes.adminClients,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Clients'))),
          ),
          // MORE tab destinations
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Admin Profile'))),
          ),
          GoRoute(
            path: AppRoutes.adminAutoPilot,
            builder: (_, _) => const Scaffold(
              body: Center(child: Text('Auto-Pilot Settings')),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminHelp,
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('Help'))),
          ),
        ],
      ),

      // ── Admin detail routes (hors shell) ─────────────
      GoRoute(
        path: AppRoutes.adminCarAdd,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Add Car'))),
      ),
      GoRoute(
        path: '/admin/cars/:id',
        builder: (context, state) {
          final carId = int.parse(state.pathParameters['id']!);
          return Scaffold(body: Center(child: Text('Car $carId')));
        },
      ),
      GoRoute(
        path: '/admin/reservations/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return Scaffold(body: Center(child: Text('Reservation $id')));
        },
      ),
      GoRoute(
        path: '/admin/clients/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return Scaffold(body: Center(child: Text('Client $id')));
        },
      ),
      GoRoute(
        path: AppRoutes.adminSmartPricing,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Smart Pricing'))),
      ),
      GoRoute(
        path: AppRoutes.adminAlerts,
        builder: (_, _) => const Scaffold(body: Center(child: Text('Alerts'))),
      ),
      GoRoute(
        path: AppRoutes.adminMaintenance,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Maintenance'))),
      ),
      GoRoute(
        path: AppRoutes.adminFinances,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Finances'))),
      ),
      GoRoute(
        path: AppRoutes.adminAnalytics,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Analytics'))),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Settings'))),
      ),

      // ── Client Shell (avec bottom nav) ───────────────
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
          ); // ← Remplacer par ClientShell(child: child)
        },
        routes: [
          GoRoute(
            path: AppRoutes.clientExplore,
            builder: (context, state) => const ClientHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.clientSearch,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Search'))),
          ),
          GoRoute(
            path: AppRoutes.clientBookings,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Bookings'))),
          ),
          GoRoute(
            path: AppRoutes.clientProfile,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Profile'))),
          ),
        ],
      ),

      // ── Client detail routes (hors shell) ────────────
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
    ],

    // ── Page 404 ───────────────────────────────────────
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
