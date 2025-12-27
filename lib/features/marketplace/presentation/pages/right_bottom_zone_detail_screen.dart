import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/office_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';

/// Office Building Detail Screen
///
/// Displays the main office building image with interactive overlays
class RightBottomZoneDetailScreen extends StatelessWidget {
  const RightBottomZoneDetailScreen({super.key});

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = OfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = OfficeOverlays.isCircular(label);
      final color = OfficeOverlays.getColor(label);
      final icon = OfficeOverlays.getIcon(label);

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
        child: label == 'Office 8'
            ? GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              )
            : InteractiveOverlayArea(
                overlay: overlay,
                isCircular: isCircular,
                color: color,
                icon: icon,
                onTap: () {
                  // Other offices show a dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(label ?? 'Office Area'),
                      content: const Text('Overlay tapped!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                ),
                // Overlays positioned on the image
                ..._buildOverlays(context, screenWidth, screenWidth * 1.5), // Adjust ratio based on your image
              ],
            );
          },
        ),
      ),
    );
  }
}
