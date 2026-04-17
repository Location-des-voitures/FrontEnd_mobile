/// -------------------------------------------------------
/// AUTH REPOSITORY (Interface / Contrat)
/// -------------------------------------------------------
/// C'est une classe ABSTRAITE — elle ne fait rien.
/// Elle dit juste : "celui qui m'implémente DOIT avoir
/// ces méthodes avec ces signatures".
///
/// Pourquoi ?
/// → Le Domain ne sait pas comment on se connecte
///   (API REST ? Firebase ? GraphQL ?). Il s'en fiche.
///   Il sait juste qu'il a besoin d'une méthode login()
///   qui retourne un User ou une Failure.
///
/// La vraie implémentation sera dans :
///   features/auth/data/repositories/auth_repository_impl.dart
///
/// Either<Failure, User> signifie :
///   → Left(Failure)  = erreur (mauvais mot de passe, réseau...)
///   → Right(User)    = succès (utilisateur connecté)
/// -------------------------------------------------------

import 'package:dartz/dartz.dart';

// On importe depuis le core (les Failures)
// et depuis le domain (l'Entity)
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Se connecter avec email + mot de passe
  /// Retourne le User connecté ou une Failure
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Créer un nouveau compte client
  /// Retourne le User créé ou une Failure
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Se déconnecter
  /// Retourne void (succès) ou une Failure
  Future<Either<Failure, void>> logout();

  /// Récupérer l'utilisateur actuellement connecté
  /// (depuis le token stocké)
  Future<Either<Failure, User>> getCurrentUser();

  /// Vérifier si un token est stocké localement
  /// (pour savoir si on redirige vers login ou home)
  Future<bool> hasToken();
}