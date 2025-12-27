import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/office_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

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

  /// Get room name for display on door plates
  String _getRoomName(String? label) {
    switch (label) {
      case 'Office 1':
        return 'Conference Room';
      case 'Office 3':
        return 'Man Cave';
      case 'Office 4':
        return 'Personal Office';
      case 'Office 5':
        return 'Doctor\'s Office';
      case 'Office 6':
        return 'Janitor';
      case 'Office 7':
        return 'Studio TV';
      case 'Office 8':
        return 'Exit';
      case 'Office 9':
        return 'HR Office';
      default:
        return 'Office';
    }
  }

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = OfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final roomName = _getRoomName(label);

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
          child: Stack(
            children: [
              // Transparent clickable area
              Container(
                color: Colors.transparent,
              ),
              // Small elegant door plate at the top with transparency
              Positioned(
                top: 5,
                left: width * 0.15,
                right: width * 0.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        roomName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SingleChildScrollView(
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
                                          Icon(
                                            Icons.question_mark_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Wanna know something shaddy',
                                            style: TextStyle(
                                              color: Colors.white,
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
                              width: 50,
                              height: 50,
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
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white70,
                                        size: 30,
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
