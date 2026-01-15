import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Doctor's Office overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the doctor's office screen using normalized coordinates (0.0-1.0)
class DoctorsOfficeOverlays {
  DoctorsOfficeOverlays._(); // Private constructor to prevent instantiation

  /// Doctor's Office Area 1
  static BuildingOverlay get area1 => const BuildingOverlay(
        left: 0.001,
        top: 0.27,
        width: 0.55,
        height: 0.32,
        label: 'Area 1',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Area 1': false, // Rectangular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Area 1': Colors.transparent,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Area 1': Icons.medical_services,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        area1,
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
