import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/providers/core_providers.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCooldown = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendCooldown > 0) _resendCooldown--;
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && index + i < 6; i++) {
        _controllers[index + i].text = digits[i];
      }
      _focusNodes[(index + digits.length).clamp(0, 5)].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  KeyEventResult _onKeyEvent(int index, FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verify() async {
    if (!_isComplete || _isLoading) return;
    setState(() => _isLoading = true);

    final result = await ref.read(verifyOtpUsecaseProvider)(
      email: widget.email,
      code: _otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        String message;
        if (failure is ValidationFailure) {
          message = failure.message;
        } else if (failure is RateLimitFailure) {
          message = '${failure.message} Retry in ${failure.retryAfter}s.';
        } else {
          message = failure.message;
        }
        _showError(message);
        // Si max attempts ou OTP expiré, effacer les champs
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      },
      (_) {
        context.go(AppRoutes.login);
      },
    );
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;

    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();

    final result = await ref.read(resendOtpUsecaseProvider)(
      email: widget.email,
      type: 'register',
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        if (failure is RateLimitFailure) {
          _showError('${failure.message} Retry in ${failure.retryAfter}s.');
        }
        // L'API retourne toujours succès (pas d'enumeration)
      },
      (_) => _startTimer(),
    );

    // Démarrer le timer même si l'API "échoue" (l'API cache les erreurs)
    _startTimer();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 2) return email;
    return '${email[0]}${'•' * (at - 2)}${email[at - 1]}${email.substring(at)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Text(
                  'FlotTrack',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Verify Your Email',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              RichText(
                text: TextSpan(
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: _maskEmail(widget.email),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Code expires in 10 minutes',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text(
                'VERIFICATION CODE',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) => _onDigitChanged(i, v),
                    onKeyEvent: (node, event) => _onKeyEvent(i, node, event),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: _resendCooldown > 0
                    ? RichText(
                        text: TextSpan(
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                          children: [
                            const TextSpan(text: "Didn't receive it? Resend in "),
                            TextSpan(
                              text: '${_resendCooldown}s',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isComplete && !_isLoading ? _verify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textHint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'VERIFY',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Wrong email? '),
                      TextSpan(
                        text: 'Go back',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go(AppRoutes.register),
                      ),
                    ],
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 44,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: onChanged,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            isDense: true,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
