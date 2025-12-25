import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Social Bar overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the social bar screen using normalized coordinates (0.0-1.0)
class SocialBarOverlays {
  SocialBarOverlays._(); // Private constructor to prevent instantiation

  /// TV - Placeholder coordinates (edit these yourself)
  static BuildingOverlay get tv => const BuildingOverlay(
        left: 0.11,
        top: 0.23,
        width: 0.4,
        height: 0.07,
        label: 'TV',
      );

  /// Window - Placeholder coordinates (edit these yourself)
  static BuildingOverlay get window => const BuildingOverlay(
        left: 0.6,
        top: 0.27,
        width: 0.25,
        height: 0.18,
        label: 'Window',
      );

  /// Board - Placeholder coordinates (edit these yourself)
  static BuildingOverlay get board => const BuildingOverlay(
        left: 0.4,
        top: 0.55,
        width: 0.47,
        height: 0.2,
        label: 'Board',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'TV': false, // Rectangular - change to true for circular
    'Window': false, // Rectangular - change to true for circular
    'Board': false, // Rectangular - change to true for circular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'TV': Colors.blue,
    'Window': Colors.green,
    'Board': Colors.orange,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'TV': Icons.tv,
    'Window': Icons.window,
    'Board': Icons.dashboard,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        tv,
        window,
        board,
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
