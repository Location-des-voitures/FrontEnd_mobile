/// -------------------------------------------------------
/// CAR PROVIDER — Client Space
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/car_remote_datasource.dart';
import '../../data/repositories/car_repository_impl.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/price_quote.dart';
import '../../domain/repositories/car_repository.dart';
import '../../domain/usecases/car_usecases.dart';

// ── Injection ─────────────────────────────────────────────
final carDatasourceProvider = Provider(
    (ref) => CarRemoteDatasource(client: ref.read(dioClientProvider)));

final carRepositoryProvider = Provider<CarRepository>(
    (ref) => CarRepositoryImpl(ref.read(carDatasourceProvider)));

final getCarsUsecaseProvider =
    Provider((ref) => GetCarsUsecase(ref.read(carRepositoryProvider)));

final getCarByIdUsecaseProvider =
    Provider((ref) => GetCarByIdUsecase(ref.read(carRepositoryProvider)));

final checkAvailabilityUsecaseProvider = Provider(
    (ref) => CheckAvailabilityUsecase(ref.read(carRepositoryProvider)));

final calculatePriceUsecaseProvider = Provider(
    (ref) => CalculatePriceUsecase(ref.read(carRepositoryProvider)));

// ── State : Liste des voitures ────────────────────────────
class CarListState {
  final List<Car> cars;
  final bool isLoading;
  final String? errorMessage;
  final CarFilters filters;
  final int total;
  final int currentPage;
  final int lastPage;

  const CarListState({
    this.cars = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filters = const CarFilters(),
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get isEmpty => cars.isEmpty && !isLoading;

  CarListState copyWith({
    List<Car>? cars,
    bool? isLoading,
    String? errorMessage,
    CarFilters? filters,
    int? total,
    int? currentPage,
    int? lastPage,
  }) =>
      CarListState(
        cars:         cars ?? this.cars,
        isLoading:    isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        filters:      filters ?? this.filters,
        total:        total ?? this.total,
        currentPage:  currentPage ?? this.currentPage,
        lastPage:     lastPage ?? this.lastPage,
      );
}

final carListProvider = NotifierProvider<CarListNotifier, CarListState>(() {
  return CarListNotifier();
});

class CarListNotifier extends Notifier<CarListState> {
  late final GetCarsUsecase _getCars;

  @override
  CarListState build() {
    _getCars = ref.read(getCarsUsecaseProvider);
    return const CarListState();
  }

  Future<void> loadCars({CarFilters? filters}) async {
    final active = filters ?? state.filters;
    state = state.copyWith(isLoading: true, filters: active);

    final result = await _getCars(
      filters: CarFilters(
        brand:        active.brand,
        minPrice:     active.minPrice,
        maxPrice:     active.maxPrice,
        fuelType:     active.fuelType,
        transmission: active.transmission,
        startDate:    active.startDate,
        endDate:      active.endDate,
        perPage:      active.perPage ?? 15,
        page:         1,
      ),
    );

    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(
        cars:        p.cars,
        isLoading:   false,
        total:       p.total,
        currentPage: p.currentPage,
        lastPage:    p.lastPage,
      ),
    );
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final result = await _getCars(
      filters: CarFilters(
        brand:        state.filters.brand,
        minPrice:     state.filters.minPrice,
        maxPrice:     state.filters.maxPrice,
        fuelType:     state.filters.fuelType,
        transmission: state.filters.transmission,
        startDate:    state.filters.startDate,
        endDate:      state.filters.endDate,
        perPage:      state.filters.perPage ?? 15,
        page:         state.currentPage + 1,
      ),
    );

    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (p) => state = state.copyWith(
        cars:        [...state.cars, ...p.cars],
        isLoading:   false,
        total:       p.total,
        currentPage: p.currentPage,
        lastPage:    p.lastPage,
      ),
    );
  }

  Future<void> refresh() => loadCars(filters: state.filters);
  Future<void> applyFilters(CarFilters f) => loadCars(filters: f);
}

// ── State : Détail voiture ────────────────────────────────
final carDetailProvider =
    FutureProvider.family<Car?, int>((ref, id) async {
  final usecase = ref.read(getCarByIdUsecaseProvider);
  final result  = await usecase(id);
  return result.fold((f) => throw Exception(f.message), (car) => car);
});

// ── State : Calculate price ───────────────────────────────
class PriceState {
  final PriceQuote? quote;
  final bool isLoading;
  final String? errorMessage;
  const PriceState({this.quote, this.isLoading = false, this.errorMessage});
}

final priceProvider = NotifierProvider<PriceNotifier, PriceState>(() {
  return PriceNotifier();
});

class PriceNotifier extends Notifier<PriceState> {
  late final CalculatePriceUsecase _calc;

  @override
  PriceState build() {
    _calc = ref.read(calculatePriceUsecaseProvider);
    return const PriceState();
  }

  Future<void> calculate({
    required int carId,
    required String startDate,
    required String endDate,
  }) async {
    state = const PriceState(isLoading: true);
    final result = await _calc(
        carId: carId, startDate: startDate, endDate: endDate);
    result.fold(
      (f) => state = PriceState(errorMessage: f.message),
      (q) => state = PriceState(quote: q),
    );
  }

  void reset() => state = const PriceState();
}