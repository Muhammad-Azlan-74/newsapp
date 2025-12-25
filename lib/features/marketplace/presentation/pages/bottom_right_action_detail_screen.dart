import 'package:flutter/material.dart';
import 'package:newsapp/app/theme/app_colors.dart';

/// News Stall Detail Screen
///
/// Placeholder screen for news stall overlay area
class BottomRightActionDetailScreen extends StatelessWidget {
  const BottomRightActionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Stall'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Colors.pink.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Content Coming Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This area will contain news content',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
