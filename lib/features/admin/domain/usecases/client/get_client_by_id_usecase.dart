/// -------------------------------------------------------
/// GET CLIENT BY ID USE CASE
/// -------------------------------------------------------
library;

import '../../entities/client_profile.dart';
import '../../repositories/client_repository.dart';

class GetClientByIdUseCase {
  final ClientRepository _repository;

  const GetClientByIdUseCase(this._repository);

  Future<ClientProfile> call(int id) => _repository.getClientById(id);
}