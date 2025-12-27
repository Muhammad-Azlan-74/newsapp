import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
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
    {'name': 'Kansas City', 'color': Colors.red, 'icon': Icons.group},
    {'name': 'Denver', 'color': Colors.blue, 'icon': Icons.group},
    {'name': 'Las Vegas', 'color': Colors.green, 'icon': Icons.group},
    {'name': 'Los Angeles', 'color': Colors.orange, 'icon': Icons.group},
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

      // Save access token
      await AuthStorageService.saveToken(authResponse.accessToken);

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

        CustomSnackbar.show(
          context,
          'Registration failed: ${e.toString()}',
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
                          Icons.groups,
                          size: 50,
                          color: AppColors.black,
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
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          final team = _teams[index];
                          final isSelected = _selectedTeam == team['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTeam = team['name'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? team['color']
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Team Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: team['color'].withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      team['icon'],
                                      size: 32,
                                      color: team['color'],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Team Name
                                  Text(
                                    team['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? team['color']
                                          : AppColors.textPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Selected Indicator
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: team['color'],
                                      size: 20,
                                    ),
                                ],
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
