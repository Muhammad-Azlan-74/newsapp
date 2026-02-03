import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/sportsbook_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Sportsbook Screen
///
/// Displays the sportsbook background image with interactive overlay
class SportsbookScreen extends StatefulWidget {
  const SportsbookScreen({super.key});

  @override
  State<SportsbookScreen> createState() => _SportsbookScreenState();
}

class _SportsbookScreenState extends State<SportsbookScreen> {
  bool _showHelpLabels = false;

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

  /// Build a help label widget (same design as mancave labels)
  Widget _buildHelpLabel(String text) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
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
                fontSize: 14,
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

  /// Show image dialog
  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Image with BoxFit.fill
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40,
                maxHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading image: $error'),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = SportsbookOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      // Convert normalized coordinates to actual pixel positions
      final left = overlay.left * imageWidth;
      final top = overlay.top * imageHeight;
      final width = overlay.width * imageWidth;
      final height = overlay.height * imageHeight;

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () {
            // Show dialog with image based on the area
            String imagePath;
            switch (label) {
              case 'Area 1':
                imagePath = 'assets/images/prediction1.png';
                break;
              case 'Area 2':
                imagePath = 'assets/images/prediction2.png';
                break;
              case 'Area 3':
                imagePath = 'assets/images/prediction3.png';
                break;
              case 'Area 4':
                imagePath = 'assets/images/prediction4.png';
                break;
              default:
                return;
            }
            _showImageDialog(context, imagePath);
          },
          child: Container(
            color: Colors.transparent, // Totally transparent
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate label positions based on updated overlay coordinates
    // Area 1: left: 0.01, top: 0.4
    // Area 2: left: 0.25, top: 0.4
    // Area 3: left: 0.46, top: 0.4
    // Area 4: left: 0.67, top: 0.38
    final area1Left = 0.01 * screenWidth + 5;
    final area1Top = 0.4 * screenHeight + 5;
    final area2Left = 0.25 * screenWidth + 5;
    final area2Top = 0.4 * screenHeight + 5;
    final area3Left = 0.46 * screenWidth + 5;
    final area3Top = 0.4 * screenHeight + 5;
    final area4Left = 0.67 * screenWidth + 5;
    final area4Top = 0.38 * screenHeight + 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background image with BoxFit.cover
              Positioned.fill(
                child: Image.asset(
                  AppAssets.sportsbook,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
                ),
              ),
              // Overlays positioned on the screen
              ..._buildOverlays(context, screenWidth, screenHeight),
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
              // Help label for Area 1 (Screen 1)
              if (_showHelpLabels)
                Positioned(
                  left: area1Left,
                  top: area1Top,
                  child: _buildHelpLabel('Screen 1'),
                ),
              // Help label for Area 2 (Screen 2)
              if (_showHelpLabels)
                Positioned(
                  left: area2Left,
                  top: area2Top,
                  child: _buildHelpLabel('Screen 2'),
                ),
              // Help label for Area 3 (Screen 3)
              if (_showHelpLabels)
                Positioned(
                  left: area3Left,
                  top: area3Top,
                  child: _buildHelpLabel('Screen 3'),
                ),
              // Help label for Area 4 (Screen 4)
              if (_showHelpLabels)
                Positioned(
                  left: area4Left,
                  top: area4Top,
                  child: _buildHelpLabel('Screen 4'),
                ),
            ],
          );
        },
      ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

