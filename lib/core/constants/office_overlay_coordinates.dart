import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Office Building overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the office building screen using normalized coordinates (0.0-1.0)
class OfficeOverlays {
  OfficeOverlays._(); // Private constructor to prevent instantiation

  /// Office Area 1 - Top Left
  static BuildingOverlay get area1 => const BuildingOverlay(
        left: 0.01,
        top: 0.17,
        width: 0.99,
        height: 0.20,
        label: 'Office 1',
      );

  /// Office Area 2 - Top Center
  static BuildingOverlay get area2 => const BuildingOverlay(
        left: 0.001,
        top: 1.09,
        width: 0.4,
        height: 0.17,
        label: 'Office 2',
      );

  /// Office Area 3 - Top Right
  static BuildingOverlay get area3 => const BuildingOverlay(
    left: 0.60,
    top: 0.87,
    width: 0.43,
    height: 0.17,
    label: 'Office 3',
      );

  /// Office Area 4 - Middle Left
  static BuildingOverlay get area4 => const BuildingOverlay(
        left: 0.001,
        top: 0.43,
        width: 0.40,
        height: 0.17,
        label: 'Office 4',
      );

  /// Office Area 5 - Middle Center
  static BuildingOverlay get area5 => const BuildingOverlay(
    left: 0.001,
    top: 0.87,
    width: 0.4,
    height: 0.17,
        label: 'Office 5',
      );

  /// Office Area 6 - Middle Right
  static BuildingOverlay get area6 => const BuildingOverlay(
        left: 0.60,
        top: 0.43,
        width: 0.4,
        height: 0.17,
        label: 'Office 6',
      );

  /// Office Area 7 - Bottom Left
  static BuildingOverlay get area7 => const BuildingOverlay(
        left: 0.001,
        top: 0.65,
        width: 0.4,
        height: 0.17,
        label: 'Office 7',
      );

  /// Office Area 8 - Bottom Center
  static BuildingOverlay get area8 => const BuildingOverlay(
        left: 0.6,
    top: 1.09,
    width: 0.43,
    height: 0.17,
        label: 'Office 8',
      );

  /// Office Area 9 - Bottom Right
  static BuildingOverlay get area9 => const BuildingOverlay(
        left: 0.60,
        top: 0.65,
        width: 0.43,
        height: 0.17,
        label: 'Office 9',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Office 1': false, // Rectangular
    'Office 2': false, // Rectangular
    'Office 3': false, // Rectangular
    'Office 4': false, // Rectangular
    'Office 5': false, // Rectangular
    'Office 6': false, // Rectangular
    'Office 7': false, // Rectangular
    'Office 8': false, // Rectangular
    'Office 9': false, // Rectangular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Office 1': Colors.blue,
    'Office 2': Colors.green,
    'Office 3': Colors.orange,
    'Office 4': Colors.purple,
    'Office 5': Colors.red,
    'Office 6': Colors.teal,
    'Office 7': Colors.pink,
    'Office 8': Colors.amber,
    'Office 9': Colors.indigo,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Office 1': Icons.meeting_room,
    'Office 2': Icons.computer,
    'Office 3': Icons.chair,
    'Office 4': Icons.desk,
    'Office 5': Icons.people,
    'Office 6': Icons.coffee,
    'Office 7': Icons.print,
    'Office 8': Icons.local_library,
    'Office 9': Icons.settings,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        area1,
        area2,
        area3,
        area4,
        area5,
        area6,
        area7,
        area8,
        area9,
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
