import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/socialbar_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/shared/widgets/webview_dialog.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Social Bar Detail Screen
///
/// Screen for social bar with background image and interactive overlays
class LeftZoneDetailScreen extends StatefulWidget {
  const LeftZoneDetailScreen({super.key});

  @override
  State<LeftZoneDetailScreen> createState() => _LeftZoneDetailScreenState();
}

class _LeftZoneDetailScreenState extends State<LeftZoneDetailScreen> {
  bool _showHelpLabels = false;

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return; // Already showing

    setState(() {
      _showHelpLabels = true;
    });

    // Hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget (same design as mancave labels)
  Widget _buildHelpLabel(String text, {VoidCallback? onTap}) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: _showHelpLabels ? onTap : null,
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
                  fontSize: 14,
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
      ),
    );
  }

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
                // Show Twitter in dialog
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://twitter.com',
                    title: 'Twitter',
                  ),
                );
                break;
              case 'Window':
                // Show The New Heights podcast in dialog
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://www.youtube.com/@newheightshow',
                    title: 'The New Heights',
                  ),
                );
                break;
              case 'Board':
                // Show NFL Memes Instagram profile in dialog
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://www.instagram.com/nflmemes_ig/',
                    title: 'NFL Memes',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate label positions based on overlay coordinates (positioned at top of overlay)
    // TV (Twitter): left: 0.11, top: 0.23
    // Window (YouTube): left: 0.6, top: 0.27
    // Board (Instagram): left: 0.4, top: 0.55
    final tvLeft = 0.11 * screenWidth + 5;
    final tvTop = 0.23 * screenHeight + 5;
    final windowLeft = 0.6 * screenWidth + 5;
    final windowTop = 0.27 * screenHeight + 5;
    final boardLeft = 0.4 * screenWidth + 5;
    final boardTop = 0.55 * screenHeight + 5;

    return Scaffold(
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: 'assets/images/social_bar.png',
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
          // Help label for TV (Twitter)
          if (_showHelpLabels)
            Positioned(
              left: tvLeft,
              top: tvTop,
              child: _buildHelpLabel('Twitter', onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://twitter.com',
                    title: 'Twitter',
                  ),
                );
              }),
            ),
          // Help label for Window (YouTube)
          if (_showHelpLabels)
            Positioned(
              left: windowLeft,
              top: windowTop,
              child: _buildHelpLabel('YouTube', onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://www.youtube.com/@newheightshow',
                    title: 'The New Heights',
                  ),
                );
              }),
            ),
          // Help label for Board (Instagram)
          if (_showHelpLabels)
            Positioned(
              left: boardLeft,
              top: boardTop,
              child: _buildHelpLabel('Instagram', onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const WebViewDialog(
                    url: 'https://www.instagram.com/nflmemes_ig/',
                    title: 'NFL Memes',
                  ),
                );
              }),
            ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

