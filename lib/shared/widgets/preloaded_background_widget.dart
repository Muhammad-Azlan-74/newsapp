import 'package:flutter/material.dart';

/// Preloaded Background Widget
///
/// Ensures background image is loaded before displaying
/// Shows dark background for minimum 0.5 seconds for smooth transitions
class PreloadedBackgroundWidget extends StatefulWidget {
  /// Path to the background image asset
  final String imagePath;

  /// Opacity of the background image (0.0 to 1.0)
  final double opacity;

  /// The child widget to display on top of the background
  final Widget child;

  /// Minimum loading time in milliseconds (default 500ms)
  final int minLoadingTime;

  const PreloadedBackgroundWidget({
    super.key,
    required this.imagePath,
    required this.opacity,
    required this.child,
    this.minLoadingTime = 500,
  });

  @override
  State<PreloadedBackgroundWidget> createState() => _PreloadedBackgroundWidgetState();
}

class _PreloadedBackgroundWidgetState extends State<PreloadedBackgroundWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  Future<void> _preloadImage() async {
    // Start timer and image precaching simultaneously
    final timer = Future.delayed(Duration(milliseconds: widget.minLoadingTime));

    try {
      // Precache the image
      await precacheImage(AssetImage(widget.imagePath), context);
    } catch (e) {
      // Silently fail - will show dark background
    }

    // Wait for minimum loading time
    await timer;

    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoaded
          ? Container(
              key: const ValueKey('loaded'),
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                  opacity: widget.opacity,
                  onError: (exception, stackTrace) {
                    // Silently fail - white background will show
                  },
                ),
              ),
              child: SafeArea(
                child: widget.child,
              ),
            )
          : Container(
              key: const ValueKey('loading'),
              color: Colors.white,
              child: SafeArea(
                child: widget.child,
              ),
            ),
    );
  }
}
