import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Sportsbook overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the sportsbook screen using normalized coordinates (0.0-1.0)
class SportsbookOverlays {
  SportsbookOverlays._(); // Private constructor to prevent instantiation

  /// Sportsbook Area 1 - Top Left
  static BuildingOverlay get area1 => const BuildingOverlay(
        left: 0.01,
        top: 0.4,
        width: 0.2,
        height: 0.07,
        label: 'Area 1',
      );

  /// Sportsbook Area 2 - Top Right
  static BuildingOverlay get area2 => const BuildingOverlay(
        left: 0.25,
    top: 0.4,
    width: 0.2,
    height: 0.07,
        label: 'Area 2',
      );

  /// Sportsbook Area 3 - Bottom Left
  static BuildingOverlay get area3 => const BuildingOverlay(
        left: 0.46,
    top: 0.4,
    width: 0.2,
    height: 0.07,
        label: 'Area 3',
      );

  /// Sportsbook Area 4 - Bottom Right
  static BuildingOverlay get area4 => const BuildingOverlay(
        left: 0.67,
    top: 0.38,
    width: 0.15,
    height: 0.06,
        label: 'Area 4',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Area 1': false, // Rectangular
    'Area 2': false, // Rectangular
    'Area 3': false, // Rectangular
    'Area 4': false, // Rectangular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Area 1': Colors.blue,
    'Area 2': Colors.green,
    'Area 3': Colors.orange,
    'Area 4': Colors.purple,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Area 1': Icons.sports_baseball,
    'Area 2': Icons.sports_football,
    'Area 3': Icons.sports_basketball,
    'Area 4': Icons.sports_soccer,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        area1,
        area2,
        area3,
        area4,
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
