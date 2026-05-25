/// -------------------------------------------------------
/// CLIENT REMOTE DATASOURCE
/// -------------------------------------------------------
library;

import '../../../../core/network/dio_client.dart';
import '../models/client_model.dart';

class ClientRemoteDatasource {
  final DioClient _client;
  const ClientRemoteDatasource({required DioClient client}) : _client = client;

  Future<PaginatedClientsModel> getClients({Map<String, dynamic>? params}) async {
    final response =
        await _client.get('/admin/clients', queryParameters: params);
    return PaginatedClientsModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ClientModel> getClientById(int id) async {
    final response = await _client.get('/admin/clients/$id');
    return ClientModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}