/// -------------------------------------------------------
/// CAR REMOTE DATASOURCE — Client Space
/// -------------------------------------------------------
library;

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/car.dart';
import '../models/car_model.dart';
import '../models/price_quote_model.dart';

class CarRemoteDatasource {
  final DioClient _client;
  const CarRemoteDatasource({required DioClient client}) : _client = client;

  Future<PaginatedCarsModel> getCars({
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.get(
      '/client/cars',
      queryParameters: params,
    );
    // L'API retourne { success, data: { data: [...], meta: {...} } }
    return PaginatedCarsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<CarModel> getCarById(int id) async {
    final response = await _client.get('/client/cars/$id');
    return CarModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<AvailabilityResultModel> checkAvailability({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _client.post(
      '/client/cars/check-availability',
      data: {
        'car_id':     carId,
        'start_date': startDate,
        'end_date':   endDate,
      },
    );
    return AvailabilityResultModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<PriceQuoteModel> calculatePrice({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _client.post(
      '/client/cars/calculate-price',
      data: {
        'car_id':     carId,
        'start_date': startDate,
        'end_date':   endDate,
      },
    );
    return PriceQuoteModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}