/// -------------------------------------------------------
/// API CONSTANTS — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------
/// Tous les endpoints correspondent exactement à ton
/// backend Laravel. Vérifié contre la doc API.
/// -------------------------------------------------------

class ApiConstants {
  ApiConstants._();

  // ── URL de base ──────────────────────────────────────
  // Émulateur Android : http://10.0.2.2:8000/api
  // iOS simulator    : http://localhost:8000/api
  // Appareil réel    : http://ton-ip-locale:8000/api
  // Production       : https://ton-domaine.com/api
  static const String baseUrl = 'http://localhost:8000/api';

  // ── Timeout ──────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ══════════════════════════════════════════════════════
  // AUTH — Publiques (pas de token requis)
  // ══════════════════════════════════════════════════════
  /// POST — Créer un compte client
  /// Rate limit: 3 req/min
  static const String register = '/auth/register';

  /// POST — Se connecter (retourne JWT)
  /// Rate limit: 5 req/min
  static const String login = '/auth/login';

  /// POST — Se déconnecter (invalide le token)
  /// Requiert: JWT
  static const String logout = '/auth/logout';

  /// POST — Rafraîchir le token JWT
  /// Requiert: JWT
  static const String refreshToken = '/auth/refresh';

  /// GET — Récupérer l'utilisateur authentifié
  /// Requiert: JWT
  static const String me = '/auth/me';

  // ══════════════════════════════════════════════════════
  // PASSWORD RESET — Publiques
  // ══════════════════════════════════════════════════════
  /// POST — Demander un lien de reset
  /// Rate limit: 3 req/min
  static const String forgotPassword = '/auth/forgot-password';

  /// POST — Réinitialiser le mot de passe avec le token
  /// Rate limit: 3 req/min
  static const String resetPassword = '/auth/reset-password';

  // ══════════════════════════════════════════════════════
  // EMAIL VERIFICATION
  // ══════════════════════════════════════════════════════
  /// GET — Vérifier l'email (lien cliqué depuis l'inbox)
  /// URL signée, publique
  static String verifyEmail(int id, String hash) => '/email/verify/$id/$hash';

  /// POST — Renvoyer l'email de vérification
  /// Requiert: JWT | Rate limit: 1 req/min
  static const String resendVerification = '/email/resend';

  // ══════════════════════════════════════════════════════
  // SUPER ADMIN — Gestion des utilisateurs
  // ══════════════════════════════════════════════════════
  /// GET — Liste de tous les utilisateurs
  /// Query params: ?role=admin&is_active=false&per_page=10
  static const String users = '/users';

  /// GET — Détail d'un utilisateur
  static String userById(int id) => '/users/$id';

  /// PUT — Activer un compte
  static String activateUser(int id) => '/users/$id/activate';

  /// PUT — Désactiver un compte
  static String deactivateUser(int id) => '/users/$id/deactivate';

  /// DELETE — Supprimer un utilisateur
  static String deleteUser(int id) => '/users/$id';

  /// POST — Créer un admin (loueur)
  static const String createAdmin = '/admins';

  // ══════════════════════════════════════════════════════
  // ADMIN (Loueur) — Routes protégées role=admin
  // ══════════════════════════════════════════════════════
  /// GET — Dashboard admin
  static const String adminDashboard = '/admin/dashboard';

  /// GET — Liste des clients de l'admin
  static const String adminClients = '/admin/clients';

  // ══════════════════════════════════════════════════════
  // CLIENT — Routes protégées role=client
  // ══════════════════════════════════════════════════════
  /// GET — Profil du client
  static const String clientProfile = '/client/profile';

  /// GET — Voitures disponibles
  static const String clientCars = '/client/cars';

  /// GET — Réservations du client
  static const String clientReservations = '/client/reservations';

  /// POST — Créer une réservation
  static const String createReservation = '/client/reservations';
}