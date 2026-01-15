import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Personal Office overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the personal office screen using normalized coordinates (0.0-1.0)
class PersonalOfficeOverlays {
  PersonalOfficeOverlays._(); // Private constructor to prevent instantiation

  /// Personal Office Area 1
  static BuildingOverlay get area1 => const BuildingOverlay(
        left: 0.02,
        top: 0.33,
        width: 0.35,
        height: 0.10,
        label: 'Area 1',
      );

  /// Personal Office Area 2
  static BuildingOverlay get area2 => const BuildingOverlay(
        left: 0.5,
        top: 0.28,
        width: 0.49,
        height: 0.24,
        label: 'Area 2',
      );

  /// Personal Office Area 3
  static BuildingOverlay get area3 => const BuildingOverlay(
        left: 0.03,
        top: 0.46,
        width: 0.22,
        height: 0.12,
        label: 'Area 3',
      );

  /// Personal Office Area 4
  static BuildingOverlay get area4 => const BuildingOverlay(
        left: 0.65,
        top: 0.68,
        width: 0.18,
        height: 0.1,
        label: 'Area 4',
      );

  /// Personal Office Area 5
  static BuildingOverlay get area5 => const BuildingOverlay(
        left: 0.26,
        top: 0.49,
        width: 0.2,
        height: 0.12,
        label: 'Area 5',
      );

  /// Personal Office Area 6
  static BuildingOverlay get area6 => const BuildingOverlay(
        left: 0.37,
        top: 0.63,
        width: 0.23,
        height: 0.09,
        label: 'Area 6',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Area 1': false, // Rectangular
    'Area 2': false, // Rectangular
    'Area 3': false, // Rectangular
    'Area 4': false, // Rectangular
    'Area 5': false, // Rectangular
    'Area 6': false, // Rectangular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Area 1': Colors.blue,
    'Area 2': Colors.green,
    'Area 3': Colors.orange,
    'Area 4': Colors.purple,
    'Area 5': Colors.red,
    'Area 6': Colors.teal,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Area 1': Icons.business,
    'Area 2': Icons.settings,
    'Area 3': Icons.analytics,
    'Area 4': Icons.dashboard,
    'Area 5': Icons.description,
    'Area 6': Icons.inbox,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        area1,
        area2,
        area3,
        area4,
        area5,
        area6,
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
