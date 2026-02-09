import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/features/auth/data/models/signup_data.dart';
import 'package:newsapp/features/auth/data/models/register_request.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/auth/presentation/pages/verify_otp_screen.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';

/// Select Team Screen
///
/// Allows users to select their team before registration
class SelectTeamScreen extends StatefulWidget {
  final SignupData signupData;

  const SelectTeamScreen({
    super.key,
    required this.signupData,
  });

  @override
  State<SelectTeamScreen> createState() => _SelectTeamScreenState();
}

class _SelectTeamScreenState extends State<SelectTeamScreen> {
  final _authRepository = AuthRepository(ApiClient());
  String? _selectedTeam;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _teams = [
    {
      'id': '6947a3a8d9ba1ed105c021c1',
      'name': 'Kansas City',
      'fullName': 'Kansas City Chiefs',
      'logo': AppAssets.chiefsLogo,
    },
    {
      'id': '6947a3a8d9ba1ed105c021c2',
      'name': 'Denver',
      'fullName': 'Denver Broncos',
      'logo': AppAssets.broncosLogo,
    },
    {
      'id': '6947a3a8d9ba1ed105c021c3',
      'name': 'Las Vegas',
      'fullName': 'Las Vegas Raiders',
      'logo': AppAssets.raidersLogo,
    },
    {
      'id': '6947a3a8d9ba1ed105c021c4',
      'name': 'Los Angeles',
      'fullName': 'Los Angeles Chargers',
      'logo': AppAssets.chargersLogo,
    },
  ];

  Future<void> _handleNext() async {
    if (_selectedTeam == null) {
      CustomSnackbar.show(
        context,
        'Please select a team',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call register API and get auth response with access token
      final authResponse = await _authRepository.register(
        RegisterRequest(
          name: widget.signupData.name,
          email: widget.signupData.email,
          phoneNumber: widget.signupData.phoneNumber,
          password: widget.signupData.password,
          selectedTeam: _selectedTeam!,
        ),
      );

      // Save access token and user data (including selectedTeam)
      await AuthStorageService.saveToken(authResponse.accessToken);

      // Save user data with selectedTeam
      final userData = authResponse.user ?? {};
      userData['selectedTeam'] = _selectedTeam;
      await AuthStorageService.saveUserData(userData);

      // Also save selected team separately for easy access
      await AuthStorageService.saveSelectedTeam(_selectedTeam!);

      if (mounted) {
        setState(() => _isLoading = false);

        // Navigate to OTP verification screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: widget.signupData.email,
              isFromSignup: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        // Get error message from exception
        String errorMessage = e.toString();
        String displayMessage = 'Registration failed. Please try again.';
        bool shouldRedirectToOtp = false;

        // Handle specific error cases more gracefully
        if (errorMessage.contains('No internet connection')) {
          displayMessage = 
              'Connection is slow or unstable. Please check your internet and try again.';
          _showRetryDialog(displayMessage);
          return;
        } else if (errorMessage.toLowerCase().contains('user already exists') ||
            errorMessage.toLowerCase().contains('already exists')) {
          // User might be in partial state - redirect to OTP verification
          displayMessage = 
              'Your account already exists but may need verification. Redirecting to verification...';
          shouldRedirectToOtp = true;
        } else if (errorMessage.toLowerCase().contains('not verified') ||
            errorMessage.toLowerCase().contains('unverified')) {
          // User exists but is not verified - redirect to OTP
          displayMessage = 
              'Your account needs verification. We\'ll send a new code to your email.';
          shouldRedirectToOtp = true;
        } else if (errorMessage.contains('timeout')) {
          displayMessage = 
              'Request timed out. The server is slow to respond. Please try again.';
          _showRetryDialog(displayMessage);
          return;
        } else {
          // Extract the actual error message if available
          if (errorMessage.contains(':')) {
            final parts = errorMessage.split(':');
            if (parts.length > 1) {
              displayMessage = parts.last.trim();
            }
          }
        }

        if (shouldRedirectToOtp) {
          // Show message and redirect to OTP screen
          CustomSnackbar.show(
            context,
            displayMessage,
            isError: false,
          );

          // Wait a moment for user to read the message
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // Redirect to OTP verification screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VerifyOtpScreen(
                  email: widget.signupData.email,
                  isFromSignup: true,
                ),
              ),
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            displayMessage,
            isError: true,
          );
        }
      }
    }
  }

  /// Show retry dialog for network errors
  void _showRetryDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Connection Issue'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // User can try again manually
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Retry the registration
                _handleNext();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        opacity: AppConstants.authBackgroundOpacity,
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding * 2,
                    vertical: AppConstants.defaultPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Icon
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups,
                            size: 50,
                            color: AppColors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Title
                      Text(
                        'Select Your Team',
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
                        'Choose a team to join',
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

                      // Team Selection Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          final team = _teams[index];
                          final isSelected = _selectedTeam == team['id'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTeam = team['id'];
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.3),
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Team Logo
                                      Container(
                                        width: 80,
                                        height: 80,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            team['logo'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // City Name
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          team['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // Selected Indicator
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
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

                      // Bottom padding to prevent overflow
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}