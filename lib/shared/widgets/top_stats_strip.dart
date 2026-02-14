import 'package:flutter/material.dart';
import 'dart:ui';

/// Top Stats Strip Widget
///
/// A thin strip showing money, XP, tier, and power icons
/// Clicking any item shows a "Coming Soon" popup
class TopStatsStrip extends StatelessWidget {
  const TopStatsStrip({super.key});

  /// Height of the strip content (excluding safe area padding)
  static const double stripHeight = 26.0;

  /// Get the total height of the strip including safe area padding
  static double getTotalHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top + stripHeight;
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Coming Soon!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$feature feature is under development',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
    required String feature,
  }) {
    return GestureDetector(
      onTap: () => _showComingSoonDialog(context, feature),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        child: Container(
          height: 26,
          // Leave space for back button (left) and help button (right)
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: Icons.monetization_on,
                value: '\$5,000',
                color: Colors.green,
                feature: 'Money',
              ),
              _buildStatItem(
                context,
                icon: Icons.star,
                value: '1,250 XP',
                color: Colors.amber,
                feature: 'XP',
              ),
              _buildStatItem(
                context,
                icon: Icons.military_tech,
                value: 'Gold',
                color: Colors.orange,
                feature: 'Tier',
              ),
              _buildStatItem(
                context,
                icon: Icons.bolt,
                value: '850',
                color: Colors.blue,
                feature: 'Power',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
