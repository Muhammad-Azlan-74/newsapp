import 'package:flutter/material.dart';

/// Represents a building overlay with image-relative coordinates
///
/// All coordinates are normalized (0.0 to 1.0) relative to the image dimensions
/// - (0, 0) is top-left corner of the image
/// - (1, 1) is bottom-right corner of the image
class BuildingOverlay {
  /// Normalized left position (0.0 to 1.0)
  final double left;

  /// Normalized top position (0.0 to 1.0)
  final double top;

  /// Normalized width (0.0 to 1.0)
  final double width;

  /// Normalized height (0.0 to 1.0)
  final double height;

  /// Label or identifier for this building
  final String? label;

  /// Custom widget to display (if null, shows white container)
  final Widget? customWidget;

  /// Container color (default: white with 0.7 opacity)
  final Color? color;

  /// Border radius for the container
  final double borderRadius;

  /// Border color and width
  final Color? borderColor;
  final double borderWidth;

  const BuildingOverlay({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.label,
    this.customWidget,
    this.color,
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth = 2.0,
  }) : assert(left >= 0.0 && left <= 1.0),
       assert(top >= 0.0),
       assert(width > 0.0 && width <= 1.0),
       assert(height > 0.0 && height <= 1.0);

  /// Creates a copy with modified properties
  BuildingOverlay copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
    String? label,
    Widget? customWidget,
    Color? color,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BuildingOverlay(
      left: left ?? this.left,
      top: top ?? this.top,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
      customWidget: customWidget ?? this.customWidget,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }
}
