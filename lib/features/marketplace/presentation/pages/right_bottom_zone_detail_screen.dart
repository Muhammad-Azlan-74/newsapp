import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/office_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Office Building Detail Screen
///
/// Displays the main office building image with interactive overlays
class RightBottomZoneDetailScreen extends StatefulWidget {
  const RightBottomZoneDetailScreen({super.key});

  @override
  State<RightBottomZoneDetailScreen> createState() => _RightBottomZoneDetailScreenState();
}

class _RightBottomZoneDetailScreenState extends State<RightBottomZoneDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showShaddyAvatar = true;
  bool _showHelpLabels = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Show the avatar
    _animationController.forward();

    // Hide after 3-4 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showShaddyAvatar = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  /// Build a help label widget
  Widget _buildHelpLabel(String text) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
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
                fontSize: 16,
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
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = OfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      // Convert normalized coordinates to actual pixel positions
      final left = overlay.left * imageWidth;
      final top = overlay.top * imageHeight;
      final width = overlay.width * imageWidth;
      final height = overlay.height * imageHeight;

      // Determine the onTap action based on label
      VoidCallback onTapAction;
      switch (label) {
        case 'Office 1':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.conferenceRoom);
          break;
        case 'Office 3':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.manCave);
          break;
        case 'Office 4':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.personalOffice);
          break;
        case 'Office 5':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.doctorsOffice);
          break;
        case 'Office 6':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.janitorOffice);
          break;
        case 'Office 7':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.studioTv);
          break;
        case 'Office 8':
          onTapAction = () => Navigator.of(context).pop();
          break;
        case 'Office 9':
          onTapAction = () => Navigator.pushNamed(context, AppRoutes.hrOffice);
          break;
        default:
          onTapAction = () {};
      }

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTapAction,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Get screen width
            final screenWidth = MediaQuery.of(context).size.width;

            return Stack(
              children: [
                // Background image
                Image.asset(
                  AppAssets.mainOffice,
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error loading image: $error'),
                          ],
                        ),
                      ),
                    );
                  },
                  // Get image dimensions when loaded
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
                // Overlays positioned on the image
                ..._buildOverlays(context, screenWidth, screenWidth * 1.5), // Adjust ratio based on your image
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: const GlassyBackButton(),
                ),
                // Help button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 10,
                  child: GlassyHelpButton(onPressed: _toggleHelpLabels),
                ),
                // Help labels for each office
                // Conference Room (Office 1) - top: 0.17
                if (_showHelpLabels)
                  Positioned(
                    left: 0.01 * screenWidth + 10,
                    top: 0.17 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Conference Room'),
                  ),
                // Man Cave (Office 3) - left: 0.60, top: 0.87
                if (_showHelpLabels)
                  Positioned(
                    left: 0.60 * screenWidth + 10,
                    top: 0.87 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Man Cave'),
                  ),
                // Personal Office (Office 4) - left: 0.001, top: 0.43
                if (_showHelpLabels)
                  Positioned(
                    left: 0.001 * screenWidth + 10,
                    top: 0.43 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Personal Office'),
                  ),
                // Doctor's Office (Office 5) - left: 0.001, top: 0.87
                if (_showHelpLabels)
                  Positioned(
                    left: 0.001 * screenWidth + 10,
                    top: 0.87 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel("Doctor's Office"),
                  ),
                // Janitor (Office 6) - left: 0.60, top: 0.43
                if (_showHelpLabels)
                  Positioned(
                    left: 0.60 * screenWidth + 10,
                    top: 0.43 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Janitor'),
                  ),
                // Studio TV (Office 7) - left: 0.001, top: 0.65
                if (_showHelpLabels)
                  Positioned(
                    left: 0.001 * screenWidth + 10,
                    top: 0.65 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Studio TV'),
                  ),
                // Exit (Office 8) - left: 0.6, top: 1.09
                if (_showHelpLabels)
                  Positioned(
                    left: 0.6 * screenWidth + 10,
                    top: 1.09 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('Exit'),
                  ),
                // HR Office (Office 9) - left: 0.60, top: 0.65
                if (_showHelpLabels)
                  Positioned(
                    left: 0.60 * screenWidth + 10,
                    top: 0.65 * (screenWidth * 1.5) + 10,
                    child: _buildHelpLabel('HR Office'),
                  ),
                // Shaddy avatar with chat bubble
                if (_showShaddyAvatar)
                  Positioned(
                    left: 20,
                    bottom: 40,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.rumourGarage);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fancy Chat bubble with glassmorphism
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Glassmorphism bubble
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Wanna know something shaddy',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Bubble tail pointing down
                                Positioned(
                                  bottom: -8,
                                  left: 20,
                                  child: CustomPaint(
                                    size: const Size(20, 10),
                                    painter: _BubbleTailPainter(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Small shaddy avatar
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  AppAssets.shaddy,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 75,
                                      height: 75,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white70,
                                        size: 45,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

/// Custom painter for the chat bubble tail with glassmorphism
class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Draw border for the tail
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
