import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/personal_office_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/settings_tv_dialog.dart';
import 'package:newsapp/shared/widgets/personalization_dialog.dart';
import 'package:newsapp/shared/widgets/support_dialog.dart';
import 'package:newsapp/shared/widgets/customization_dialog.dart';
import 'package:newsapp/shared/widgets/status_dialog.dart';
import 'package:newsapp/shared/widgets/fantasy_dialog.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Personal Office Screen
///
/// Displays the personal office background image with interactive overlays
class PersonalOfficeScreen extends StatefulWidget {
  const PersonalOfficeScreen({super.key});

  @override
  State<PersonalOfficeScreen> createState() => _PersonalOfficeScreenState();
}

class _PersonalOfficeScreenState extends State<PersonalOfficeScreen> {
  bool _showHelpLabels = false;

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return; // Already showing

    setState(() {
      _showHelpLabels = true;
    });

    // Hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget
  Widget _buildHelpLabel(String text, {VoidCallback? onTap}) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: _showHelpLabels ? onTap : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get display name for area label
  String _getAreaDisplayName(String? label) {
    switch (label) {
      case 'Area 1':
        return 'Settings';
      case 'Area 2':
        return 'Fantasy';
      case 'Area 3':
        return 'Status';
      case 'Area 4':
        return 'Support';
      case 'Area 5':
        return 'Personalization';
      case 'Area 6':
        return 'Customization';
      default:
        return label ?? '';
    }
  }

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = PersonalOfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      // Convert normalized coordinates to actual pixel positions
      final left = overlay.left * imageWidth;
      final top = overlay.top * imageHeight;
      final width = overlay.width * imageWidth;
      final height = overlay.height * imageHeight;

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () {
            // Show SettingsTvDialog for Area 1
            if (label == 'Area 1') {
              showDialog(
                context: context,
                builder: (context) => const SettingsTvDialog(),
              );
            } else if (label == 'Area 2') {
              // Show FantasyDialog for Area 2
              showDialog(
                context: context,
                builder: (context) => const FantasyDialog(),
              );
            } else if (label == 'Area 3') {
              // Show StatusDialog for Area 3
              showDialog(
                context: context,
                builder: (context) => const StatusDialog(),
              );
            } else if (label == 'Area 5') {
              // Show PersonalizationDialog for Area 5
              showDialog(
                context: context,
                builder: (context) => const PersonalizationDialog(),
              );
            } else if (label == 'Area 4') {
              // Show SupportDialog for Area 4
              showDialog(
                context: context,
                builder: (context) => const SupportDialog(),
              );
            } else if (label == 'Area 6') {
              // Show CustomizationDialog for Area 6
              showDialog(
                context: context,
                builder: (context) => const CustomizationDialog(),
              );
            } else {
              // Default dialog for other areas
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(label ?? 'Personal Office Area'),
                  content: const Text('Overlay tapped!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  /// Build help labels for all overlays
  List<Widget> _buildHelpLabels(double screenWidth, double screenHeight) {
    if (!_showHelpLabels) return [];

    final overlays = PersonalOfficeOverlays.all;

    return overlays.map((overlay) {
      final left = overlay.left * screenWidth + 5;
      final top = overlay.top * screenHeight + 5;
      final displayName = _getAreaDisplayName(overlay.label);

      VoidCallback? onTap;
      if (overlay.label == 'Area 1') {
        onTap = () => showDialog(context: context, builder: (context) => const SettingsTvDialog());
      } else if (overlay.label == 'Area 2') {
        onTap = () => showDialog(context: context, builder: (context) => const FantasyDialog());
      } else if (overlay.label == 'Area 3') {
        onTap = () => showDialog(context: context, builder: (context) => const StatusDialog());
      } else if (overlay.label == 'Area 4') {
        onTap = () => showDialog(context: context, builder: (context) => const SupportDialog());
      } else if (overlay.label == 'Area 5') {
        onTap = () => showDialog(context: context, builder: (context) => const PersonalizationDialog());
      } else if (overlay.label == 'Area 6') {
        onTap = () => showDialog(context: context, builder: (context) => const CustomizationDialog());
      }

      return Positioned(
        left: left,
        top: top,
        child: _buildHelpLabel(displayName, onTap: onTap),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Get screen dimensions
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;

              return Stack(
                children: [
                  // Background image with BoxFit.cover
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.personalOffice,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                      gaplessPlayback: true,
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
                  // Overlays positioned on the screen
                  ..._buildOverlays(context, screenWidth, screenHeight),
                  // Help labels for all areas
                  ..._buildHelpLabels(screenWidth, screenHeight),
                  // Back button
                  const Positioned(
                    top: 40,
                    left: 16,
                    child: GlassyBackButton(),
                  ),
                  // Help button
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GlassyHelpButton(onPressed: _toggleHelpLabels),
                  ),
                ],
              );
            },
          ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

