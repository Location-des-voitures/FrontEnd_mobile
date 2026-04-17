/// -------------------------------------------------------
/// APP ROUTER — Aligné sur API_DOCUMENTATION v2.0
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

  // ── Client (role = client) ───────────────────────────
  static const String clientHome = '/client/home';
  static const String clientSearch = '/client/search';
  static const String clientCarDetail = '/client/cars/:id';
  static const String clientBookings = '/client/bookings';
  static const String clientBookingDetail = '/client/bookings/:id';
  static const String clientBookingComplete = '/client/bookings/:id/complete';
  static const String clientProfile = '/client/profile';
}

// ═══════════════════════════════════════════════════════
// ROUTER PROVIDER
// ═══════════════════════════════════════════════════════

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      // TODO: Connecter avec ton AuthProvider
      // final authState = ref.read(authProvider);
      // final isLoggedIn = authState.user != null;
      // final userRole = authState.user?.role;

      final isLoggedIn = false; // ← Remplacer
      final userRole = 'client'; // ← Remplacer

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword ||
          state.matchedLocation == AppRoutes.onboarding;

      // Pas connecté → login
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.login;
      }

      // Connecté sur page auth → rediriger selon rôle
      if (isLoggedIn && isAuthRoute) {
        return userRole == 'admin' || userRole == 'super_admin'
            ? AppRoutes.adminDashboard
            : AppRoutes.clientHome;
      }

      // Client essaie d'aller sur admin
      if (isLoggedIn &&
          userRole == 'client' &&
          state.matchedLocation.startsWith('/admin')) {
        return AppRoutes.clientHome;
      }

      // Admin essaie d'aller sur client
      if (isLoggedIn &&
          (userRole == 'admin' || userRole == 'super_admin') &&
          state.matchedLocation.startsWith('/client')) {
        return AppRoutes.adminDashboard;
      }

      return null;
    },

    routes: [
      // ── Splash ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),

      // ── Onboarding ───────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Onboarding')), // ← Remplacer
        ),
      ),

      // ── Auth ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login')), // ← Remplacer par LoginScreen()
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register')), // ← Remplacer
        ),
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
          return Scaffold(body: child); // ← Remplacer par AdminShell(child: child)
        },
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Dashboard')),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminCars,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Cars')),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminReservations,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Reservations')),
            ),
          ),
          GoRoute(
            path: AppRoutes.adminClients,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Clients')),
            ),
          ),
          // MORE tab destinations
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Profile')),
            ),
          ),
        ],
      ),

      // ── Admin detail routes (hors shell) ─────────────
      GoRoute(
        path: AppRoutes.adminCarAdd,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Add Car')),
        ),
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
      GoRoute(path: AppRoutes.adminSmartPricing, builder: (_, __) => const Scaffold(body: Center(child: Text('Smart Pricing')))),
      GoRoute(path: AppRoutes.adminAlerts, builder: (_, __) => const Scaffold(body: Center(child: Text('Alerts')))),
      GoRoute(path: AppRoutes.adminMaintenance, builder: (_, __) => const Scaffold(body: Center(child: Text('Maintenance')))),
      GoRoute(path: AppRoutes.adminFinances, builder: (_, __) => const Scaffold(body: Center(child: Text('Finances')))),
      GoRoute(path: AppRoutes.adminAnalytics, builder: (_, __) => const Scaffold(body: Center(child: Text('Analytics')))),
      GoRoute(path: AppRoutes.adminSettings, builder: (_, __) => const Scaffold(body: Center(child: Text('Settings')))),

      // ── Client Shell (avec bottom nav) ───────────────
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(body: child); // ← Remplacer par ClientShell(child: child)
        },
        routes: [
          GoRoute(
            path: AppRoutes.clientHome,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientSearch,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Search')),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientBookings,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Bookings')),
            ),
          ),
          GoRoute(
            path: AppRoutes.clientProfile,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Profile')),
            ),
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
            Text('Page introuvable', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
          ],
        ),
      ),
    ),
  );
});