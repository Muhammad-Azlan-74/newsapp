import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/features/marketplace/presentation/pages/friend_hof_screen.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Friend HOF Hallway Screen
///
/// Displays the HOF hallway with friend's name over the gate
/// Clicking the gate navigates to the friend's HOF room
class FriendHofHallwayScreen extends StatelessWidget {
  final String userId;
  final String userName;

  // Normalized coordinates for the gate overlay
  static const double gateLeft = 0.38;
  static const double gateTop = 0.30;
  static const double gateWidth = 0.23;
  static const double gateHeight = 0.23;

  // Normalized coordinates for the name label (above the gate)
  static const double nameLabelTop = 0.22;

  const FriendHofHallwayScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: AppConstants.dashboardBackgroundOpacity,
              child: Image.asset(
                'assets/images/hof_hallway.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Friend's name label above the gate
          Positioned(
            top: screenHeight * nameLabelTop,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Gate overlay - clickable area
          Positioned(
            left: screenWidth * gateLeft,
            top: screenHeight * gateTop,
            width: screenWidth * gateWidth,
            height: screenHeight * gateHeight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendHofScreen(
                      userId: userId,
                      userName: userName,
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}
