import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Conference Room overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the conference room screen using normalized coordinates (0.0-1.0)
class ConferenceRoomOverlays {
  ConferenceRoomOverlays._(); // Private constructor to prevent instantiation

  /// Overlay 4 - Attack History (invisible)
  static BuildingOverlay get overlay4 => const BuildingOverlay(
    left: 0.12,
    top: 0.15,
    width: 0.13,
    height: 0.33,
    label: 'Overlay 4',
  );

  /// Overlay 5 - Defense History (invisible)
  static BuildingOverlay get overlay5 => const BuildingOverlay(
    left: 0.75,
    top: 0.15,
    width: 0.13,
    height: 0.33,
    label: 'Overlay 5',
  );

  /// Overlay 6 - Attack Lineup (left side of table, invisible)
  /// EDIT THESE VALUES to position the overlay:
  /// - left: 0.0 = left edge, 1.0 = right edge
  /// - top: 0.0 = top edge, 1.0 = bottom edge
  /// - width/height: size as fraction of screen
  static BuildingOverlay get overlay6 => const BuildingOverlay(
    left: 0.05,    // <<< EDIT: X position (0.0-1.0)
    top: 0.48,     // <<< EDIT: Y position (0.0-1.0)
    width: 0.45,   // <<< EDIT: Width (0.0-1.0)
    height: 0.5,   // <<< EDIT: Height (0.0-1.0)
    label: 'Overlay 6',
  );

  /// Overlay 7 - Defense Lineup (right side of table, invisible)
  /// EDIT THESE VALUES to position the overlay
  static BuildingOverlay get overlay7 => const BuildingOverlay(
    left: 0.5,     // <<< EDIT: X position (0.0-1.0)
    top: 0.48,     // <<< EDIT: Y position (0.0-1.0)
    width: 0.45,   // <<< EDIT: Width (0.0-1.0)
    height: 0.5,   // <<< EDIT: Height (0.0-1.0)
    label: 'Overlay 7',
  );

  /// Overlay 8 - Match History (visible, semi-transparent)
  /// EDIT THESE VALUES to position the overlay
  static BuildingOverlay get overlay8 => const BuildingOverlay(
    left: 0.25,    // <<< EDIT: X position (0.0-1.0)
    top: 0.11,     // <<< EDIT: Y position (0.0-1.0)
    width: 0.47,   // <<< EDIT: Width (0.0-1.0)
    height: 0.3,   // <<< EDIT: Height (0.0-1.0)
    label: 'Overlay 8',
  );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Overlay 4': false,
    'Overlay 5': false,
    'Overlay 6': false,
    'Overlay 7': false,
    'Overlay 8': false,
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Overlay 4': Colors.purple,
    'Overlay 5': Colors.orange,
    'Overlay 6': Colors.red,      // Attack - Red
    'Overlay 7': Colors.blue,     // Defense - Blue
    'Overlay 8': Colors.amber,    // History - Amber
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Overlay 4': Icons.history,
    'Overlay 5': Icons.history,
    'Overlay 6': Icons.sports_mma,    // Attack icon
    'Overlay 7': Icons.shield,        // Defense icon
    'Overlay 8': Icons.history,       // History icon
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
    overlay4,
    overlay5,
    overlay6,
    overlay7,
    overlay8,
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
