import 'package:flutter/material.dart';
import 'package:newsapp/app/theme/app_colors.dart';

/// Office Building Detail Screen
///
/// Placeholder screen for office building overlay area
class RightBottomZoneDetailScreen extends StatelessWidget {
  const RightBottomZoneDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Building'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets,
              size: 64,
              color: Colors.orange.withOpacity(0.5),
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
              'This area will contain office content',
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
