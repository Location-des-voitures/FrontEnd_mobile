import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'booking_confirmation_screen.dart';

import '../../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

class CarSummary {
  final int id;
  final String brand;
  final String model;
  final double pricePerDay;
  final String? imageUrl;

  CarSummary({
    required this.id,
    required this.brand,
    required this.model,
    required this.pricePerDay,
    this.imageUrl,
  });

  String get fullName => '$brand $model';
}

class PriceSummary {
  final double pricePerDay;
  final int totalDays;
  final double totalAmount;

  PriceSummary({
    required this.pricePerDay,
    required this.totalDays,
    required this.totalAmount,
  });
}

// ─────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────

class ReservationApiService {
  static const String _baseUrl = 'https://YOUR_API_BASE_URL/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// POST /api/client/reservations  (multipart/form-data)
  /// FIX: retourne maintenant le body complet pour que _submit() puisse l'utiliser
  static Future<Map<String, dynamic>> submitReservation({
    required int carId,
    required String startDate,
    required String endDate,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required File cinFile,
    required File drivingLicenseFile,
    String? birthDate,
    String? licenseNumber,
    String? licenseExpiration,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('$_baseUrl/client/reservations');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    request.fields['car_id'] = carId.toString();
    request.fields['start_date'] = startDate;
    request.fields['end_date'] = endDate;
    request.fields['full_name'] = fullName;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['address'] = address;
    if (birthDate != null && birthDate.isNotEmpty) {
      request.fields['birth_date'] = birthDate;
    }
    if (licenseNumber != null && licenseNumber.isNotEmpty) {
      request.fields['license_number'] = licenseNumber;
    }
    if (licenseExpiration != null && licenseExpiration.isNotEmpty) {
      request.fields['license_expiration'] = licenseExpiration;
    }

    final cinExt = cinFile.path.split('.').last.toLowerCase();
    request.files.add(
      await http.MultipartFile.fromPath(
        'cin',
        cinFile.path,
        contentType: _mediaType(cinExt),
      ),
    );

    final dlExt = drivingLicenseFile.path.split('.').last.toLowerCase();
    request.files.add(
      await http.MultipartFile.fromPath(
        'driving_license',
        drivingLicenseFile.path,
        contentType: _mediaType(dlExt),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // FIX: body est déclaré ici dans le service, pas dans _submit()
    final responseBody = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return responseBody; // ← retourné proprement
    }

    final message =
        responseBody['message'] as String? ?? 'Une erreur est survenue.';
    final errors = responseBody['errors'] as Map<String, dynamic>?;
    throw _ApiException(
      message: message,
      errors: errors,
      statusCode: response.statusCode,
    );
  }

  static MediaType _mediaType(String ext) {
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }
}

class _ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int statusCode;

  _ApiException({
    required this.message,
    this.errors,
    required this.statusCode,
  });

  String? fieldError(String field) {
    final list = errors?[field];
    if (list is List && list.isNotEmpty) return list.first as String;
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────

class ReservationFormScreen extends StatefulWidget {
  final CarSummary car;
  final DateTime startDate;
  final DateTime endDate;
  final PriceSummary? priceSummary;

  const ReservationFormScreen({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    this.priceSummary,
  });

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  int _step = 0;

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _licenseNumberCtrl = TextEditingController();
  final _licenseExpirationCtrl = TextEditingController();

  DateTime? _birthDate;
  DateTime? _licenseExpiration;

  File? _cinFile;
  File? _licenseFile;

  Map<String, String> _fieldErrors = {};
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _birthDateCtrl.dispose();
    _licenseNumberCtrl.dispose();
    _licenseExpirationCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────

  String _fmtDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);
  String _fmtApi(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
  String _fileName(File f) => f.path.split('/').last;

  Future<void> _pickDate({required bool isBirthDate}) async {
    final now = DateTime.now();
    final initial = isBirthDate
        ? (_birthDate ?? DateTime(1990, 1, 1))
        : (_licenseExpiration ?? now.add(const Duration(days: 365)));
    final first = isBirthDate ? DateTime(1940) : now;
    final last =
        isBirthDate ? now : now.add(const Duration(days: 365 * 20));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (isBirthDate) {
        _birthDate = picked;
        _birthDateCtrl.text = _fmtDate(picked);
      } else {
        _licenseExpiration = picked;
        _licenseExpirationCtrl.text = _fmtDate(picked);
      }
    });
  }

  Future<void> _pickFile({required bool isCin}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCin ? 'CIN / ID Card' : 'Driving License',
                style: AppTextStyles.h3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                'Choisissez la source du fichier (JPG, PNG ou PDF)',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),
              _sheetTile(
                icon: Icons.photo_camera_outlined,
                label: 'Prendre une photo',
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromSource(
                      isCin: isCin, source: ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              _sheetTile(
                icon: Icons.photo_library_outlined,
                label: 'Galerie photos',
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromSource(
                      isCin: isCin, source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickFromSource({
    required bool isCin,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      if (isCin) {
        _cinFile = File(picked.path);
        _fieldErrors.remove('cin');
      } else {
        _licenseFile = File(picked.path);
        _fieldErrors.remove('driving_license');
      }
    });
  }

  // ─────────────────────────────────────────────────────
  // STEP NAVIGATION
  // ─────────────────────────────────────────────────────

  void _nextStep() {
    if (_step == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    if (_step == 1) {
      if (_cinFile == null || _licenseFile == null) {
        _showSnack('Veuillez uploader les deux documents requis.',
            isError: true);
        return;
      }
    }
    if (_step < 2) setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  // ─────────────────────────────────────────────────────
  // SUBMIT
  // FIX: le résultat de submitReservation est capturé dans `apiResponse`
  //      (plus de référence à `body` qui n'existe pas dans ce scope)
  // ─────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _fieldErrors = {};
    });

    try {
      // FIX ① : on capture la valeur retournée par le service
      final apiResponse = await ReservationApiService.submitReservation(
        carId: widget.car.id,
        startDate: _fmtApi(widget.startDate),
        endDate: _fmtApi(widget.endDate),
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        cinFile: _cinFile!,
        drivingLicenseFile: _licenseFile!,
        birthDate: _birthDate != null ? _fmtApi(_birthDate!) : null,
        licenseNumber: _licenseNumberCtrl.text.trim().isEmpty
            ? null
            : _licenseNumberCtrl.text.trim(),
        licenseExpiration:
            _licenseExpiration != null ? _fmtApi(_licenseExpiration!) : null,
      );

      if (!mounted) return;

      // FIX ② : on utilise `apiResponse` (plus `body`)
      final apiData = apiResponse['data'] as Map<String, dynamic>;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: BookingConfirmation.fromApiResponse(
              data: apiData,
              carName: widget.car.fullName,
              carImageUrl: widget.car.imageUrl,
              location: _addressCtrl.text.trim(),
            ),
          ),
        ),
      );
    } on _ApiException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        final mapped = <String, String>{};
        e.errors!.forEach((key, value) {
          final list = value as List;
          if (list.isNotEmpty) mapped[key] = list.first as String;
        });
        setState(() => _fieldErrors = mapped);
        _showSnack(e.message, isError: true);
        // FIX ③ : blocs if avec accolades (curly_braces warning)
        if (_hasStep0Errors(mapped)) {
          setState(() => _step = 0);
        } else if (mapped.containsKey('cin') ||
            mapped.containsKey('driving_license')) {
          setState(() => _step = 1);
        }
      } else {
        _showSnack(e.message, isError: true);
      }
    } catch (e) {
      _showSnack('Erreur réseau. Vérifiez votre connexion.', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool _hasStep0Errors(Map<String, String> m) =>
      m.containsKey('full_name') ||
      m.containsKey('email') ||
      m.containsKey('phone') ||
      m.containsKey('address');

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarSummary(),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _step == 0
                          ? _buildStep0Personal()
                          : _step == 1
                              ? _buildStep1Documents()
                              : _buildStep2Review(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: _step > 0 ? _prevStep : () => Navigator.pop(context),
      ),
      title: Text(
        'THE BOOKING',
        style: AppTextStyles.labelUppercase.copyWith(
          fontSize: 13,
          color: AppColors.textPrimary,
          letterSpacing: 2.5,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // STEPPER
  // ─────────────────────────────────────────────────────

  Widget _buildStepper() {
    const steps = ['Personal Info', 'Documents', 'Confirm'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < _step;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.primary : AppColors.divider,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < _step;
          final isActive = stepIndex == _step;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDone || isActive
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isDone
                        ? AppColors.primary
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isActive ? Colors.white : AppColors.textHint,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: isActive || isDone
                      ? AppColors.primary
                      : AppColors.textHint,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // CAR SUMMARY
  // ─────────────────────────────────────────────────────

  Widget _buildCarSummary() {
    final days = widget.endDate.difference(widget.startDate).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (widget.car.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                widget.car.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _carImagePh(),
              ),
            )
          else
            _carImagePh(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Fleet',
                            style: AppTextStyles.labelUppercase.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.car.fullName,
                            style: AppTextStyles.h3.copyWith(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.car.pricePerDay.round()}',
                          style: AppTextStyles.price.copyWith(fontSize: 20),
                        ),
                        Text(
                          'per day',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _scheduleChip(
                      icon: Icons.calendar_today_rounded,
                      label: 'PICK UP',
                      value: _fmtDate(widget.startDate),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    _scheduleChip(
                      icon: Icons.event_repeat_rounded,
                      label: 'RETURN',
                      value: _fmtDate(widget.endDate),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '$days day${days != 1 ? 's' : ''}',
                        style: AppTextStyles.labelUppercase.copyWith(
                          color: AppColors.primary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carImagePh() => Container(
        height: 120,
        color: AppColors.surfaceVariant,
        child: const Center(
          child:
              Icon(Icons.directions_car, size: 48, color: AppColors.textHint),
        ),
      );

  Widget _scheduleChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(fontSize: 9, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // STEP 0 — PERSONAL INFO
  // ─────────────────────────────────────────────────────

  Widget _buildStep0Personal() {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Location Details'),
        const SizedBox(height: 16),
        _inputField(
          controller: _fullNameCtrl,
          label: 'Full Name',
          hint: 'Hamza Lalami',
          icon: Icons.person_outline_rounded,
          apiError: _fieldErrors['full_name'],
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nom complet requis' : null,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _emailCtrl,
          label: 'Email Address',
          hint: 'hamza@example.com',
          icon: Icons.mail_outline_rounded,
          apiError: _fieldErrors['email'],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email requis';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
              return 'Email invalide';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _phoneCtrl,
          label: 'Phone Number',
          hint: '0600000000',
          icon: Icons.phone_outlined,
          apiError: _fieldErrors['phone'],
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _addressCtrl,
          label: 'Address',
          hint: 'Casablanca, Maroc',
          icon: Icons.location_on_outlined,
          apiError: _fieldErrors['address'],
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Adresse requise' : null,
          keyboardType: TextInputType.streetAddress,
          maxLines: 2,
        ),
        const SizedBox(height: 28),
        _sectionLabel('Optional Info'),
        const SizedBox(height: 16),
        _dateTapField(
          controller: _birthDateCtrl,
          label: 'Date of Birth',
          icon: Icons.cake_outlined,
          onTap: () => _pickDate(isBirthDate: true),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // STEP 1 — DOCUMENTS
  // ─────────────────────────────────────────────────────

  Widget _buildStep1Documents() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Required Documents'),
        const SizedBox(height: 8),
        Text(
          'Uploadez une photo claire ou un scan PDF de vos documents.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: 20),
        _documentUploader(
          label: "CIN / Carte d'Identité",
          subtitle: 'Recto ou recto-verso (JPG, PNG ou PDF)',
          icon: Icons.badge_outlined,
          file: _cinFile,
          hasError: _fieldErrors.containsKey('cin'),
          apiError: _fieldErrors['cin'],
          onTap: () => _pickFile(isCin: true),
          onRemove: () => setState(() {
            _cinFile = null;
            _fieldErrors.remove('cin');
          }),
        ),
        const SizedBox(height: 16),
        _documentUploader(
          label: 'Permis de Conduire',
          subtitle: 'Recto ou recto-verso (JPG, PNG ou PDF)',
          icon: Icons.drive_file_rename_outline_rounded,
          file: _licenseFile,
          hasError: _fieldErrors.containsKey('driving_license'),
          apiError: _fieldErrors['driving_license'],
          onTap: () => _pickFile(isCin: false),
          onRemove: () => setState(() {
            _licenseFile = null;
            _fieldErrors.remove('driving_license');
          }),
        ),
        const SizedBox(height: 28),
        _sectionLabel('License Details (optional)'),
        const SizedBox(height: 16),
        _inputField(
          controller: _licenseNumberCtrl,
          label: 'License Number',
          hint: 'AB-12345-CD',
          icon: Icons.numbers_rounded,
          apiError: _fieldErrors['license_number'],
        ),
        const SizedBox(height: 16),
        _dateTapField(
          controller: _licenseExpirationCtrl,
          label: 'License Expiration',
          icon: Icons.event_available_outlined,
          onTap: () => _pickDate(isBirthDate: false),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // STEP 2 — REVIEW
  // FIX: variable `total` maintenant utilisée dans le widget
  // ─────────────────────────────────────────────────────

  Widget _buildStep2Review() {
    final days = widget.endDate.difference(widget.startDate).inDays;
    // FIX ④ : `total` utilisé directement dans le Text ci-dessous
    final total =
        widget.priceSummary?.totalAmount ?? (widget.car.pricePerDay * days);

    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Fare Breakdown'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Column(
            children: [
              _fareRow('Daily Rate', '\$${widget.car.pricePerDay.round()}.00'),
              const SizedBox(height: 12),
              _fareRow(
                  'Rental Duration', '$days day${days != 1 ? 's' : ''}'),
              const SizedBox(height: 12),
              _fareRow('Insurance & Service', 'Included'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Text(
                    'TOTAL PRICE',
                    style: AppTextStyles.labelUppercase
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  // FIX ④ : `total` est bien utilisé ici
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.price.copyWith(fontSize: 26),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('Your Details'),
        const SizedBox(height: 16),
        _reviewTable({
          'Full Name': _fullNameCtrl.text,
          'Email': _emailCtrl.text,
          'Phone': _phoneCtrl.text,
          'Address': _addressCtrl.text,
          if (_birthDate != null) 'Birth Date': _fmtDate(_birthDate!),
        }),
        const SizedBox(height: 20),
        _sectionLabel('Documents'),
        const SizedBox(height: 16),
        _docReviewTile(
            label: 'CIN', file: _cinFile, icon: Icons.badge_outlined),
        const SizedBox(height: 10),
        _docReviewTile(
          label: 'Permis de conduire',
          file: _licenseFile,
          icon: Icons.drive_file_rename_outline_rounded,
        ),
        if (_licenseNumberCtrl.text.isNotEmpty ||
            _licenseExpiration != null) ...[
          const SizedBox(height: 20),
          _sectionLabel('License Details'),
          const SizedBox(height: 16),
          _reviewTable({
            if (_licenseNumberCtrl.text.isNotEmpty)
              'License N°': _licenseNumberCtrl.text,
            if (_licenseExpiration != null)
              'Expiration': _fmtDate(_licenseExpiration!),
          }),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.statusPending.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: AppColors.statusPending.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.statusPending, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Votre réservation sera soumise à validation par l\'admin avant confirmation. '
                  'Vous ne pouvez annuler que les réservations en statut "Pending".',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.statusPending,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
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
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _reviewTable(Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        children: data.entries.toList().asMap().entries.map((e) {
          final isLast = e.key == data.length - 1;
          final item = e.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
    );
  }

  Widget _docReviewTile({
    required String label,
    required File? file,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                  file != null ? _fileName(file) : 'Non uploadé',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: file != null ? AppColors.textHint : AppColors.error,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            file != null ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: file != null ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _step == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _submitting ? null : (isLast ? _submit : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'CONFIRM RESERVATION' : 'Continue',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLast
                              ? Icons.bolt_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          if (_step > 0) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: _prevStep,
              child: Text(
                'Retour',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // SHARED UI COMPONENTS
  // ─────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelUppercase.copyWith(
        fontSize: 10,
        color: AppColors.textHint,
        letterSpacing: 2,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? apiError,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    final hasError = apiError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.divider,
              width: hasError ? 1.5 : 0.8,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium,
            validator: validator,
            onChanged: (_) {
              final key = _fieldKeyFromLabel(label);
              if (_fieldErrors.containsKey(key)) {
                setState(() => _fieldErrors.remove(key));
              }
            },
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(icon,
                  size: 18,
                  color: hasError ? AppColors.error : AppColors.textHint),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: hasError ? AppColors.error : AppColors.textHint,
              ),
              floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
                color: hasError ? AppColors.error : AppColors.primary,
              ),
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            ),
          ),
        ),
        if (apiError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(apiError,
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ),
        ],
      ],
    );
  }

  String _fieldKeyFromLabel(String label) {
    const map = {
      'Full Name': 'full_name',
      'Email Address': 'email',
      'Phone Number': 'phone',
      'Address': 'address',
      'License Number': 'license_number',
    };
    return map[label] ?? label.toLowerCase().replaceAll(' ', '_');
  }

  Widget _dateTapField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textHint),
            const SizedBox(width: 12),
            Expanded(
              child: controller.text.isEmpty
                  ? Text(label,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textHint))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary, fontSize: 10)),
                        Text(controller.text,
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _documentUploader({
    required String label,
    required String subtitle,
    required IconData icon,
    required File? file,
    required bool hasError,
    required String? apiError,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final uploaded = file != null;
    return GestureDetector(
      onTap: uploaded ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: hasError
                ? AppColors.error
                : uploaded
                    ? AppColors.success
                    : AppColors.divider,
            width: hasError || uploaded ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: uploaded
                        ? AppColors.success.withValues(alpha: 0.10)
                        : hasError
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Icon(
                    uploaded ? Icons.check_rounded : icon,
                    color: uploaded
                        ? AppColors.success
                        : hasError
                            ? AppColors.error
                            : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(label,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'REQUIS',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                                fontSize: 8,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        uploaded ? _fileName(file) : subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (uploaded)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 16),
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: const Icon(Icons.upload_rounded,
                        color: AppColors.primary, size: 16),
                  ),
              ],
            ),
            if (uploaded && _isImage(file)) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                child: Image.file(file,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
            ],
            if (apiError != null) ...[
              const SizedBox(height: 8),
              Text(apiError,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.error)),
            ],
          ],
        ),
      ),
    );
  }

  bool _isImage(File f) {
    final ext = f.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
  }
}