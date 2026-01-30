import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Janitor Screen
///
/// Displays only the janitor office background image with no overlays
class JanitorScreen extends StatelessWidget {
  const JanitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage(AppAssets.janitorOffice),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Back button
          const Positioned(
            top: 40,
            left: 16,
            child: GlassyBackButton(),
          ),
          // Help button
          const Positioned(
            top: 40,
            right: 16,
            child: GlassyHelpButton(),
          ),
        ],
      ),
    );
  }
}
