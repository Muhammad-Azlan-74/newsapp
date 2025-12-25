import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/core/network/api_client.dart';

/// Reset Password Screen
///
/// Allows users to set a new password after OTP verification
class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository(ApiClient());
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Reset password with reset token
        await _authRepository.resetPassword(
          widget.resetToken,
          _passwordController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate to login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );

          // Show success message
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              CustomSnackbar.show(
                context,
                'Password reset successfully! Please login',
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          CustomSnackbar.show(
            context,
            e.toString(),
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        opacity: AppConstants.authBackgroundOpacity,
        child: Column(
          children: [
            // Back Button
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 50,
                            color: AppColors.black,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Title
                        Text(
                          'Reset Password',
                          style:
                              Theme.of(context).textTheme.headlineLarge?.copyWith(
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

                        const SizedBox(height: 10),

                        // Description
                        Text(
                          'Enter your new password',
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

                        const SizedBox(height: 40),

                        // New Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            hintText: 'Enter your new password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your new password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Retype New Password',
                            hintText: 'Re-enter your new password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Reset Password Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleResetPassword,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
