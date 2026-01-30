import 'package:flutter/material.dart';
import 'dart:ui';

/// Glassy Help Button Widget
///
/// A help button with glassmorphism effect matching the app's button style
/// Shows a question mark icon for help/info functionality
class GlassyHelpButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GlassyHelpButton({
    super.key,
    this.onPressed,
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
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.black,
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
