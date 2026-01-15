import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/personal_office_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/shared/widgets/settings_tv_dialog.dart';
import 'package:newsapp/shared/widgets/personalization_dialog.dart';
import 'package:newsapp/shared/widgets/support_dialog.dart';
import 'package:newsapp/shared/widgets/customization_dialog.dart';
import 'package:newsapp/shared/widgets/status_dialog.dart';
import 'package:newsapp/shared/widgets/fantasy_dialog.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

/// Personal Office Screen
///
/// Displays the personal office background image with interactive overlays
class PersonalOfficeScreen extends StatefulWidget {
  const PersonalOfficeScreen({super.key});

  @override
  State<PersonalOfficeScreen> createState() => _PersonalOfficeScreenState();
}

class _PersonalOfficeScreenState extends State<PersonalOfficeScreen> {
  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = PersonalOfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = PersonalOfficeOverlays.isCircular(label);
      final color = PersonalOfficeOverlays.getColor(label);
      final icon = PersonalOfficeOverlays.getIcon(label);

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
            // Show SettingsTvDialog for Area 1
            if (label == 'Area 1') {
              showDialog(
                context: context,
                builder: (context) => const SettingsTvDialog(),
              );
            } else if (label == 'Area 2') {
              // Show FantasyDialog for Area 2
              showDialog(
                context: context,
                builder: (context) => const FantasyDialog(),
              );
            } else if (label == 'Area 3') {
              // Show StatusDialog for Area 3
              showDialog(
                context: context,
                builder: (context) => const StatusDialog(),
              );
            } else if (label == 'Area 5') {
              // Show PersonalizationDialog for Area 5
              showDialog(
                context: context,
                builder: (context) => const PersonalizationDialog(),
              );
            } else if (label == 'Area 4') {
              // Show SupportDialog for Area 4
              showDialog(
                context: context,
                builder: (context) => const SupportDialog(),
              );
            } else if (label == 'Area 6') {
              // Show CustomizationDialog for Area 6
              showDialog(
                context: context,
                builder: (context) => const CustomizationDialog(),
              );
            } else {
              // Default dialog for other areas
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(label ?? 'Personal Office Area'),
                  content: const Text('Overlay tapped!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
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
      backgroundColor: Colors.white, // White background
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
                  AppAssets.personalOffice,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
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
              const Positioned(
                top: 40,
                left: 16,
                child: GlassyBackButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}
