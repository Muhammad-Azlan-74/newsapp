import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/shared/widgets/glassy_button.dart';
import 'package:newsapp/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:newsapp/features/auth/data/repositories/auth_repository.dart';
import 'package:newsapp/features/auth/data/models/login_request.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/repositories/user_preferences_repository.dart';
import 'package:newsapp/core/services/team_image_cache_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

/// Login Screen
///
/// Allows users to login with email and password
/// Background image with 40% opacity
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _apiClient = ApiClient();
  late final _authRepository = AuthRepository(_apiClient);
  late final _preferencesRepository = UserPreferencesRepository(_apiClient);
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login action
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call login API
        final response = await _authRepository.login(
          LoginRequest(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );

        // Always save user data for the session
        // Save token only if remember me is checked
        final userData = response.user ?? {'email': _emailController.text};
        await AuthStorageService.saveUserData(userData);

        // If the API returns selectedTeam, save it separately
        if (userData['selectedTeam'] != null) {
          await AuthStorageService.saveSelectedTeam(userData['selectedTeam'] as String);
        }

        if (_rememberMe) {
          await AuthStorageService.saveToken(response.accessToken);
          await AuthStorageService.saveRememberMe(true);
        } else {
          // For current session only, save token temporarily
          await AuthStorageService.saveToken(response.accessToken);
        }

        // Fetch favorite teams and cache team images
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

          // Navigate to marketplace
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MarketplaceScreen(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          // Show error message
          CustomSnackbar.show(
            context,
            e.toString().replaceAll('ApiException: ', ''),
            isError: true,
          );
        }
      }
    }
  }

  /// Navigate to signup screen
  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        opacity: AppConstants.authBackgroundOpacity,
        child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Text
                    Text(
                      'Welcome Back!',
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

                    Text(
                      'Login to continue',
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

                    const SizedBox(height: 50),

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

                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: WidgetStateProperty.all(AppColors.primary),
                              checkColor: AppColors.white,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Text(
                                'Remember Me',
                                style: TextStyle(
                                  color: AppColors.black.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Forgot Password
                        GlassyTextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          text: 'Forgot Password?',
                          textColor: AppColors.black,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    GlassyButton(
                      onPressed: _handleLogin,
                      text: 'Login',
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.black.withOpacity(0.9),
                          ),
                        ),
                        GlassyTextButton(
                          onPressed: _navigateToSignup,
                          text: 'Sign Up',
                          textColor: AppColors.black,
                        ),
                      ],
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
