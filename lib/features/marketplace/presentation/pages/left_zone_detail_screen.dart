import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/socialbar_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/shared/widgets/webview_screen.dart';

/// Social Bar Detail Screen
///
/// Screen for social bar with background image and interactive overlays
class LeftZoneDetailScreen extends StatefulWidget {
  const LeftZoneDetailScreen({super.key});

  @override
  State<LeftZoneDetailScreen> createState() => _LeftZoneDetailScreenState();
}

class _LeftZoneDetailScreenState extends State<LeftZoneDetailScreen> {
  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = SocialBarOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = SocialBarOverlays.isCircular(label);
      final color = SocialBarOverlays.getColor(label);
      final icon = SocialBarOverlays.getIcon(label);

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () {
            // Handle tap for each overlay
            switch (label) {
              case 'TV':
                // Navigate to Twitter in webview
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://twitter.com',
                      title: 'Twitter',
                    ),
                  ),
                );
                break;
              case 'Window':
                // Navigate to The New Heights podcast
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://www.youtube.com/@newheightshow',
                      title: 'The New Heights',
                    ),
                  ),
                );
                break;
              case 'Board':
                // Navigate to NFL Memes Instagram profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://www.instagram.com/nflmemes_ig/',
                      title: 'NFL Memes',
                    ),
                  ),
                );
                break;
              default:
                // Show snackbar for any other overlays
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
      body: ImageRelativeBackground(
        imagePath: 'assets/images/social_bar.png',
        opacity: AppConstants.dashboardBackgroundOpacity,
        overlays: _buildOverlays(),
        child: Container(),
      ),
    );
  }
}
