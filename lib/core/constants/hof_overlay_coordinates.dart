import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Hall of Fame overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the Hall of Fame screen using normalized coordinates (0.0-1.0)
class HallOfFameOverlays {
  HallOfFameOverlays._(); // Private constructor to prevent instantiation

  /// HOF Friends
  static BuildingOverlay get leftMiddle => const BuildingOverlay(
        left: 0.14,
        top: 0.2,
        width: 0.1,
        height: 0.23,
        label: 'HOF Friends',
      );

  /// Personal HOF
  static BuildingOverlay get center => const BuildingOverlay(
        left: 0.38,
        top: 0.3,
        width: 0.23,
        height: 0.23,
        label: 'Personal HOF',
      );

  /// Personal Profile
  static BuildingOverlay get rightMiddle => const BuildingOverlay(
        left: 0.76,
        top: 0.22,
        width: 0.1,
        height: 0.22,
        label: 'Personal Profile',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'HOF Friends': false, // Rectangular - change to true for circular
    'Personal HOF': false, // Rectangular - change to true for circular
    'Personal Profile': false, // Rectangular - change to true for circular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'HOF Friends': Colors.purple,
    'Personal HOF': Colors.amber,
    'Personal Profile': Colors.cyan,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'HOF Friends': Icons.people,
    'Personal HOF': Icons.emoji_events,
    'Personal Profile': Icons.person,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        leftMiddle,
        center,
        // rightMiddle removed - Personal Profile overlay removed
      ];

  /// Check if an overlay should be circular
  static bool isCircular(String? label) {
    if (label == null) return false;
    return shapeMap[label] ?? false;
  }

  /// Get the color for an overlay
  static Color getColor(String? label) {
    if (label == null) return Colors.grey;
    return colorMap[label] ?? Colors.grey;
  }

  /// Get the icon for an overlay
  static IconData getIcon(String? label) {
    if (label == null) return Icons.help_outline;
    return iconMap[label] ?? Icons.help_outline;
  }
}
