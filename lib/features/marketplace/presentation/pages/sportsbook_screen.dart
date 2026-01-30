import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/sportsbook_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Sportsbook Screen
///
/// Displays the sportsbook background image with interactive overlay
class SportsbookScreen extends StatefulWidget {
  const SportsbookScreen({super.key});

  @override
  State<SportsbookScreen> createState() => _SportsbookScreenState();
}

class _SportsbookScreenState extends State<SportsbookScreen> {
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
            // Show dialog with image
            if (label == 'Area 1') {
              _showImageDialog(context, 'assets/images/sportsbook_settings.png');
            }
          },
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get screen dimensions
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

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
                child: const GlassyHelpButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}
