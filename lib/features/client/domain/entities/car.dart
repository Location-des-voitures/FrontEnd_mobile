/// -------------------------------------------------------
/// CAR ENTITY — Client Space
/// -------------------------------------------------------
library;

enum FuelType { gasoline, diesel, electric, hybrid }
enum TransmissionType { manual, automatic }

class Car {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final FuelType fuelType;
  final TransmissionType transmission;
  final double pricePerDay;
  final String? imageUrl;
  final String? description;
  final bool isAvailable;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    this.imageUrl,
    this.description,
    required this.isAvailable,
  });

  String get displayName => '$brand $model $year';

  String get fuelLabel => switch (fuelType) {
        FuelType.gasoline => 'Gasoline',
        FuelType.diesel   => 'Diesel',
        FuelType.electric => 'Electric',
        FuelType.hybrid   => 'Hybrid',
      };

  String get transmissionLabel => switch (transmission) {
        TransmissionType.manual    => 'Manual',
        TransmissionType.automatic => 'Automatic',
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Résultat paginé de la liste voitures
class PaginatedCars {
  final List<Car> cars;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const PaginatedCars({
    required this.cars,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;
}

/// Filtres pour GET /api/client/cars
class CarFilters {
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final String? startDate; // Y-m-d
  final String? endDate;   // Y-m-d
  final int? perPage;
  final int? page;

  const CarFilters({
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.fuelType,
    this.transmission,
    this.startDate,
    this.endDate,
    this.perPage,
    this.page,
  });
}