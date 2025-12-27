import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/hof_overlay_coordinates.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

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
        customWidget: GestureDetector(
          onTap: () {
            // Handle tap for each overlay
            if (label == 'HOF Friends') {
              Navigator.pushNamed(context, AppRoutes.hofFriends);
            } else if (label == 'Personal HOF') {
              Navigator.pushNamed(context, AppRoutes.personalHof);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label tapped!')),
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
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: 'assets/images/hof_hallway.png',
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
