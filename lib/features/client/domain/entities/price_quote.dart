/// -------------------------------------------------------
/// PRICE QUOTE ENTITY — Résultat de calculate-price
/// -------------------------------------------------------
library;

class PriceQuote {
  final int carId;
  final double pricePerDay;
  final int totalDays;
  final double totalAmount;
  final bool isAvailable;

  const PriceQuote({
    required this.carId,
    required this.pricePerDay,
    required this.totalDays,
    required this.totalAmount,
    required this.isAvailable,
  });
}

/// Résultat de check-availability
class AvailabilityResult {
  final int carId;
  final bool isAvailable;
  final String? reason; // pourquoi indisponible

  const AvailabilityResult({
    required this.carId,
    required this.isAvailable,
    this.reason,
  });
}