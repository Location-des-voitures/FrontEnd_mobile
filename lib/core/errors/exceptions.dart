/// -------------------------------------------------------
/// EXCEPTIONS — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------
/// Lancées dans la couche Data (datasources).
/// Les repositories les attrapent → les convertissent en Failures.
/// -------------------------------------------------------

/// Exception serveur (500+)
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Erreur serveur',
    this.statusCode,
  });
}

/// 401 — Token manquant, expiré, invalide ou mauvais identifiants
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Non authentifié']);
}

/// 403 — Compte désactivé, email non vérifié, mauvais rôle
class ForbiddenException implements Exception {
  final String message;
  final String? action; // "Resend verification at POST /api/email/resend"

  const ForbiddenException([this.message = 'Accès refusé', this.action]);
}

/// 404 — Ressource non trouvée
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Ressource introuvable']);
}

/// 422 — Validation Laravel ou règle métier
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;
  final List<String>? protectedFields;

  const ValidationException({
    this.message = 'Validation échouée',
    this.errors = const {},
    this.protectedFields,
  });
}

/// 429 — Rate limit dépassé
class RateLimitException implements Exception {
  final String message;
  final int retryAfter;

  const RateLimitException({
    this.message = 'Trop de requêtes',
    this.retryAfter = 60,
  });
}

/// Pas de connexion internet
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Pas de connexion']);
}

/// Cache local
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Erreur cache']);
}