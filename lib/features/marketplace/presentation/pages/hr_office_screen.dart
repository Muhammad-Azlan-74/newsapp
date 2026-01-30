import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// HR Office Screen
///
/// Displays only the HR office background image with no overlays
class HrOfficeScreen extends StatelessWidget {
  const HrOfficeScreen({super.key});

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
                image: AssetImage(AppAssets.hrOffice),
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
