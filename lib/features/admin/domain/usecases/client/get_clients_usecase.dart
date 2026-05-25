/// -------------------------------------------------------
/// GET CLIENTS USE CASE
/// -------------------------------------------------------
library;

import '../../repositories/client_repository.dart';

class GetClientsUseCase {
  final ClientRepository _repository;

  const GetClientsUseCase(this._repository);

  Future<ClientListResult> call({
    String? search,
    int page = 1,
    int perPage = 15,
  }) {
    return _repository.getClients(params: {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
  }
}