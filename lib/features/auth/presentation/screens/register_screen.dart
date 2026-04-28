import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/providers/core_providers.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  int _passwordStrength = 0;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength = _evaluateStrength(_passwordController.text);
      if (_passwordError != null) _validatePassword();
      if (_confirmPasswordError != null) _validateConfirmPassword();
    });
  }

  int _evaluateStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    if (score <= 1) return 1;
    if (score <= 2) return 2;
    return 3;
  }

  void _validateName() {
    final v = _nameController.text.trim();
    setState(() {
      if (v.isEmpty) {
        _nameError = 'Full name is required';
      } else if (v.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail() {
    final v = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
    setState(() {
      if (v.isEmpty) {
        _emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(v)) {
        _emailError = 'Enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final v = _passwordController.text;
    setState(() {
      if (v.isEmpty) {
        _passwordError = 'Password is required';
      } else if (v.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _validateAll() {
    _validateName();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _signUp() async {
    if (!_validateAll()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    final result = await ref.read(registerUsecaseProvider)(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          setState(() {
            _nameError = failure.fieldError('name');
            _emailError = failure.fieldError('email');
            _passwordError = failure.fieldError('password');
            if (_nameError == null && _emailError == null && _passwordError == null) {
              _generalError = failure.message;
            }
          });
        } else if (failure is RateLimitFailure) {
          setState(() => _generalError =
              '${failure.message} Retry in ${failure.retryAfter}s.');
        } else {
          setState(() => _generalError = failure.message);
        }
      },
      (_) {
        context.go(
          '${AppRoutes.verifyEmail}?email=${Uri.encodeComponent(_emailController.text.trim())}',
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.roboto(fontSize: 14, color: AppColors.textHint),
      errorText: errorText,
      errorStyle: GoogleFonts.roboto(fontSize: 11, color: AppColors.error),
      suffixIcon: suffixIcon,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      isDense: true,
    );
  }

  TextStyle get _inputTextStyle =>
      GoogleFonts.roboto(fontSize: 14, color: AppColors.textPrimary);

  TextStyle _labelStyle() => GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      );

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
                'Create Account',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Join the exclusive world of kinetic travel.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              Text('FULL NAME', style: _labelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) { if (_nameError != null) _validateName(); },
                onEditingComplete: _validateName,
                decoration: _fieldDecoration(
                  hint: 'ALEXANDER VANCE',
                  errorText: _nameError,
                ),
                style: _inputTextStyle,
              ),

              const SizedBox(height: 24),

              Text('EMAIL ADDRESS', style: _labelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) { if (_emailError != null) _validateEmail(); },
                onEditingComplete: _validateEmail,
                decoration: _fieldDecoration(
                  hint: 'vance@kinetic.rrw',
                  errorText: _emailError,
                ),
                style: _inputTextStyle,
              ),

              const SizedBox(height: 24),

              Text('PASSWORD', style: _labelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                onChanged: (_) { if (_passwordError != null) _validatePassword(); },
                onEditingComplete: _validatePassword,
                decoration: _fieldDecoration(
                  hint: '••••••••',
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                style: _inputTextStyle,
              ),

              if (_passwordStrength > 0) ...[
                const SizedBox(height: 10),
                _PasswordStrengthBar(strength: _passwordStrength),
              ],

              const SizedBox(height: 24),

              Text('CONFIRM PASSWORD', style: _labelStyle()),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                onChanged: (_) {
                  if (_confirmPasswordError != null) _validateConfirmPassword();
                },
                onEditingComplete: _validateConfirmPassword,
                decoration: _fieldDecoration(
                  hint: '••••••••',
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                  ),
                ),
                style: _inputTextStyle,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    foregroundColor: Colors.white,
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
                          'SIGN UP',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              if (_generalError != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _generalError!,
                        style:
                            GoogleFonts.roboto(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'By creating an account, you agree to FlotTrack\'s\n',
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
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
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log in',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go(AppRoutes.login),
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

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    final color = switch (strength) {
      1 => const Color(0xFFE53935),
      2 => const Color(0xFFFB8C00),
      _ => const Color(0xFF43A047),
    };
    final label = switch (strength) {
      1 => 'Weak',
      2 => 'Medium',
      _ => 'Strong',
    };

    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 4,
            children: List.generate(3, (i) {
              final filled = i < strength;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  decoration: BoxDecoration(
                    color: filled ? color : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
