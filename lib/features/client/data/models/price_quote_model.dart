/// -------------------------------------------------------
/// PRICE QUOTE MODEL
/// -------------------------------------------------------
library;

import '../../domain/entities/price_quote.dart';

class PriceQuoteModel extends PriceQuote {
  const PriceQuoteModel({
    required super.carId,
    required super.pricePerDay,
    required super.totalDays,
    required super.totalAmount,
    required super.isAvailable,
  });

  factory PriceQuoteModel.fromJson(Map<String, dynamic> json) {
    return PriceQuoteModel(
      carId:       json['car_id'] as int,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      totalDays:   json['total_days'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

class AvailabilityResultModel extends AvailabilityResult {
  const AvailabilityResultModel({
    required super.carId,
    required super.isAvailable,
    super.reason,
  });

  factory AvailabilityResultModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityResultModel(
      carId:       json['car_id'] as int,
      isAvailable: json['is_available'] as bool? ?? false,
      reason:      json['reason'] as String?,
    );
  }
}