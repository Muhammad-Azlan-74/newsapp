import 'package:flutter/material.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

/// Interactive overlay area widget for marketplace dashboard
///
/// Displays a tappable area that can be circular or rectangular
/// with custom styling and tap handling
class InteractiveOverlayArea extends StatefulWidget {
  /// The building overlay configuration
  final BuildingOverlay overlay;

  /// Whether this area should be circular (true) or rectangular (false)
  final bool isCircular;

  /// The color for this overlay area
  final Color color;

  /// Icon to display in the center
  final IconData? icon;

  /// Callback when the area is tapped
  final VoidCallback onTap;

  const InteractiveOverlayArea({
    super.key,
    required this.overlay,
    required this.isCircular,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  State<InteractiveOverlayArea> createState() => _InteractiveOverlayAreaState();
}

class _InteractiveOverlayAreaState extends State<InteractiveOverlayArea>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_isPressed ? 0.6 : 0.4),
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(12),
          border: Border.all(
            color: widget.color,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: widget.isCircular ? 32 : 40,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              if (widget.icon != null && widget.overlay.label != null)
                const SizedBox(height: 8),
              if (widget.overlay.label != null)
                Text(
                  widget.overlay.label!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isCircular ? 12 : 16,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
