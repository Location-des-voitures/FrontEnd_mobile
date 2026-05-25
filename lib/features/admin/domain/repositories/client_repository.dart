/// -------------------------------------------------------
/// CLIENT REPOSITORY — Interface (Domain Layer)
/// -------------------------------------------------------
library;

import '../entities/client_profile.dart';

abstract class ClientRepository {
  /// Retourne la liste paginée des clients.
  /// [params] : search, per_page, page
  Future<ClientListResult> getClients({Map<String, dynamic>? params});

  /// Retourne le détail d'un client par son ID.
  Future<ClientProfile> getClientById(int id);
}

/// ── Résultat paginé ─────────────────────────────────────
class ClientListResult {
  final List<ClientProfile> clients;
  final int total;
  final int currentPage;
  final int lastPage;

  const ClientListResult({
    required this.clients,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });
}