import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'building_overlay.dart';

/// Background widget with image-relative overlay positioning
///
/// This widget displays a background image and positions overlays
/// relative to the image coordinates, not screen coordinates.
/// Overlays stay locked to the image when screen size changes.
class ImageRelativeBackground extends StatefulWidget {
  /// Path to the background image asset
  final String imagePath;

  /// List of building overlays with normalized coordinates
  final List<BuildingOverlay> overlays;

  /// Opacity of the background image (0.0 to 1.0)
  final double opacity;

  /// Optional child widget to display on top of everything
  final Widget? child;

  /// Whether to show debug borders around overlay areas
  final bool debugMode;

  const ImageRelativeBackground({
    super.key,
    required this.imagePath,
    required this.overlays,
    this.opacity = 1.0,
    this.child,
    this.debugMode = false,
  });

  @override
  State<ImageRelativeBackground> createState() => _ImageRelativeBackgroundState();
}

class _ImageRelativeBackgroundState extends State<ImageRelativeBackground> {
  ui.Image? _image;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageRelativeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DefaultAssetBundle.of(context).load(widget.imagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _image = frame.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return _buildFallback();
    }

    if (_error != null) {
      return _buildFallback();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate rendered image dimensions with BoxFit.cover
        final imageAspectRatio = _image!.width / _image!.height;
        final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

        double renderedWidth;
        double renderedHeight;
        double offsetX;
        double offsetY;

        if (screenAspectRatio > imageAspectRatio) {
          // Screen is wider than image - fit to width and crop height
          renderedWidth = constraints.maxWidth;
          renderedHeight = renderedWidth / imageAspectRatio;
          offsetX = 0;
          offsetY = (constraints.maxHeight - renderedHeight) / 2;
        } else {
          // Screen is taller than image - fit to height and crop width
          renderedHeight = constraints.maxHeight;
          renderedWidth = renderedHeight * imageAspectRatio;
          offsetX = (constraints.maxWidth - renderedWidth) / 2;
          offsetY = 0;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (centered with BoxFit.contain behavior)
            Positioned(
              left: offsetX,
              top: offsetY,
              width: renderedWidth,
              height: renderedHeight,
              child: Opacity(
                opacity: widget.opacity,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.fill, // We already calculated the size
                  width: renderedWidth,
                  height: renderedHeight,
                ),
              ),
            ),

            // Building Overlays (positioned relative to image)
            ...widget.overlays.map((overlay) {
              // Convert normalized coordinates to screen coordinates
              final overlayLeft = offsetX + (overlay.left * renderedWidth);
              final overlayTop = offsetY + (overlay.top * renderedHeight);
              final overlayWidth = overlay.width * renderedWidth;
              final overlayHeight = overlay.height * renderedHeight;

              return Positioned(
                left: overlayLeft,
                top: overlayTop,
                width: overlayWidth,
                height: overlayHeight,
                child: overlay.customWidget ?? _buildDefaultOverlay(overlay),
              );
            }).toList(),

            // Optional child widget on top
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  Widget _buildDefaultOverlay(BuildingOverlay overlay) {
    return Container(
      decoration: BoxDecoration(
        color: overlay.color ?? Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(overlay.borderRadius),
        border: overlay.borderColor != null
            ? Border.all(
                color: overlay.borderColor!,
                width: overlay.borderWidth,
              )
            : null,
        boxShadow: widget.debugMode
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: overlay.label != null
          ? Center(
              child: Text(
                overlay.label!,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }

  Widget _buildFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade800,
          ],
        ),
      ),
      child: widget.child ?? const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }
}
