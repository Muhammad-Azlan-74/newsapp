import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';

/// Reusable Background Widget
///
/// Displays a background image with customizable opacity
/// Used across splash, login, signup, and marketplace screens
class BackgroundWidget extends StatelessWidget {
  /// The opacity of the background image (0.0 to 1.0)
  final double opacity;

  /// The child widget to display on top of the background
  final Widget child;

  const BackgroundWidget({
    super.key,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              AppAssets.backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image not found
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade800,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Content
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}
