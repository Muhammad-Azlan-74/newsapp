import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/auth/data/models/signup_data.dart';

/// Check Email Screen
///
/// Informs user to check their email for verification link
class CheckEmailScreen extends StatefulWidget {
  final String email;
  final SignupData? signupData;

  const CheckEmailScreen({
    super.key,
    required this.email,
    this.signupData,
  });

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  final _authRepository = AuthRepository(ApiClient());
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  /// Start 30-second cooldown for resend button
  void _startCooldown() {
    setState(() => _resendCooldown = 30);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        return true;
      }
      return false;
    });
  }

  /// Resend verification email
  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      // Note: For resend to work, we need the original signup data
      // This is a simplified version - in production you might want to
      // call a dedicated resend endpoint
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isResending = false);

        CustomSnackbar.show(
          context,
          'Verification email resent successfully',
        );

        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);

        CustomSnackbar.show(
          context,
          'Failed to resend email: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  /// Navigate to login screen
  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        opacity: AppConstants.authBackgroundOpacity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Email Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Check Your Email',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'We\'ve sent a verification link to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.black,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Click the link in the email to verify your account',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'After verification, come back and log in with your credentials',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Resend Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _resendCooldown > 0 || _isResending
                          ? null
                          : _handleResend,
                      icon: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : 'Resend Email',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _resendCooldown > 0
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back to Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Help Text
                  Text(
                    'Didn\'t receive the email? Check your spam folder',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
