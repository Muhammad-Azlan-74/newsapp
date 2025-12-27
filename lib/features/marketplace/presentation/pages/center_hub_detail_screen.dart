import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/training_ground_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

/// Training Ground Detail Screen
///
/// Displays the training ground background image with three colored interactive overlays
class CenterHubDetailScreen extends StatefulWidget {
  const CenterHubDetailScreen({super.key});

  @override
  State<CenterHubDetailScreen> createState() => _CenterHubDetailScreenState();
}

class _CenterHubDetailScreenState extends State<CenterHubDetailScreen> {
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
            // Image with BoxFit.fit
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
    final overlays = TrainingGroundOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = TrainingGroundOverlays.isCircular(label);
      final color = TrainingGroundOverlays.getColor(label);
      final icon = TrainingGroundOverlays.getIcon(label);

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
            if (label == 'Area 1') {
              imagePath = 'assets/images/bench.png';
            } else if (label == 'Area 2') {
              imagePath = 'assets/images/settings_training.png';
            } else if (label == 'Area 3') {
              imagePath = 'assets/images/changes.png';
            } else {
              return;
            }

            _showImageDialog(context, imagePath);
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
                  'assets/images/training_ground.png',
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
            ],
          );
        },
      ),
    );
  }
}
