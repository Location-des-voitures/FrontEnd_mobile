/// -------------------------------------------------------
/// CORE PROVIDERS (Injection de dépendances)
/// -------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/dio_client.dart';

/// Secure Storage — pour le token JWT et données sensibles
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Dio Client — client HTTP configuré avec interceptors
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return DioClient(storage: storage);
});