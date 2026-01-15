import 'package:flutter/material.dart';

/// Navigation Helper
///
/// Provides methods to navigate with image preloading to prevent black screen flash
class NavigationHelper {
  /// Navigate to a route after preloading the background image
  static Future<void> navigateTo(
    BuildContext context, {
    required String route,
    String? imagePath,
    Object? arguments,
  }) async {
    // Preload the image if provided
    if (imagePath != null) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        // Continue navigation even if precaching fails
      }
    }

    // Small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 100));

    // Navigate to the route
    if (context.mounted) {
      Navigator.pushNamed(context, route, arguments: arguments);
    }
  }

  /// Replace current route after preloading the background image
  static Future<void> navigateReplacementTo(
    BuildContext context, {
    required String route,
    String? imagePath,
    Object? arguments,
  }) async {
    // Preload the image if provided
    if (imagePath != null) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        // Continue navigation even if precaching fails
      }
    }

    // Small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 100));

    // Navigate to the route
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, route, arguments: arguments);
    }
  }

  /// Pop and navigate to a route after preloading
  static Future<void> popAndNavigateTo(
    BuildContext context, {
    required String route,
    String? imagePath,
    Object? arguments,
  }) async {
    // Preload the image if provided
    if (imagePath != null) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        // Continue navigation even if precaching fails
      }
    }

    // Small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 100));

    // Navigate to the route
    if (context.mounted) {
      Navigator.popAndPushNamed(context, route, arguments: arguments);
    }
  }
}
