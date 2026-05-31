import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class ReservationDetail {
  final int id;
  final String reference;
  final String status;
  final String carName;
  final String? carImageUrl;
  final String? carBrand;
  final String? carModel;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerDay;
  final int totalDays;
  final double totalAmount;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? location;
  final String? rejectionReason;
  final int? cinDocumentId;
  final int? licenseDocumentId;
  final DateTime createdAt;

  ReservationDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.carName,
    this.carImageUrl,
    this.carBrand,
    this.carModel,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.totalDays,
    required this.totalAmount,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.location,
    this.rejectionReason,
    this.cinDocumentId,
    this.licenseDocumentId,
    required this.createdAt,
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json) {
    final carObj = json['car'] as Map<String, dynamic>?;
    final brand = carObj?['brand'] as String? ?? '';
    final model = carObj?['model'] as String? ?? '';
    final carName = carObj != null
        ? '$brand $model'.trim()
        : (json['car_name'] as String? ?? 'Unknown Car');
    final carImage =
        carObj?['image_url'] as String? ?? json['car_image_url'] as String?;

    // Documents
    final docs = json['documents'] as List<dynamic>?;
    int? cinId, licId;
    if (docs != null) {
      for (final d in docs) {
        final doc = d as Map<String, dynamic>;
        final type = (doc['type'] as String? ?? '').toLowerCase();
        if (type == 'cin') cinId = doc['id'] as int?;
        if (type == 'driving_license' || type == 'license') {
          licId = doc['id'] as int?;
        }
      }
    }

    final days = json['total_days'] as int? ??
        DateTime.parse(json['end_date'] as String)
            .difference(DateTime.parse(json['start_date'] as String))
            .inDays;

    return ReservationDetail(
      id: json['id'] as int,
      reference: json['reference'] as String? ??
          '#RRW-${(json['id'] as int).toString().padLeft(5, '0')}',
      status: json['status'] as String? ?? 'pending',
      carName: carName,
      carImageUrl: carImage,
      carBrand: brand.isNotEmpty ? brand : null,
      carModel: model.isNotEmpty ? model : null,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      pricePerDay:
          double.tryParse(json['price_per_day']?.toString() ?? '0') ?? 0,
      totalDays: days,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: json['location'] as String?,
      rejectionReason: json['rejection_reason'] as String? ??
          json['coach_rejection_reason'] as String?,
      cinDocumentId: cinId,
      licenseDocumentId: licId,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => isPending;
  bool get canDownloadContract => isConfirmed || isCompleted;
}

// ─────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────

class ReservationDetailService {
  static const String _baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/client/reservations/{id}
  static Future<ReservationDetail> fetchDetail(int id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$_baseUrl/client/reservations/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return ReservationDetail.fromJson(data);
    }
    throw Exception('Erreur ${response.statusCode}');
  }

  /// POST /api/client/reservations/{id}/cancel
  static Future<void> cancelReservation(int id) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl/client/reservations/$id/cancel'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(
          body['message'] as String? ?? 'Annulation échouée.');
    }
  }

  /// GET /api/client/contracts/{reservationId}/download → PDF bytes
  static Future<File> downloadContract(int reservationId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$_baseUrl/client/contracts/$reservationId/download'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/contract_$reservationId.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
    throw Exception('Téléchargement échoué (${response.statusCode})');
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  ReservationDetail? _detail;
  bool _loading = true;
  String? _error;

  bool _cancelling = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _fmtDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
  String _fmtDatetime(DateTime dt) =>
      DateFormat('d MMM yyyy · HH:mm').format(dt);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail =
          await ReservationDetailService.fetchDetail(widget.reservationId);
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _cancel() async {
    final confirmed = await _showConfirmDialog(
      title: 'Cancel Reservation?',
      message:
          'This action cannot be undone. Your reservation will be cancelled immediately.',
      confirmLabel: 'Yes, Cancel',
      isDanger: true,
    );
    if (!confirmed) return;

    setState(() => _cancelling = true);
    try {
      await ReservationDetailService.cancelReservation(widget.reservationId);
      await _load();
      if (mounted) {
        _showSnack('Réservation annulée avec succès.', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _downloadContract() async {
    setState(() => _downloading = true);
    try {
      final file = await ReservationDetailService.downloadContract(
          widget.reservationId);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        _showSnack('Téléchargement échoué. Réessayez.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (isDanger ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDanger
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline_rounded,
                  color: isDanger ? AppColors.error : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDanger ? AppColors.error : AppColors.primary,
                  ),
                  child: Text(confirmLabel),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text('Impossible de charger la réservation.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final d = _detail!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(d),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarHero(d),
            const SizedBox(height: 20),
            if (d.isRejected && d.rejectionReason != null)
              _buildRejectionBanner(d.rejectionReason!),
            _buildStateMachine(d),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Booking Info',
              icon: Icons.calendar_month_outlined,
              child: _buildBookingInfo(d),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Fare Breakdown',
              icon: Icons.receipt_long_outlined,
              child: _buildFareBreakdown(d),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Personal Details',
              icon: Icons.person_outline_rounded,
              child: _buildPersonalDetails(d),
            ),
            const SizedBox(height: 16),
            _buildReferenceFooter(d),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(d),
    );
  }

  PreferredSizeWidget _buildAppBar(ReservationDetail d) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Reservation Detail',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }

  Widget _buildCarHero(ReservationDetail d) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            if (d.carImageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 8,
                child: Image.network(
                  d.carImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _heroPh(),
                ),
              )
            else
              _heroPh(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VEHICLE',
                          style: AppTextStyles.labelUppercase.copyWith(
                            fontSize: 9,
                            color: AppColors.textHint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(d.carName,
                            style: AppTextStyles.h2.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  _StatusBadge(status: d.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPh() => Container(
        height: 180,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(Icons.directions_car,
              size: 64, color: AppColors.textHint),
        ),
      );

  Widget _buildRejectionBanner(String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block_rounded,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESERVATION REJECTED',
                    style: AppTextStyles.labelUppercase.copyWith(
                      color: AppColors.error,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateMachine(ReservationDetail d) {
    final steps = _stepsFor(d.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS TIMELINE',
            style: AppTextStyles.labelUppercase.copyWith(
              fontSize: 10,
              color: AppColors.textHint,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return _StepRow(
              label: step.label,
              subtitle: step.subtitle,
              state: step.state,
              showConnector: !isLast,
            );
          }),
        ],
      ),
    );
  }

  List<_StepData> _stepsFor(String status) {
    if (status == 'cancelled') {
      return [
        _StepData(
            label: 'Submitted',
            subtitle: 'Reservation created',
            state: _StepState.done),
        _StepData(
            label: 'Cancelled',
            subtitle: 'Cancelled by client',
            state: _StepState.error),
      ];
    }
    if (status == 'rejected') {
      return [
        _StepData(
            label: 'Submitted',
            subtitle: 'Awaiting review',
            state: _StepState.done),
        _StepData(
            label: 'Rejected',
            subtitle: 'Admin rejected the request',
            state: _StepState.error),
      ];
    }
    final order = ['pending', 'approved', 'confirmed', 'active', 'completed'];
    final labels = {
      'pending': ('Submitted', 'Awaiting admin review'),
      'approved': ('Approved', 'Admin approved your request'),
      'confirmed': ('Confirmed', 'Contract ready to download'),
      'active': ('Active', 'Rental in progress'),
      'completed': ('Completed', 'Rental finished'),
    };
    final currentIdx = order.indexOf(status);
    return order.map((s) {
      final idx = order.indexOf(s);
      _StepState stepState;
      if (idx < currentIdx) {
        stepState = _StepState.done;
      } else if (idx == currentIdx) {
        stepState = _StepState.active;
      } else {
        stepState = _StepState.pending;
      }
      final info = labels[s]!;
      return _StepData(label: info.$1, subtitle: info.$2, state: stepState);
    }).toList();
  }

  Widget _buildBookingInfo(ReservationDetail d) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoTile(
                label: 'PICK UP',
                value: _fmtDate(d.startDate),
                icon: Icons.calendar_today_rounded,
              ),
            ),
            Container(
                width: 1,
                height: 44,
                color: AppColors.divider,
                margin:
                    const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: _infoTile(
                label: 'RETURN',
                value: _fmtDate(d.endDate),
                icon: Icons.event_repeat_rounded,
              ),
            ),
          ],
        ),
        if (d.location != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _infoTile(
            label: 'LOCATION',
            value: d.location!,
            icon: Icons.location_on_outlined,
          ),
        ],
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 14),
        _infoTile(
          label: 'DURATION',
          value: '${d.totalDays} day${d.totalDays != 1 ? 's' : ''}',
          icon: Icons.schedule_outlined,
        ),
      ],
    );
  }

  Widget _buildFareBreakdown(ReservationDetail d) {
    return Column(
      children: [
        _fareRow('Daily Rate', '\$${d.pricePerDay.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        _fareRow(
            'Duration', '${d.totalDays} day${d.totalDays != 1 ? 's' : ''}'),
        const SizedBox(height: 10),
        _fareRow('Insurance & Service', 'Included'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1),
        ),
        Row(
          children: [
            Text(
              'TOTAL',
              style: AppTextStyles.labelUppercase
                  .copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            Text(
              '\$${d.totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.price.copyWith(fontSize: 22),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fareRow(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPersonalDetails(ReservationDetail d) {
    return _tableRows({
      'Full Name': d.fullName,
      'Email': d.email,
      'Phone': d.phone,
      'Address': d.address,
    });
  }

  Widget _buildReferenceFooter(ReservationDetail d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REFERENCE',
                style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: AppColors.textHint),
              ),
              const SizedBox(height: 3),
              Text(
                d.reference,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SUBMITTED',
                style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: AppColors.textHint),
              ),
              const SizedBox(height: 3),
              Text(
                _fmtDatetime(d.createdAt),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ReservationDetail d) {
    final showCancel = d.canCancel;
    final showDownload = d.canDownloadContract;

    if (!showCancel && !showDownload) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border:
            Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDownload)
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _downloadContract,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  elevation: 0,
                ),
                icon: _downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  _downloading ? 'Downloading...' : 'Download Contract',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          if (showDownload && showCancel) const SizedBox(height: 10),
          if (showCancel)
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: _cancelling ? null : _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                icon: _cancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.error),
                      )
                    : const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  _cancelling ? 'Cancelling...' : 'Cancel Reservation',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: AppColors.textHint),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tableRows(Map<String, String> data) {
    return Column(
      children: data.entries.toList().asMap().entries.map((e) {
        final isLast = e.key == data.length - 1;
        final item = e.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(item.key,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast) const Divider(height: 0.5, thickness: 0.5),
          ],
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STATUS BADGE WIDGET
// ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.statusActive;
      case 'confirmed':
      case 'approved':
        return AppColors.statusConfirmed;
      case 'pending':
        return AppColors.statusPending;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
      case 'rejected':
        return AppColors.statusCancelled;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STATE MACHINE STEP COMPONENTS
// ─────────────────────────────────────────────────────────────

enum _StepState { done, active, pending, error }

class _StepData {
  final String label;
  final String subtitle;
  final _StepState state;
  const _StepData(
      {required this.label, required this.subtitle, required this.state});
}

class _StepRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final _StepState state;
  final bool showConnector;

  const _StepRow({
    required this.label,
    required this.subtitle,
    required this.state,
    required this.showConnector,
  });

  Color get _dotColor {
    switch (state) {
      case _StepState.done:
        return AppColors.success;
      case _StepState.active:
        return AppColors.primary;
      case _StepState.error:
        return AppColors.error;
      case _StepState.pending:
        return AppColors.divider;
    }
  }

  Color get _lineColor {
    switch (state) {
      case _StepState.done:
      case _StepState.active:
        return AppColors.success.withValues(alpha: 0.4);
      default:
        return AppColors.divider;
    }
  }

  IconData get _icon {
    switch (state) {
      case _StepState.done:
        return Icons.check_rounded;
      case _StepState.active:
        return Icons.radio_button_checked_rounded;
      case _StepState.error:
        return Icons.close_rounded;
      case _StepState.pending:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = state == _StepState.pending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.surfaceVariant
                      : _dotColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon,
                    color: isPending ? AppColors.textHint : _dotColor,
                    size: 15),
              ),
              if (showConnector)
                Container(
                  width: 2,
                  height: 32,
                  color: _lineColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: state == _StepState.active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isPending
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textHint, fontSize: 11),
                ),
                if (showConnector) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}