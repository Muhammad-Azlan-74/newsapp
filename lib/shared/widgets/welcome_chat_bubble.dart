import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

/// Welcome Chat Bubble Widget
///
/// Displays a welcome message in a chat bubble that appears in the bottom left
/// and automatically disappears after a few seconds
class WelcomeChatBubble extends StatefulWidget {
  final bool isFirstTime;
  final VoidCallback? onDismissed;
  final String? customMessage;

  const WelcomeChatBubble({
    super.key,
    required this.isFirstTime,
    this.onDismissed,
    this.customMessage,
  });

  @override
  State<WelcomeChatBubble> createState() => _WelcomeChatBubbleState();
}

class _WelcomeChatBubbleState extends State<WelcomeChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Slide animation (from left)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation
    _animationController.forward();

    // Auto-dismiss after 4.5 seconds
    _dismissTimer = Timer(const Duration(milliseconds: 4500), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          widget.onDismissed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.customMessage ??
        (widget.isFirstTime
            ? 'Welcome to the newsapp'
            : 'Welcome back');

    return Positioned(
      left: 140, // Position to the right of the avatar (avatar at left: 20, width: 110)
      bottom: 65, // Align with avatar center (avatar at bottom: 30, height: 110, so center is at 30 + 55 = 85, minus half bubble height)
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chat bubble tail pointing to the left (towards avatar)
              CustomPaint(
                size: const Size(12, 20),
                painter: _ChatBubbleTailPainter(),
              ),
              // Glossy chat bubble
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Custom painter for the chat bubble tail pointing left (towards avatar)
class _ChatBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height * 0.3) // Top right
      ..lineTo(0, size.height / 2) // Point to left
      ..lineTo(size.width, size.height * 0.7) // Bottom right
      ..close();

    // Add shadow to the tail
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.2),
      3,
      false,
    );

    canvas.drawPath(path, paint);

    // Add border to tail
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
