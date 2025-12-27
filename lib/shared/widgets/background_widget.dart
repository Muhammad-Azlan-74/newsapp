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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundImage),
          fit: BoxFit.cover,
          opacity: opacity,
          onError: (exception, stackTrace) {
            // Silently fail - white background will show
          },
        ),
      ),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
