import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Man Cave overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the man cave screen using normalized coordinates (0.0-1.0)
class ManCaveOverlays {
  ManCaveOverlays._(); // Private constructor to prevent instantiation

  /// Overlay 1 - Placeholder coordinates (edit these yourself)
  static BuildingOverlay get overlay1 => const BuildingOverlay(
        left: 0.15,
        top: 0.3,
        width: 0.3,
        height: 0.2,
        label: 'Overlay 1',
      );

  /// Overlay 2 - Placeholder coordinates (edit these yourself)
  static BuildingOverlay get overlay2 => const BuildingOverlay(
        left: 0.55,
        top: 0.4,
        width: 0.3,
        height: 0.2,
        label: 'Overlay 2',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Overlay 1': false, // Rectangular - change to true for circular
    'Overlay 2': false, // Rectangular - change to true for circular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Overlay 1': Colors.green,
    'Overlay 2': Colors.green,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Overlay 1': Icons.location_on,
    'Overlay 2': Icons.location_on,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        overlay1,
        overlay2,
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
