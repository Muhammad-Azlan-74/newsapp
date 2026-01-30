import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/hof_overlay_coordinates.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Hall of Fame Detail Screen
///
/// Screen for hall of fame with background image and interactive overlays
class RightTopZoneDetailScreen extends StatefulWidget {
  const RightTopZoneDetailScreen({super.key});

  @override
  State<RightTopZoneDetailScreen> createState() => _RightTopZoneDetailScreenState();
}

class _RightTopZoneDetailScreenState extends State<RightTopZoneDetailScreen> {
  bool _showHelpLabels = false;

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return;

    setState(() {
      _showHelpLabels = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget
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
                fontSize: 10,
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

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = HallOfFameOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          // Help button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(onPressed: _toggleHelpLabels),
          ),
          // Help label for HOF Friends - left: 0.14, top: 0.2
          if (_showHelpLabels)
            Positioned(
              left: 0.14 * screenWidth + 5,
              top: 0.2 * screenHeight + 5,
              child: _buildHelpLabel('HOF Friends'),
            ),
          // Help label for Personal HOF - left: 0.38, top: 0.3
          if (_showHelpLabels)
            Positioned(
              left: 0.38 * screenWidth + 5,
              top: 0.3 * screenHeight + 5,
              child: _buildHelpLabel('Personal HOF'),
            ),
        ],
      ),
    );
  }
}
