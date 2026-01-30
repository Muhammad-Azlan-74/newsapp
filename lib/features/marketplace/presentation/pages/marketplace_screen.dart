import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/core/constants/marketplace_overlay_coordinates.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/welcome_chat_bubble.dart';
import 'package:newsapp/shared/widgets/team_avatar_widget.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Marketplace/Dashboard Screen
///
/// Main screen after login showing only background image
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _showWelcomeBubble = false;
  bool _isFirstTime = false;
  bool _showHelpBubble = false;
  bool _showHelpLabels = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowWelcome();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return; // Already showing

    setState(() {
      _showHelpLabels = true;
    });

    // Hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget (same design as before but with animation)
  Widget _buildHelpLabel(String text, {double? width}) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }


  /// Check if user has logged in before and show welcome message
  Future<void> _checkAndShowWelcome() async {
    final hasLoggedIn = await AuthStorageService.hasLoggedInBefore();

    setState(() {
      _isFirstTime = !hasLoggedIn;
      _showWelcomeBubble = true;
    });

    // Mark that user has logged in after showing the welcome message
    // This ensures first-time users see "Welcome to the newsapp"
    if (!hasLoggedIn) {
      // Wait for the welcome bubble to appear, then mark as logged in
      Future.delayed(const Duration(milliseconds: 500), () async {
        await AuthStorageService.markLoggedIn();
      });
    }
  }

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = MarketplaceOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      // Determine the route based on the label
      String route;
      switch (label) {
        case 'Social Bar':
          route = AppRoutes.leftZoneDetail;
          break;
        case 'Training Ground':
          route = AppRoutes.centerHubDetail;
          break;
        case 'Hall of Fame':
          route = AppRoutes.rightTopZoneDetail;
          break;
        case 'Office Building':
          route = AppRoutes.rightBottomZoneDetail;
          break;
        case 'Office Building 2':
          route = AppRoutes.rightBottomZoneDetail;
          break;
        case 'office':
          route = AppRoutes.rightBottomZoneDetail;
          break;
        case 'News Stall':
          route = AppRoutes.newsStand;
          break;
        case 'Screenbook':
          route = AppRoutes.sportsbook;
          break;
        default:
          route = AppRoutes.marketplace;
      }

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () => Navigator.pushNamed(context, route),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  /// Handle sign out
  Future<void> _handleSignOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(AppAssets.backgroundImage),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  const Text(
                    'Are you sure you want to sign out?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sign out button
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

    if (shouldSignOut == true && mounted) {
      // Clear authentication data
      await AuthStorageService.clearAuth();

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
            'Signed out successfully',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Main background with overlays
          ImageRelativeBackground(
            imagePath: AppAssets.backgroundImage,
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // Team avatar (always visible)
          TeamAvatarWidget(
            onTap: () {
              setState(() {
                _showWelcomeBubble = false;
                _showHelpBubble = true;
              });
            },
          ),
          // Welcome chat bubble (appears above avatar)
          if (_showWelcomeBubble)
            WelcomeChatBubble(
              isFirstTime: _isFirstTime,
              onDismissed: () {
                setState(() {
                  _showWelcomeBubble = false;
                });
              },
            ),
          // Help chat bubble (appears when avatar is tapped)
          if (_showHelpBubble)
            WelcomeChatBubble(
              isFirstTime: false,
              customMessage: 'Hi! How can I help you?',
              onDismissed: () {
                setState(() {
                  _showHelpBubble = false;
                });
              },
            ),
          // Help button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(onPressed: _toggleHelpLabels),
          ),
          // Help labels (only shown when help button is tapped)
          // Social Bar - left: 0.07, top: 0.25
          if (_showHelpLabels)
            Positioned(
              left: 0.07 * screenWidth + 5,
              top: 0.25 * screenHeight + 5,
              child: _buildHelpLabel('Social Bar', width: 45),
            ),
          // Training Ground - left: 0.33, top: 0.15
          if (_showHelpLabels)
            Positioned(
              left: 0.33 * screenWidth + 5,
              top: 0.15 * screenHeight + 5,
              child: _buildHelpLabel('Training Ground'),
            ),
          // Hall of Fame - left: 0.79, top: 0.2
          if (_showHelpLabels)
            Positioned(
              left: 0.79 * screenWidth + 5,
              top: 0.2 * screenHeight + 5,
              child: _buildHelpLabel('HOF'),
            ),
          // Office Building - left: 0.2, top: 0.03
          if (_showHelpLabels)
            Positioned(
              left: 0.2 * screenWidth + 5,
              top: 0.03 * screenHeight + 12,
              child: _buildHelpLabel('Office'),
            ),
          // News Stall - left: 0.61, top: 0.62
          if (_showHelpLabels)
            Positioned(
              left: 0.61 * screenWidth + 5,
              top: 0.62 * screenHeight + 5,
              child: _buildHelpLabel('News Stand'),
            ),
          // Screenbook (Sports Book) - left: 0.64, top: 0.32
          if (_showHelpLabels)
            Positioned(
              left: 0.64 * screenWidth + 5,
              top: 0.32 * screenHeight + 5,
              child: _buildHelpLabel('Sports Book', width: 45),
            ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSignOut,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}