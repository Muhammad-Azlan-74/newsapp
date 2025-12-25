import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/hof_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';

/// Hall of Fame Detail Screen
///
/// Screen for hall of fame with background image and interactive overlays
class RightTopZoneDetailScreen extends StatefulWidget {
  const RightTopZoneDetailScreen({super.key});

  @override
  State<RightTopZoneDetailScreen> createState() => _RightTopZoneDetailScreenState();
}

class _RightTopZoneDetailScreenState extends State<RightTopZoneDetailScreen> {
  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = HallOfFameOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = HallOfFameOverlays.isCircular(label);
      final color = HallOfFameOverlays.getColor(label);
      final icon = HallOfFameOverlays.getIcon(label);

      return overlay.copyWith(
        customWidget: InteractiveOverlayArea(
          overlay: overlay,
          isCircular: isCircular,
          color: color,
          icon: icon,
          onTap: () {
            // Handle tap for each overlay
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label tapped!')),
            );
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageRelativeBackground(
        imagePath: 'assets/images/hof_hallway.png',
        opacity: AppConstants.dashboardBackgroundOpacity,
        overlays: _buildOverlays(),
        child: Container(),
      ),
    );
  }
}
