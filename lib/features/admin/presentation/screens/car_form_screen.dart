/// -------------------------------------------------------
/// CAR ADD / EDIT SCREEN — FlotTrack Admin
/// -------------------------------------------------------
/// Usage :
///   CarFormScreen()           → mode Add
///   CarFormScreen(car: car)   → mode Edit
/// -------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/car.dart';

class CarFormScreen extends ConsumerStatefulWidget {
  final Car? car; // null = mode Add
  const CarFormScreen({super.key, this.car});

  @override
  ConsumerState<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends ConsumerState<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _seatsCtrl;
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _descCtrl;

  CarStatus _status = CarStatus.available;
  TransmissionType _transmission = TransmissionType.automatic;
  FuelType _fuelType = FuelType.gasoline;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEdit => widget.car != null;

  @override
  void initState() {
    super.initState();
    final c = widget.car;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _brandCtrl = TextEditingController(text: c?.brand ?? '');
    _modelCtrl = TextEditingController(text: c?.model ?? '');
    _yearCtrl = TextEditingController(text: c?.year.toString() ?? '');
    _plateCtrl = TextEditingController(text: c?.licensePlate ?? '');
    _colorCtrl = TextEditingController(text: c?.color ?? '');
    _priceCtrl =
        TextEditingController(text: c?.pricePerDay.toString() ?? '');
    _seatsCtrl = TextEditingController(text: c?.seats.toString() ?? '5');
    _mileageCtrl =
        TextEditingController(text: c?.mileage?.toString() ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    if (c != null) {
      _status = c.status;
      _transmission = c.transmission;
      _fuelType = c.fuelType;
    }
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl, _brandCtrl, _modelCtrl, _yearCtrl, _plateCtrl,
      _colorCtrl, _priceCtrl, _seatsCtrl, _mileageCtrl, _descCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = {
      'name': _nameCtrl.text.trim(),
      'brand': _brandCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': int.parse(_yearCtrl.text.trim()),
      'license_plate': _plateCtrl.text.trim(),
      'color': _colorCtrl.text.trim(),
      'price_per_day': double.parse(_priceCtrl.text.trim()),
      'seats': int.parse(_seatsCtrl.text.trim()),
      'transmission': _transmission == TransmissionType.automatic
          ? 'automatic'
          : 'manual',
      'fuel_type': _fuelType.name,
      'status': _status.name,
      if (_mileageCtrl.text.isNotEmpty)
        'mileage': int.parse(_mileageCtrl.text.trim()),
      if (_descCtrl.text.isNotEmpty)
        'description': _descCtrl.text.trim(),
    };

    // TODO: appeler CreateCarUsecase ou UpdateCarUsecase via provider
    // Exemple :
    // final result = _isEdit
    //   ? await ref.read(updateCarUsecaseProvider)(widget.car!.id, data)
    //   : await ref.read(createCarUsecaseProvider)(data);
    // result.fold(
    //   (f) => setState(() { _isLoading = false; _errorMessage = f.message; }),
    //   (car) { ref.read(carListProvider.notifier).refresh(); Navigator.pop(context); },
    // );

    // Simulation pour UI
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Car updated!' : 'Car added!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Car' : 'Add New Car',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : Text(
                      _isEdit ? 'Save' : 'Create',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Upload placeholder ──────────────
              _ImageUploadCard(),

              const SizedBox(height: 20),

              // ── Infos de base ─────────────────────────
              _SectionCard(
                title: 'BASIC INFO',
                children: [
                  _AppField(
                    label: 'Display Name',
                    hint: 'e.g. BMW i4 M50',
                    controller: _nameCtrl,
                    validator: Validators.required,
                  ),
                  _AppField(
                    label: 'Brand',
                    hint: 'e.g. BMW',
                    controller: _brandCtrl,
                    validator: Validators.required,
                  ),
                  _AppField(
                    label: 'Model',
                    hint: 'e.g. i4 M50',
                    controller: _modelCtrl,
                    validator: Validators.required,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _AppField(
                          label: 'Year',
                          hint: '2024',
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          validator: Validators.required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AppField(
                          label: 'Seats',
                          hint: '5',
                          controller: _seatsCtrl,
                          keyboardType: TextInputType.number,
                          validator: Validators.required,
                        ),
                      ),
                    ],
                  ),
                  _AppField(
                    label: 'License Plate',
                    hint: 'e.g. 12345-A-5',
                    controller: _plateCtrl,
                    validator: Validators.required,
                  ),
                  _AppField(
                    label: 'Color',
                    hint: 'e.g. Midnight Blue',
                    controller: _colorCtrl,
                    validator: Validators.required,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Tarif & Caractéristiques ──────────────
              _SectionCard(
                title: 'PRICING & SPECS',
                children: [
                  _AppField(
                    label: 'Price per day (MAD)',
                    hint: '250',
                    controller: _priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.positiveNumber,
                  ),
                  _AppField(
                    label: 'Mileage (km) — optional',
                    hint: '15000',
                    controller: _mileageCtrl,
                    keyboardType: TextInputType.number,
                  ),

                  // Transmission
                  const SizedBox(height: 8),
                  Text('TRANSMISSION',
                      style: AppTextStyles.labelUppercase.copyWith(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SelectChip(
                        label: 'Automatic',
                        selected:
                            _transmission == TransmissionType.automatic,
                        onTap: () => setState(
                            () => _transmission = TransmissionType.automatic),
                      ),
                      const SizedBox(width: 10),
                      _SelectChip(
                        label: 'Manual',
                        selected:
                            _transmission == TransmissionType.manual,
                        onTap: () => setState(
                            () => _transmission = TransmissionType.manual),
                      ),
                    ],
                  ),

                  // Fuel Type
                  const SizedBox(height: 16),
                  Text('FUEL TYPE',
                      style: AppTextStyles.labelUppercase.copyWith(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: FuelType.values.map((f) {
                      final labels = {
                        FuelType.electric: 'Electric',
                        FuelType.hybrid: 'Hybrid',
                        FuelType.diesel: 'Diesel',
                        FuelType.gasoline: 'Gasoline',
                      };
                      return _SelectChip(
                        label: labels[f]!,
                        selected: _fuelType == f,
                        onTap: () => setState(() => _fuelType = f),
                      );
                    }).toList(),
                  ),

                  // Status
                  const SizedBox(height: 16),
                  Text('INITIAL STATUS',
                      style: AppTextStyles.labelUppercase.copyWith(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SelectChip(
                        label: 'Available',
                        selected: _status == CarStatus.available,
                        color: AppColors.success,
                        onTap: () =>
                            setState(() => _status = CarStatus.available),
                      ),
                      _SelectChip(
                        label: 'Maintenance',
                        selected: _status == CarStatus.maintenance,
                        color: AppColors.error,
                        onTap: () =>
                            setState(() => _status = CarStatus.maintenance),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Description ───────────────────────────
              _SectionCard(
                title: 'DESCRIPTION — optional',
                children: [
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Tell clients about this vehicle...',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textHint),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text(
                          _isEdit ? 'Save Changes' : 'Add Car',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────

class _ImageUploadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: image picker
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 10),
            Text('Add Photos',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            Text('Tap to upload car images',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AppField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AppField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelUppercase.copyWith(
                  fontSize: 10, fontWeight: FontWeight.w700)),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label,
      required this.selected,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: selected ? c : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}