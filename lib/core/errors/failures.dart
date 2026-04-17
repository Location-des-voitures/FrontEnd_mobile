/// -------------------------------------------------------
/// FAILURES — Aligné sur API_DOCUMENTATION v2.0
/// -------------------------------------------------------
/// Chaque Failure correspond à un code HTTP réel de ton API.
/// Les messages sont ceux retournés par Laravel.
/// -------------------------------------------------------

/// Classe de base
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure($statusCode): $message';
}

/// 500 — Erreur serveur
class ServerFailure extends Failure {
  const ServerFailure([
    String message = 'Erreur du serveur. Veuillez réessayer.',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);
}

/// 401 — Non authentifié
/// Messages API :
///   "Token is missing or malformed."
///   "Token has expired."
///   "Token is invalid."
///   "Invalid email or password."
class AuthFailure extends Failure {
  const AuthFailure([
    String message = 'Non authentifié.',
  ]) : super(message, statusCode: 401);
}

/// 403 — Accès refusé
/// Messages API :
///   "Your account is deactivated. Please contact the administrator."
///   "Your email address is not verified. Please check your inbox."
///   "Forbidden. You do not have permission to access this resource."
class ForbiddenFailure extends Failure {
  final String? action; // ex: "Resend verification at POST /api/email/resend"

  const ForbiddenFailure([
    String message = 'Accès refusé.',
    this.action,
  ]) : super(message, statusCode: 403);
}

/// 404 — Ressource non trouvée
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    String message = 'Ressource introuvable.',
  ]) : super(message, statusCode: 404);
}

/// 422 — Validation ou règle métier échouée
/// Messages API :
///   "Request contains protected fields that cannot be set manually."
///   "The reset token is invalid or has already been used."
///   "Your email is already verified."
class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  final List<String>? protectedFields; // pour ForbiddenFieldsMiddleware

  const ValidationFailure({
    String message = 'Données invalides.',
    this.errors = const {},
    this.protectedFields,
  }) : super(message, statusCode: 422);

  /// Récupère la première erreur d'un champ
  String? fieldError(String field) {
    if (errors.containsKey(field) && errors[field]!.isNotEmpty) {
      return errors[field]!.first;
    }
    return null;
  }
}

/// 429 — Trop de requêtes (rate limit)
/// L'API retourne "retry_after" en secondes
class RateLimitFailure extends Failure {
  final int retryAfter; // secondes avant de pouvoir réessayer

  const RateLimitFailure({
    String message = 'Trop de requêtes. Patientez un moment.',
    this.retryAfter = 60,
  }) : super(message, statusCode: 429);
}

/// Pas de connexion internet
class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'Pas de connexion internet.',
  ]) : super(message);
}

/// Erreur de cache local
class CacheFailure extends Failure {
  const CacheFailure([
    String message = 'Erreur de cache local.',
  ]) : super(message);
}

/// Erreur inattendue (fallback)
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    String message = 'Une erreur inattendue est survenue.',
  ]) : super(message);
}