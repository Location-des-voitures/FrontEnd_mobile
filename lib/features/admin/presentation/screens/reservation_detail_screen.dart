library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reservation.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(reservationDetailProvider(reservationId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F4F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F4F0),
          elevation: 0,
          title: const Text('Reservation Details'),
        ),
        body: reservationAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(reservationDetailProvider(reservationId)),
          ),
          data: (reservation) {
            if (reservation == null) {
              return const _ErrorState(message: 'Reservation introuvable');
            }
            return _ReservationBody(reservation: reservation);
          },
        ),
      ),
    );
  }
}

class _ReservationBody extends ConsumerWidget {
  final Reservation reservation;

  const _ReservationBody({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _HeroCard(reservation: reservation),
        const SizedBox(height: 16),
        _StatusStepper(status: reservation.status),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.calendar_month_outlined,
          label: 'Reservation Dates',
          value:
              '${_formatDate(reservation.startDate)} -> ${_formatDate(reservation.endDate)}',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.access_time_rounded,
          label: 'Duration',
          value: '${reservation.durationDays} days',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.monetization_on_outlined,
          label: 'Total Amount',
          value: '${reservation.totalPrice.toStringAsFixed(0)} MAD',
          accent: true,
        ),
        const SizedBox(height: 12),
        _ClientCard(reservation: reservation),
        const SizedBox(height: 20),
        _ActionSection(reservation: reservation),
        const SizedBox(height: 20),
        _DocumentSection(reservation: reservation),
      ],
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _HeroCard extends StatelessWidget {
  final Reservation reservation;

  const _HeroCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: Colors.white70, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: reservation.status),
                const SizedBox(height: 10),
                Text(
                  reservation.carName.isEmpty ? 'Vehicle' : reservation.carName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reservation.carLicensePlate,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends ConsumerWidget {
  final Reservation reservation;

  const _ActionSection({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reservationListProvider.notifier);

    Future<void> refreshDetail() async {
      ref.invalidate(reservationDetailProvider(reservation.id));
      await ref.read(reservationListProvider.notifier).refresh();
    }

    if (reservation.status == ReservationStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final ok = await notifier.approveReservation(reservation.id);
                if (!context.mounted) return;
                _toast(context, ok ? 'Reservation approved' : 'Action failed');
                if (ok) await refreshDetail();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Approve'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final reason = await _askReason(context);
                if (reason == null || reason.trim().isEmpty) return;
                final ok = await notifier.rejectReservation(
                  reservation.id,
                  reason: reason.trim(),
                );
                if (!context.mounted) return;
                _toast(context, ok ? 'Reservation rejected' : 'Action failed');
                if (ok) await refreshDetail();
              },
              icon: const Icon(Icons.close_rounded),
              label: const Text('Reject'),
            ),
          ),
        ],
      );
    }

    if (reservation.status == ReservationStatus.paymentPendingVerification) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: reservation.latestPaymentId == null
                ? null
                : () => _toast(
                      context,
                      'Receipt endpoint: /admin/reservations/payments/${reservation.latestPaymentId}/receipt',
                    ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('View Receipt'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: reservation.latestPaymentId == null
                ? null
                : () async {
                    final ok = await notifier
                        .verifyPayment(reservation.latestPaymentId!);
                    if (!context.mounted) return;
                    _toast(context,
                        ok ? 'Payment verified, contract generated' : 'Action failed');
                    if (ok) await refreshDetail();
                  },
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Verify Payment'),
          ),
        ],
      );
    }

    if (reservation.status == ReservationStatus.awaitingPayment) {
      return const _ReadonlyNotice(
        text: 'Waiting for client payment. Invoice is generated.',
      );
    }

    if (reservation.status == ReservationStatus.confirmed) {
      return const _ReadonlyNotice(
        text: 'Reservation confirmed. Contract is ready if returned by API.',
      );
    }

    return const _ReadonlyNotice(text: 'Read-only state.');
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject reservation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  final Reservation reservation;

  const _DocumentSection({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel(text: 'RELATED DOCUMENTS'),
        const SizedBox(height: 10),
        _DocumentRow(
          icon: Icons.receipt_long_rounded,
          label: 'Download Invoice PDF',
          enabled: reservation.invoiceId != null,
          onTap: () => _toast(
            context,
            'Invoice endpoint: /admin/invoices/${reservation.invoiceId}/pdf',
          ),
        ),
        const SizedBox(height: 8),
        _DocumentRow(
          icon: Icons.description_outlined,
          label: 'Download Contract PDF',
          enabled: reservation.contractId != null,
          onTap: () => _toast(
            context,
            'Contract endpoint: /admin/contracts/${reservation.contractId}/pdf',
          ),
        ),
      ],
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: accent
            ? const Border(left: BorderSide(color: Color(0xFF2952FF), width: 4))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2952FF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Reservation reservation;

  const _ClientCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2952FF),
            child: Text(reservation.initials,
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.clientName.isEmpty
                      ? 'Client'
                      : reservation.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  reservation.clientEmail,
                  style: const TextStyle(color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final ReservationStatus status;

  const _StatusStepper({required this.status});

  int get _activeStep => switch (status) {
        ReservationStatus.pending => 0,
        ReservationStatus.awaitingPayment => 1,
        ReservationStatus.paymentPendingVerification => 2,
        ReservationStatus.confirmed => 3,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    const steps = [
      'PENDING',
      'PAYMENT',
      'VERIFY',
      'CONFIRMED',
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final active = index <= _activeStep;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    active ? const Color(0xFF2952FF) : const Color(0xFFE5E5E5),
                child: Icon(
                  active ? Icons.check_rounded : Icons.circle_outlined,
                  size: 16,
                  color: active ? Colors.white : const Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                      active ? const Color(0xFF2952FF) : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const _StatusBadge({required this.status});

  String get label => switch (status) {
        ReservationStatus.pending => 'PENDING',
        ReservationStatus.awaitingPayment => 'AWAITING PAYMENT',
        ReservationStatus.paymentPendingVerification => 'PENDING VERIFICATION',
        ReservationStatus.confirmed => 'CONFIRMED',
        ReservationStatus.cancelled => 'CANCELLED',
        ReservationStatus.completed => 'COMPLETED',
        ReservationStatus.rejected => 'REJECTED',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _DocumentRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: enabled ? const Color(0xFF2952FF) : null),
      title: Text(label),
      trailing: const Icon(Icons.download_rounded),
      onTap: enabled ? onTap : null,
    );
  }
}

class _ReadonlyNotice extends StatelessWidget {
  final String text;

  const _ReadonlyNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2952FF)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
