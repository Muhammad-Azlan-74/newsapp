import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/building_coordinates.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';

/// Demo screen showing building overlays on the marketplace background
///
/// This demonstrates how to use image-relative positioning to place
/// white containers that stay locked to buildings in the background image,
/// regardless of screen size or aspect ratio changes.
class BuildingOverlayDemoScreen extends StatelessWidget {
  const BuildingOverlayDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Overlay Demo'),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: ImageRelativeBackground(
        imagePath: AppAssets.backgroundImage,
        opacity: 1.0,
        debugMode: false, // Set to true to see red debug borders
        // Use predefined building coordinates with styling
        overlays: BuildingCoordinates.getAllWithStyling(
          opacity: 0.75,
          showBorders: true,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions card
                Card(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Image-Relative Positioning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The white containers are positioned using normalized coordinates (0.0 to 1.0) relative to the background image.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Rotate your device or resize the window\n'
                          '• Containers stay locked to the same image positions\n'
                          '• They scale and move with the background\n'
                          '• No drift or misalignment',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
