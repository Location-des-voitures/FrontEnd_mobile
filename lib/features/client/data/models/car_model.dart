/// -------------------------------------------------------
/// CAR MODEL — Client Space
/// -------------------------------------------------------
library;

import '../../domain/entities/car.dart';

class CarModel extends Car {
  const CarModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.year,
    required super.plate,
    required super.fuelType,
    required super.transmission,
    required super.pricePerDay,
    super.imageUrl,
    super.description,
    required super.isAvailable,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id:           json['id'] as int,
      brand:        json['brand'] as String,
      model:        json['model'] as String,
      year:         json['year'] as int,
      plate:        json['plate'] as String,
      fuelType:     _parseFuel(json['fuel_type'] as String),
      transmission: _parseTrans(json['transmission'] as String),
      pricePerDay:  (json['price_per_day'] as num).toDouble(),
      imageUrl:     json['image_url'] as String?,
      description:  json['description'] as String?,
      isAvailable:  json['is_available'] as bool? ?? true,
    );
  }

  static FuelType _parseFuel(String s) => switch (s) {
        'diesel'   => FuelType.diesel,
        'electric' => FuelType.electric,
        'hybrid'   => FuelType.hybrid,
        _          => FuelType.gasoline,
      };

  static TransmissionType _parseTrans(String s) =>
      s == 'manual' ? TransmissionType.manual : TransmissionType.automatic;
}

class PaginatedCarsModel {
  final List<CarModel> cars;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedCarsModel({
    required this.cars,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedCarsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ??
        json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedCarsModel(
      cars:        data.map((c) => CarModel.fromJson(c as Map<String, dynamic>)).toList(),
      total:       _int(meta['total']),
      perPage:     _int(meta['per_page']),
      currentPage: _int(meta['current_page']),
      lastPage:    _int(meta['last_page']),
    );
  }

  PaginatedCars toDomain() => PaginatedCars(
        cars:        cars,
        total:       total,
        perPage:     perPage,
        currentPage: currentPage,
        lastPage:    lastPage,
      );

  static int _int(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}