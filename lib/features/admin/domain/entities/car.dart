/// -------------------------------------------------------
/// CAR ENTITY — FlotTrack Admin
/// -------------------------------------------------------
library;

enum CarStatus { available, rented, maintenance }
enum TransmissionType { automatic, manual }
enum FuelType { electric, hybrid, diesel, gasoline }

class Car {
  final int id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final double pricePerDay;
  final CarStatus status;
  final int seats;
  final TransmissionType transmission;
  final FuelType fuelType;
  final List<String> images;
  final String? description;
  final bool isActive;
  final int? mileage;
  final DateTime? createdAt;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.pricePerDay,
    required this.status,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.images,
    this.description,
    required this.isActive,
    this.mileage,
    this.createdAt,
  });

  // ── Logique métier ───────────────────────────────────
  bool get isAvailable => status == CarStatus.available && isActive;
  bool get isRented => status == CarStatus.rented;
  bool get isInMaintenance => status == CarStatus.maintenance;
  String get primaryImage => images.isNotEmpty ? images.first : '';
  String get displayName => '$brand $model $year';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Car(id: $id, name: $name, status: $status)';
}