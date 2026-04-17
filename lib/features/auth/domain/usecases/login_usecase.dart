/// -------------------------------------------------------
/// LOGIN USECASE
/// -------------------------------------------------------
/// Un usecase = une action = une classe.
///
/// Pourquoi pas juste appeler le repository directement ?
/// → Parce que parfois, avant de se connecter, tu voudras
///   peut-être vérifier quelque chose, logger, ou ajouter
///   de la logique. Le usecase est l'endroit pour ça.
///
/// Pour l'instant c'est simple (juste un passe-plat),
/// mais ça te donne la structure pour plus tard.
///
/// Utilisation dans le Provider :
///   final result = await loginUsecase(
///     email: 'jane@example.com',
///     password: 'MyPass@123',
///   );
///   result.fold(
///     (failure) => // afficher erreur,
///     (user) => // naviguer vers home,
///   );
/// -------------------------------------------------------

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  const LoginUsecase(this.repository);

  /// Appeler le usecase comme une fonction :
  /// loginUsecase(email: '...', password: '...')
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}