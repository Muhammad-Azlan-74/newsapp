import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/doctors_office_overlay_coordinates.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/shared/widgets/medlab_menu_dialog.dart';
import 'package:newsapp/shared/widgets/team_avatar_widget.dart';
import 'package:newsapp/shared/widgets/welcome_chat_bubble.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Doctors Office Screen
///
/// Displays the doctor's office background image with interactive overlays
class DoctorsOfficeScreen extends StatefulWidget {
  const DoctorsOfficeScreen({super.key});

  @override
  State<DoctorsOfficeScreen> createState() => _DoctorsOfficeScreenState();
}

class _DoctorsOfficeScreenState extends State<DoctorsOfficeScreen> {
  bool _showHelpBubble = false;
  bool _showHelpLabels = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Show welcome message after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showHelpBubble = true;
        });
      }
    });
  }

  Future<void> _loadUserName() async {
    final name = await AuthStorageService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

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

  /// Build a help label widget (same design as marketplace labels)
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

  /// Build the list of interactive overlays
  List<Widget> _buildOverlays(BuildContext context, double imageWidth, double imageHeight) {
    final overlays = DoctorsOfficeOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = DoctorsOfficeOverlays.isCircular(label);
      final color = DoctorsOfficeOverlays.getColor(label);
      final icon = DoctorsOfficeOverlays.getIcon(label);

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
        child: label == 'Area 1'
            ? GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const MedlabMenuDialog(),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                ),
              )
            : InteractiveOverlayArea(
                overlay: overlay,
                isCircular: isCircular,
                color: color,
                icon: icon,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(label ?? "Doctor's Office Area"),
                      content: const Text('Overlay tapped!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
                  AppAssets.doctorOffice,
                  fit: BoxFit.cover,
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
              // Team doctor avatar in bottom left
              TeamAvatarWidget(
                imageType: 'doctor',
                onTap: () {
                  setState(() {
                    _showHelpBubble = true;
                  });
                },
              ),
              // Help chat bubble (appears when avatar is tapped)
              if (_showHelpBubble)
                WelcomeChatBubble(
                  isFirstTime: false,
                  customMessage: 'Hey ${_userName ?? 'there'}, check the MRI for all injury news.',
                  onDismissed: () {
                    setState(() {
                      _showHelpBubble = false;
                    });
                  },
                ),
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
              // Help label for MRI Machine (Area 1)
              // Area 1: left: 0.001, top: 0.27, width: 0.55, height: 0.32
              if (_showHelpLabels)
                Positioned(
                  left: 0.001 * screenWidth + 5,
                  top: 0.27 * screenHeight + 5,
                  child: _buildHelpLabel('MRI Machine', onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const MedlabMenuDialog(),
                    );
                  }),
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

