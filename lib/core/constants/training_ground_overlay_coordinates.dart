import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Training Ground overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the training ground screen using normalized coordinates (0.0-1.0)
class TrainingGroundOverlays {
  TrainingGroundOverlays._(); // Private constructor to prevent instantiation

  /// Training Ground Area 1 - Left area
  static BuildingOverlay get area1 => const BuildingOverlay(
        left: 0.001,
        top: 0.3,
        width: 0.28,
        height: 0.15,
        label: 'Area 1',
      );

  /// Training Ground Area 2 - Center area
  static BuildingOverlay get area2 => const BuildingOverlay(
        left: 0.65,
        top: 0.38,
        width: 0.4,
        height: 0.1,
        label: 'Area 2',
      );

  /// Training Ground Area 3 - Right area
  static BuildingOverlay get area3 => const BuildingOverlay(
        left: 0.55,
        top: 0.6,
        width: 0.45,
        height: 0.2,
        label: 'Area 3',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Area 1': false, // Rectangular
    'Area 2': false, // Rectangular
    'Area 3': false, // Rectangular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Area 1': Colors.transparent, // Completely transparent
    'Area 2': Colors.transparent, // Completely transparent
    'Area 3': Colors.transparent, // Completely transparent
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Area 1': Icons.fitness_center,
    'Area 2': Icons.sports_soccer,
    'Area 3': Icons.sports_basketball,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        area1,
        area2,
        area3,
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
