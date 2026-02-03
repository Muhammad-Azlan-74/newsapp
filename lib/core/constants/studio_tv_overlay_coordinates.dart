import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Studio TV overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the studio TV screen using normalized coordinates (0.0-1.0)
class StudioTvOverlays {
  StudioTvOverlays._(); // Private constructor to prevent instantiation

  /// Left Chair (Blue overlay) - plays studio1.mp4
  static BuildingOverlay get leftChair => const BuildingOverlay(
        left: 0.09,
        top: 0.38,
        width: 0.25,
        height: 0.1,
        label: 'Left Chair',
      );

  /// Right Chair (Purple overlay) - plays studio2.mp4
  static BuildingOverlay get rightChair => const BuildingOverlay(
    left: 0.45,
    top: 0.38,
    width: 0.25,
    height: 0.1,
        label: 'Right Chair',
      );

  /// Breaking News board overlay - shows TV Studio news
  static BuildingOverlay get breakingNews => const BuildingOverlay(
    left: 0.5,
    top: 0.24,
    width: 0.5,
    height: 0.14,
    label: 'Breaking News',
  );

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Left Chair': Colors.blue,
    'Right Chair': Colors.purple,
    'Breaking News': Colors.orange,
  };

  /// Map of overlay names to their video paths
  static const Map<String, String> videoMap = {
    'Left Chair': 'assets/videos/studio1.mp4',
    'Right Chair': 'assets/videos/studio2.mp4',
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        leftChair,
        rightChair,
        breakingNews,
      ];

  /// Get the color for an overlay
  static Color getColor(String? label) {
    if (label == null) return Colors.grey;
    return colorMap[label] ?? Colors.grey;
  }

  /// Get the video path for an overlay
  static String? getVideoPath(String? label) {
    if (label == null) return null;
    return videoMap[label];
  }
}
