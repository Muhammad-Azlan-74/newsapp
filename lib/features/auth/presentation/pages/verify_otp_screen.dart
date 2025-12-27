import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/repositories/user_preferences_repository.dart';
import 'package:newsapp/core/services/team_image_cache_service.dart';

/// Verify OTP Screen
///
/// Allows users to enter 6-digit OTP for verification
class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final bool isFromSignup;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.isFromSignup = false,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _apiClient = ApiClient();
  late final _authRepository = AuthRepository(_apiClient);
  late final _preferencesRepository = UserPreferencesRepository(_apiClient);
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      CustomSnackbar.show(context, 'Please enter complete OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isFromSignup) {
        // Verify email OTP for signup
        await _authRepository.verifyEmailOtp(widget.email, otp);

        // Fetch favorite teams and cache team images after verification
        try {
          var favoriteTeamsResponse = await _preferencesRepository.getFavoriteTeams();

          // If favoriteTeams is empty but we have a selectedTeam saved, sync it
          if (favoriteTeamsResponse.favoriteTeams.isEmpty) {
            final selectedTeamId = await AuthStorageService.getSelectedTeam();
            if (selectedTeamId != null && selectedTeamId.isNotEmpty) {
              // Update backend with the selected team
              await _preferencesRepository.updateFavoriteTeams([selectedTeamId]);

              // Fetch again to get full team details with images
              favoriteTeamsResponse = await _preferencesRepository.getFavoriteTeams();
            }
          }

          // Cache images for the first favorite team (working with one team for now)
          if (favoriteTeamsResponse.favoriteTeams.isNotEmpty) {
            final team = favoriteTeamsResponse.favoriteTeams.first;
            await TeamImageCacheService.cacheTeamImages(team);

            // Update selectedTeam with the team ID from favorite teams
            await AuthStorageService.saveSelectedTeam(team.id);
          }
        } catch (e) {
          // Continue even if favorite teams fetch fails
          // User can still access the app
        }

        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate to marketplace (user already has token from registration)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
            (route) => false,
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              CustomSnackbar.show(
                context,
                'Email verified successfully!',
              );
            }
          });
        }
      } else {
        // Verify reset OTP for forgot password
        final resetToken = await _authRepository.verifyResetOtp(widget.email, otp);

        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate to reset password screen with token
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(resetToken: resetToken),
            ),
          );
        }
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

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onOtpDeleted(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);

    try {
      if (widget.isFromSignup) {
        // Resend verification OTP
        await _authRepository.resendVerificationOtp(widget.email);
      } else {
        // Resend forgot password OTP
        await _authRepository.forgotPassword(widget.email);
      }

      if (mounted) {
        setState(() => _isResending = false);

        CustomSnackbar.show(
          context,
          'OTP resent successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);

        CustomSnackbar.show(
          context,
          e.toString(),
          isError: true,
        );
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
                          Icons.lock_outline,
                          size: 50,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Title
                      Text(
                        'Verify OTP',
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

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        'Enter the 6-digit code sent to\n${widget.email}',
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

                      // OTP Input Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  _onOtpChanged(index, value);
                                }
                              },
                              onTap: () {
                                _controllers[index].clear();
                              },
                              onEditingComplete: () {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Verify Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerify,
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
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Resend Code
                      Center(
                        child: TextButton(
                          onPressed: _isResending ? null : _handleResend,
                          child: _isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
