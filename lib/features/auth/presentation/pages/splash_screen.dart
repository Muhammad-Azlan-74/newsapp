import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/services/permission_service.dart';
import 'package:newsapp/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'login_screen.dart';

/// Splash Screen
///
/// Initial screen shown when app launches
/// Automatically navigates to login screen after a delay
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Check for saved token and navigate accordingly
    _checkAuthAndNavigate();
  }

  /// Check for saved authentication and navigate to appropriate screen
  Future<void> _checkAuthAndNavigate() async {
    // Request all necessary permissions
    await PermissionService().requestAllPermissions();

    // Wait for splash duration
    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));

    if (!mounted) return;

    // Debug: Check token status
    final token = await AuthStorageService.getToken();
    debugPrint('Splash screen - Token check: ${token != null && token.isNotEmpty ? "Token found (${token.length} chars)" : "NO TOKEN FOUND"}');

    // Check if user is logged in
    final isLoggedIn = await AuthStorageService.isLoggedIn();
    debugPrint('Splash screen - isLoggedIn: $isLoggedIn');

    if (isLoggedIn) {
      // Navigate to marketplace if token exists
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
      );
    } else {
      // Navigate to login screen if no token
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        opacity: AppConstants.authBackgroundOpacity,
        child: SizedBox.expand(
          child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      AppAssets.appLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon if logo not found
                        return const Icon(
                          Icons.newspaper,
                          size: 80,
                          color: Colors.blue,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // App Name
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  'Your Daily News Companion',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 50),

                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
