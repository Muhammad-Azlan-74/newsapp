import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/doctors_office_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/shared/widgets/medlab_menu_dialog.dart';
import 'package:newsapp/shared/widgets/team_avatar_widget.dart';
import 'package:newsapp/shared/widgets/welcome_chat_bubble.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

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

  @override
  void initState() {
    super.initState();
    // Show welcome message after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showHelpBubble = true;
        });
      }
    });
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
      body: LayoutBuilder(
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
                  customMessage: 'Hi! How can I help you?',
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
            ],
          );
        },
      ),
    );
  }
}
