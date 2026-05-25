/// -------------------------------------------------------
/// CAR PROVIDER — FlotTrack Admin
/// -------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/car_remote_datasource.dart';
import '../../data/repositories/car_repository_impl.dart';
import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../../domain/usecases/car/get_cars_usecase.dart';
import '../../domain/usecases/car/get_car_by_id_usecase.dart';


// ═══════════════════════════════════════════════════════
// INJECTION
// ═══════════════════════════════════════════════════════

final carDatasourceProvider = Provider(
  (ref) => CarRemoteDatasource(client: ref.read(dioClientProvider)),
);

final carRepositoryProvider = Provider<CarRepository>(
  (ref) => CarRepositoryImpl(ref.read(carDatasourceProvider)),
);

final getCarsUsecaseProvider = Provider(
  (ref) => GetCarsUsecase(ref.read(carRepositoryProvider)),
);

final getCarByIdUsecaseProvider = Provider(
  (ref) => GetCarByIdUsecase(ref.read(carRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════

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

  int get availableCount =>
      cars.where((c) => c.status == CarStatus.available).length;
  int get rentedCount =>
      cars.where((c) => c.status == CarStatus.rented).length;
  int get maintenanceCount =>
      cars.where((c) => c.status == CarStatus.maintenance).length;

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
        cars: cars ?? this.cars,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        filters: filters ?? this.filters,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
      );
}

// ═══════════════════════════════════════════════════════
// NOTIFIER — NotifierProvider (Riverpod 2.x)
// ═══════════════════════════════════════════════════════

class CarListNotifier extends Notifier<CarListState> {
  @override
  CarListState build() {
    // Charge automatiquement au premier accès
    Future.microtask(() => loadCars());
    return const CarListState();
  }

  GetCarsUsecase get _getCars => ref.read(getCarsUsecaseProvider);

  Future<void> loadCars({CarFilters? filters}) async {
    final active = filters ?? state.filters;
    state = state.copyWith(isLoading: true, filters: active);

    final result = await _getCars(
      filters: CarFilters(
        search: active.search,
        status: active.status,
        brand: active.brand,
        isActive: active.isActive,
        perPage: active.perPage ?? 15,
        page: 1,
      ),
    );

    result.fold(
  (f) => state = state.copyWith(
    isLoading: false,
    errorMessage: f.message,
  ),
  (PaginatedCars p) => state = state.copyWith(
    cars: p.cars,
    isLoading: false,
    total: p.total,
    currentPage: p.currentPage,
    lastPage: p.lastPage,
    errorMessage: null,
  ),
);
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final result = await _getCars(
      filters: CarFilters(
        search: state.filters.search,
        status: state.filters.status,
        perPage: state.filters.perPage ?? 15,
        page: state.currentPage + 1,
      ),
    );

   result.fold(
  (f) => state = state.copyWith(
    isLoading: false,
    errorMessage: f.message,
  ),
  (PaginatedCars p) => state = state.copyWith(
    cars: [...state.cars, ...p.cars],
    isLoading: false,
    total: p.total,
    currentPage: p.currentPage,
    lastPage: p.lastPage,
    errorMessage: null,
  ),
);
  }

  Future<void> refresh() => loadCars(filters: state.filters);

  Future<void> applyFilters(CarFilters filters) => loadCars(filters: filters);

  void updateCarInList(Car updated) {
    state = state.copyWith(
      cars: state.cars
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
    );
  }

  void removeCarFromList(int id) {
    state = state.copyWith(
      cars: state.cars.where((c) => c.id != id).toList(),
      total: state.total - 1,
    );
  }
}

final carListProvider =
    NotifierProvider<CarListNotifier, CarListState>(CarListNotifier.new);

// ═══════════════════════════════════════════════════════
// DETAIL
// ═══════════════════════════════════════════════════════

final carDetailProvider =
    FutureProvider.family<Car?, int>((ref, id) async {
  final usecase = ref.read(getCarByIdUsecaseProvider);
  final result = await usecase(id);
  return result.fold(
    (f) => throw Exception(f.message),
    (car) => car,
  );
});