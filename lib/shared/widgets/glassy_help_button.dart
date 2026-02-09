import 'package:flutter/material.dart';
import 'dart:ui';

/// Glassy Help Button Widget
///
/// A button with glassmorphism effect matching the app's button style
/// Can show different icons based on the icon parameter
class GlassyHelpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;

  const GlassyHelpButton({
    super.key,
    this.onPressed,
    this.icon = Icons.info_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed ?? () {
                // Placeholder - functionality to be implemented later
              },
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: iconColor ?? Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
