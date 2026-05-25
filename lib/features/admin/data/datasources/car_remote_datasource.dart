/// -------------------------------------------------------
/// CAR REMOTE DATASOURCE — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/car_model.dart';
import '../../domain/entities/car.dart';

// ── Ajoute ces constantes dans api_constants.dart ───────
// static const String cars = '/admin/cars';
// static String carById(int id) => '/admin/cars/$id';
// static String carStatus(int id) => '/admin/cars/$id/status';

class CarRemoteDatasource {
  final DioClient _client;
  const CarRemoteDatasource({required DioClient client}) : _client = client;

  Future<PaginatedCarsModel> getCars({Map<String, dynamic>? params}) async {
    final response = await _client.get('/admin/cars', queryParameters: params);
    return PaginatedCarsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<CarModel> getCarById(int id) async {
    final response = await _client.get('/admin/cars/$id');
    return CarModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CarModel> createCar(Map<String, dynamic> data) async {
    final formData = FormData.fromMap({
      ...data,
      if (data['image'] is String && (data['image'] as String).isNotEmpty)
        'image': await MultipartFile.fromFile(data['image'] as String),
    });
    final response = await _client.postMultipart('/admin/cars', data: formData);
    return CarModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CarModel> updateCar(int id, Map<String, dynamic> data) async {
    final response = await _client.put('/admin/cars/$id', data: data);
    return CarModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCar(int id) async {
    await _client.delete('/admin/cars/$id');
  }

  Future<CarModel> updateCarStatus(int id, CarStatus status) async {
    final statusStr = switch (status) {
      CarStatus.available => 'available',
      CarStatus.rented => 'rented',
      CarStatus.maintenance => 'maintenance',
    };
    final response = await _client.patch(
      '/admin/cars/$id/status',
      data: {'status': statusStr},
    );
    return CarModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
