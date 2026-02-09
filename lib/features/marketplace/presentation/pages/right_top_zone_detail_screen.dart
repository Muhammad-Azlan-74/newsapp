import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/hof_overlay_coordinates.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/hof_repository.dart';
import 'package:newsapp/features/user/data/models/hof_user_model.dart';
import 'package:newsapp/features/marketplace/presentation/pages/friend_hof_hallway_screen.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';

/// Hall of Fame Detail Screen
///
/// Screen for hall of fame with background image and interactive overlays
class RightTopZoneDetailScreen extends StatefulWidget {
  const RightTopZoneDetailScreen({super.key});

  @override
  State<RightTopZoneDetailScreen> createState() => _RightTopZoneDetailScreenState();
}

class _RightTopZoneDetailScreenState extends State<RightTopZoneDetailScreen> {
  bool _showHelpLabels = false;
  final HofRepository _hofRepository = HofRepository(ApiClient());
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await AuthStorageService.getFullName() ?? await AuthStorageService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  /// Show HOF Friends dialog with hof_list.png background
  /// Re-opens the dialog when returning from a friend's HOF
  Future<void> _showHofFriendsDialog() async {
    while (true) {
      final selectedUser = await showDialog<HofUser>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => _HofFriendsDialog(hofRepository: _hofRepository),
      );

      // If no user was selected (dialog dismissed), break the loop
      if (selectedUser == null || !mounted) break;

      // Navigate to friend's HOF hallway and wait for return
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendHofHallwayScreen(
            userId: selectedUser.id,
            userName: selectedUser.fullName,
          ),
        ),
      );

      // Loop will re-show the dialog
      if (!mounted) break;
    }
  }

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return;

    setState(() {
      _showHelpLabels = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget
  Widget _buildHelpLabel(String text) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
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
    );
  }

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = HallOfFameOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () {
            // Handle tap for each overlay
            if (label == 'HOF Friends') {
              _showHofFriendsDialog();
            } else if (label == 'Personal HOF') {
              Navigator.pushNamed(context, AppRoutes.personalHof);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label tapped!')),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: 'assets/images/hof_hallway.png',
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // User name label above the gate
          if (_userName != null)
            Positioned(
              top: screenHeight * 0.22,
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
                            _userName!,
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
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
          // Help button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(onPressed: _toggleHelpLabels),
          ),
          // Help label for HOF Friends - left: 0.14, top: 0.2
          if (_showHelpLabels)
            Positioned(
              left: 0.14 * screenWidth + 5,
              top: 0.2 * screenHeight + 5,
              child: _buildHelpLabel('HOF Friends'),
            ),
          // Help label for Personal HOF - left: 0.38, top: 0.3
          if (_showHelpLabels)
            Positioned(
              left: 0.38 * screenWidth + 5,
              top: 0.3 * screenHeight + 5,
              child: _buildHelpLabel('Personal HOF'),
            ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

/// HOF Friends Dialog Widget
class _HofFriendsDialog extends StatefulWidget {
  final HofRepository hofRepository;

  // Normalized coordinates for content positioning (0.0-1.0)
  static const double contentTop = 0.60; // Start at 60% from top
  static const double contentBottom = 0.80; // End at 80% from top
  static const double contentHeight = contentBottom - contentTop; // 20% height

  const _HofFriendsDialog({required this.hofRepository});

  @override
  State<_HofFriendsDialog> createState() => _HofFriendsDialogState();
}

class _HofFriendsDialogState extends State<_HofFriendsDialog> {
  List<HofUser>? _users;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHofUsers();
  }

  Future<void> _loadHofUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await widget.hofRepository.getHofUsers();

      setState(() {
        _users = response.users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
            maxWidth: screenWidth * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(AppAssets.hofList),
              fit: BoxFit.cover,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dialogHeight = constraints.maxHeight;
              final topOffset = dialogHeight * _HofFriendsDialog.contentTop;
              final contentHeight = dialogHeight * _HofFriendsDialog.contentHeight;

              return Stack(
                children: [
                  // Semi-transparent overlay for better readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Close button at top right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content - fixed position from 60% to 80%
                  Positioned(
                    top: topOffset,
                    left: 0,
                    right: 0,
                    height: contentHeight,
                    child: _buildContent(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading users',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHofUsers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_users == null || _users!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'No HOF users found',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _users!.length,
      itemBuilder: (context, index) {
        final user = _users![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: user.username.isNotEmpty
                      ? Text(
                          '@${user.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )
                      : null,
                  trailing: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                  ),
                  onTap: () {
                    // Return selected user to caller
                    Navigator.pop(context, user);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

