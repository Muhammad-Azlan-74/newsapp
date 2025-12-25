import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Marketplace overlay coordinates configuration
///
/// Defines the positions and properties of all interactive overlay areas
/// on the marketplace dashboard screen using normalized coordinates (0.0-1.0)
class MarketplaceOverlays {
  MarketplaceOverlays._(); // Private constructor to prevent instantiation

  /// Social Bar - Tall vertical rectangle on the left side
  static BuildingOverlay get leftZone => const BuildingOverlay(
        left: 0.07,
        top: 0.25,
        width: 0.10,
        height: 0.30,
        label: 'Social Bar',
      );

  /// Training Ground - Large oval area in the center
  static BuildingOverlay get centerHub => const BuildingOverlay(
        left: 0.33,
        top: 0.15,  // Moved up from 0.25
        width: 0.30,
        height: 0.45,  // Extended vertically to make it oval (was 0.30)
        label: 'Training Ground',
      );

  /// Hall of Fame - Tall vertical rectangle (top right)
  static BuildingOverlay get rightTopZone => const BuildingOverlay(
        left: 0.79,
        top: 0.2,  // Moved up from 0.10
        width: 0.12,
        height: 0.35,
        label: 'Hall of Fame',
      );

  /// Office Building - Tall vertical rectangle (bottom right)
  static BuildingOverlay get rightBottomZone => const BuildingOverlay(
        left: 0.2,
        top: 0.03,
        width: 0.10,
        height: 0.50,
        label: 'Office Building',
      );

  /// News Stall - Small circular button (bottom right corner)
  static BuildingOverlay get bottomRightAction => const BuildingOverlay(
        left: 0.61,
        top: 0.62,  // Moved up (was 0.80, moved up by 2x its height 0.15*2 = 0.30)
        width: 0.35,
        height: 0.18,
        label: 'News Stall',
      );

  /// Map of overlay names to their circular/rectangular shape
  static const Map<String, bool> shapeMap = {
    'Social Bar': false, // Rectangular
    'Training Ground': true, // Circular
    'Hall of Fame': false, // Rectangular
    'Office Building': false, // Rectangular
    'News Stall': true, // Circular
  };

  /// Map of overlay names to their colors
  static const Map<String, Color> colorMap = {
    'Social Bar': Colors.deepPurple,
    'Training Ground': Colors.blue,
    'Hall of Fame': Colors.teal,
    'Office Building': Colors.orange,
    'News Stall': Colors.pink,
  };

  /// Map of overlay names to their icons
  static const Map<String, IconData> iconMap = {
    'Social Bar': Icons.featured_play_list,
    'Training Ground': Icons.hub,
    'Hall of Fame': Icons.category,
    'Office Building': Icons.widgets,
    'News Stall': Icons.touch_app,
  };

  /// Get all overlays as a list
  static List<BuildingOverlay> get all => [
        leftZone,
        centerHub,
        rightTopZone,
        rightBottomZone,
        bottomRightAction,
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
