library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../providers/reservation_provider.dart';

class ReservationListScreen extends ConsumerStatefulWidget {
  const ReservationListScreen({super.key});

  @override
  ConsumerState<ReservationListScreen> createState() =>
      _ReservationListScreenState();
}

class _ReservationListScreenState extends ConsumerState<ReservationListScreen> {
  final _searchController = TextEditingController();
  ReservationStatus? _selectedFilter;

  static const _filters = <ReservationStatus?>[
    null,
    ReservationStatus.pending,
    ReservationStatus.awaitingPayment,
    ReservationStatus.paymentPendingVerification,
    ReservationStatus.confirmed,
    ReservationStatus.cancelled,
    ReservationStatus.rejected,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reservationListProvider.notifier).loadReservations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() {
    return ref.read(reservationListProvider.notifier).applyFilters(
          ReservationFilters(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            status: _selectedFilter,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reservationListProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F4F0),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(total: state.total),
              const SizedBox(height: 16),
              _SearchBar(
                controller: _searchController,
                onSubmitted: (_) => _applyFilters(),
                onChanged: (_) => _applyFilters(),
              ),
              const SizedBox(height: 16),
              _FilterChips(
                selected: _selectedFilter,
                filters: _filters,
                onSelect: (filter) {
                  setState(() => _selectedFilter = filter);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 20),
              if (state.errorMessage != null)
                _ErrorBanner(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(reservationListProvider.notifier)
                      .loadReservations(),
                ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.reservations.isEmpty
                        ? const _EmptyState()
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(reservationListProvider.notifier)
                                .refresh(),
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: state.reservations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, i) => _ReservationCard(
                                reservation: state.reservations[i],
                                onTap: () => context.push(
                                  '/admin/reservations/${state.reservations[i].id}',
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  const _Header({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total RESERVATIONS',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: 'Search by client...',
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ReservationStatus? selected;
  final List<ReservationStatus?> filters;
  final ValueChanged<ReservationStatus?> onSelect;

  const _FilterChips({
    required this.selected,
    required this.filters,
    required this.onSelect,
  });

  String _label(ReservationStatus? status) => switch (status) {
        null => 'ALL',
        ReservationStatus.pending => 'PENDING',
        ReservationStatus.awaitingPayment => 'AWAITING PAYMENT',
        ReservationStatus.paymentPendingVerification => 'VERIFY',
        ReservationStatus.confirmed => 'CONFIRMED',
        ReservationStatus.completed => 'COMPLETED',
        ReservationStatus.cancelled => 'CANCELLED',
        ReservationStatus.rejected => 'REJECTED',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final filter = filters[i];
          final isSelected = selected == filter;
          return ChoiceChip(
            label: Text(_label(filter)),
            selected: isSelected,
            onSelected: (_) => onSelect(filter),
            selectedColor: const Color(0xFF2952FF),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF555555),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _ReservationCard({required this.reservation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        size: 36, color: Color(0xFFCCCCCC)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reservation.carName.isEmpty
                                    ? 'Vehicle'
                                    : reservation.carName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: reservation.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.clientName.isEmpty
                              ? reservation.clientEmail
                              : reservation.clientName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 15, color: Color(0xFF888888)),
                  const SizedBox(width: 6),
                  Text(
                    '${_shortDate(reservation.startDate)} -> ${_shortDate(reservation.endDate)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${reservation.totalPrice.toStringAsFixed(0)} MAD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const _StatusBadge({required this.status});

  (String, Color, Color) get _config => switch (status) {
        ReservationStatus.confirmed => (
            'CONFIRMED',
            const Color(0xFF00A86B),
            const Color(0xFFE6F7F2),
          ),
        ReservationStatus.pending => (
            'PENDING',
            const Color(0xFFFF6B35),
            const Color(0xFFFFF0EB),
          ),
        ReservationStatus.awaitingPayment => (
            'AWAITING PAYMENT',
            const Color(0xFF2952FF),
            const Color(0xFFEBEFFF),
          ),
        ReservationStatus.paymentPendingVerification => (
            'VERIFY',
            const Color(0xFFFF9500),
            const Color(0xFFFFF8EC),
          ),
        ReservationStatus.cancelled => (
            'CANCELLED',
            const Color(0xFF999999),
            const Color(0xFFF2F2F2),
          ),
        ReservationStatus.completed => (
            'COMPLETED',
            const Color(0xFF34C759),
            const Color(0xFFEFFAF2),
          ),
        ReservationStatus.rejected => (
            'REJECTED',
            const Color(0xFFFF3B30),
            const Color(0xFFFFECEB),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: const Color(0xFFFFECEB),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          title: Text(message),
          trailing: IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            'Aucune reservation trouvee',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
