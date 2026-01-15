import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/man_cave_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

/// Man Cave Screen
///
/// Displays the man cave background image with interactive overlays
class ManCaveScreen extends StatefulWidget {
  const ManCaveScreen({super.key});

  @override
  State<ManCaveScreen> createState() => _ManCaveScreenState();
}

class _ManCaveScreenState extends State<ManCaveScreen> {
  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = ManCaveOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = ManCaveOverlays.isCircular(label);
      final color = ManCaveOverlays.getColor(label);
      final icon = ManCaveOverlays.getIcon(label);

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () {
            // Handle tap for each overlay - show snackbar for now
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label tapped!')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(isCircular ? 100 : 8),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: AppAssets.manCave,
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
        ],
      ),
    );
  }
}
