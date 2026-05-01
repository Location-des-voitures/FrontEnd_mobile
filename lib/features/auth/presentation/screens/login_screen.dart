import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/providers/core_providers.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

// ══════════════════════════════════════════════════════════
// 🧪 MOCK CONFIG — mettre false quand le backend est prêt
// ══════════════════════════════════════════════════════════
const bool _kUseMock = true;

// Comptes de test :  email → (User, password)
final _mockAccounts = <String, ({User user, String password})>{
  'admin@test.com': (
    user: const User(
      id: 1,
      name: 'Super Admin',
      email: 'admin@test.com',
      role: 'super_admin',
      isActive: true,
      emailVerifiedAt: '2026-01-01T00:00:00Z',
    ),
    password: 'password',
  ),
  'loueur@test.com': (
    user: const User(
      id: 2,
      name: 'Ahmed Loueur',
      email: 'loueur@test.com',
      role: 'admin',
      isActive: true,
      emailVerifiedAt: '2026-01-01T00:00:00Z',
    ),
    password: 'password',
  ),
  'client@test.com': (
    user: const User(
      id: 3,
      name: 'Youssef Client',
      email: 'client@test.com',
      role: 'client',
      isActive: true,
      emailVerifiedAt: '2026-01-01T00:00:00Z',
    ),
    password: 'password',
  ),
};

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ════════════════════════════════════════════════
    // MODE MOCK — AUCUN appel réseau, aucun usecase
    // ════════════════════════════════════════════════
    if (_kUseMock) {
      await Future.delayed(const Duration(milliseconds: 500)); // simule réseau

      if (!mounted) return;
      setState(() => _isLoading = false);

      final account = _mockAccounts[email.toLowerCase()];

      if (account == null || account.password != password) {
        setState(() => _errorMessage =
            'Invalid email or password.\nTest accounts: admin@test.com / loueur@test.com / client@test.com\nPassword: password');
        return;
      }

      // Connecte l'utilisateur → GoRouter redirige automatiquement
      authNotifier.login(account.user);
      return;
    }

    // ════════════════════════════════════════════════
    // MODE RÉEL — backend Laravel requis
    // ════════════════════════════════════════════════
    final result = await ref.read(loginUsecaseProvider)(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        if (failure is ForbiddenFailure) {
          if (failure.message.toLowerCase().contains('verif') ||
              failure.message.toLowerCase().contains('not verified')) {
            context.go(
              '${AppRoutes.verifyEmail}?email=${Uri.encodeComponent(email)}',
            );
          } else {
            setState(() => _errorMessage = failure.message);
          }
        } else if (failure is RateLimitFailure) {
          setState(() => _errorMessage =
              '${failure.message} Retry in ${failure.retryAfter}s.');
        } else {
          setState(() => _errorMessage = failure.message);
        }
      },
      (user) {
        authNotifier.login(user);
      },
    );
  }

  // Remplit les champs avec un compte de test en 1 tap
  void _quickFill(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'password';
      _errorMessage = null;
    });
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
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // ── Bandeau test accounts (mock seulement) ──
              if (_kUseMock) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_outlined,
                              size: 14, color: Color(0xFF856404)),
                          SizedBox(width: 6),
                          Text(
                            'MODE TEST — Tap pour remplir',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF856404),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _QuickLoginChip(
                            label: '⚡ Super Admin',
                            email: 'admin@test.com',
                            onTap: () => _quickFill('admin@test.com'),
                          ),
                          _QuickLoginChip(
                            label: '🚗 Loueur',
                            email: 'loueur@test.com',
                            onTap: () => _quickFill('loueur@test.com'),
                          ),
                          _QuickLoginChip(
                            label: '👤 Client',
                            email: 'client@test.com',
                            onTap: () => _quickFill('client@test.com'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Text(
                'Welcome back.',
                style: GoogleFonts.roboto(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Access your kinetic gallery and bookings.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'EMAIL ADDRESS',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'PASSWORD',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
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
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.forgotPassword),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          'LOG IN',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                      child: Divider(color: AppColors.divider, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: AppColors.divider, thickness: 1)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SIGN IN WITH GOOGLE',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Center(
                child: Column(
                  children: [
                    Text(
                      'FlotTrack',
                      style: GoogleFonts.roboto(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 89, 222),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KINETIC GALLERY & CONCIERGE',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget chip de connexion rapide ───────────────────────
class _QuickLoginChip extends StatelessWidget {
  final String label;
  final String email;
  final VoidCallback onTap;

  const _QuickLoginChip({
    required this.label,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF856404),
          ),
        ),
      ),
    );
  }
}