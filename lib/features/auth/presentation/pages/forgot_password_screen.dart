import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/core/network/api_client.dart';

/// Forgot Password Screen
///
/// Allows users to enter email to receive OTP for password reset
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authRepository = AuthRepository(ApiClient());
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Request password reset OTP
        await _authRepository.forgotPassword(_emailController.text);

        if (mounted) {
          setState(() => _isLoading = false);

          CustomSnackbar.show(
            context,
            'OTP sent to ${_emailController.text}',
          );

          // Navigate to OTP screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                email: _emailController.text,
                isFromSignup: false,
              ),
            ),
          );
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
                          'Forgot Password?',
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
                          'Enter your email address to receive\na verification code',
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

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Next Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleNext,
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
                                    'Next',
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
