/// -------------------------------------------------------
/// CAR MODEL — FlotTrack API
/// -------------------------------------------------------
library;

import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';

class CarModel extends Car {
  const CarModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.model,
    required super.year,
    required super.licensePlate,
    required super.color,
    required super.pricePerDay,
    required super.status,
    required super.seats,
    required super.transmission,
    required super.fuelType,
    required super.images,
    super.description,
    required super.isActive,
    super.mileage,
    super.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int,
      name: (json['name'] ??
              '${json['brand'] ?? ''} ${json['model'] ?? ''}'.trim())
          .toString(),
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? '') ?? 0,
      licensePlate:
          (json['plate'] ?? json['license_plate'] ?? '').toString(),
      color: json['color']?.toString() ?? '',
      pricePerDay: _asDouble(json['price_per_day']),
      status: _parseStatus(json['status']?.toString() ?? 'available'),
      seats: int.tryParse(json['seats']?.toString() ?? '') ?? 0,
      transmission:
          _parseTransmission(json['transmission']?.toString() ?? 'automatic'),
      fuelType: _parseFuelType(json['fuel_type']?.toString() ?? 'gasoline'),
      images: [
        if (json['image'] != null) json['image'].toString(),
        ...(json['images'] as List<dynamic>? ?? []).map((e) => e.toString()),
      ],
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      mileage: int.tryParse(json['mileage']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'model': model,
        'year': year,
        'license_plate': licensePlate,
        'color': color,
        'price_per_day': pricePerDay,
        'status': _statusToString(status),
        'seats': seats,
        'transmission': _transmissionToString(transmission),
        'fuel_type': _fuelTypeToString(fuelType),
        'images': images,
        'description': description,
        'is_active': isActive,
        'mileage': mileage,
      };

  static CarStatus _parseStatus(String s) => switch (s) {
        'rented' => CarStatus.rented,
        'maintenance' => CarStatus.maintenance,
        _ => CarStatus.available,
      };

  static TransmissionType _parseTransmission(String s) =>
      s == 'manual' ? TransmissionType.manual : TransmissionType.automatic;

  static FuelType _parseFuelType(String s) => switch (s) {
        'electric' => FuelType.electric,
        'hybrid' => FuelType.hybrid,
        'diesel' => FuelType.diesel,
        _ => FuelType.gasoline,
      };

  static String _statusToString(CarStatus s) => switch (s) {
        CarStatus.available => 'available',
        CarStatus.rented => 'rented',
        CarStatus.maintenance => 'maintenance',
      };

  static String _transmissionToString(TransmissionType t) =>
      t == TransmissionType.manual ? 'manual' : 'automatic';

  static String _fuelTypeToString(FuelType f) => switch (f) {
        FuelType.electric => 'electric',
        FuelType.hybrid => 'hybrid',
        FuelType.diesel => 'diesel',
        FuelType.gasoline => 'gasoline',
      };

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
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
    final carsList = (json['cars'] as List)
        .map((c) => CarModel.fromJson(c as Map<String, dynamic>))
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>;
    return PaginatedCarsModel(
      cars: carsList,
      total: pagination['total'] as int,
      perPage: pagination['per_page'] as int,
      currentPage: pagination['current_page'] as int,
      lastPage: pagination['last_page'] as int,
    );
  }

  PaginatedCars toDomain() => PaginatedCars(
        cars: cars,
        total: total,
        perPage: perPage,
        currentPage: currentPage,
        lastPage: lastPage,
      );
}
