import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';

/// Fantasy Dialog Widget
///
/// Displays a sequence of dialogs with fantasy1.png, fantasy2.png, and fantasy3.png as backgrounds
/// User can tap to progress through the sequence
class FantasyDialog extends StatefulWidget {
  const FantasyDialog({super.key});

  @override
  State<FantasyDialog> createState() => _FantasyDialogState();
}

class _FantasyDialogState extends State<FantasyDialog> {
  int _currentIndex = 0;

  final List<String> _fantasyImages = [
    AppAssets.fantasy1,
    AppAssets.fantasy2,
    AppAssets.fantasy3,
  ];

  void _nextImage() {
    setState(() {
      if (_currentIndex < _fantasyImages.length - 1) {
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _nextImage,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _fantasyImages[_currentIndex],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error loading image: $error'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Close button positioned at top right
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              // Progress indicator at bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _fantasyImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
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
