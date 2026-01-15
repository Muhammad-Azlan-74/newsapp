import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/core/constants/marketplace_overlay_coordinates.dart';
import 'package:newsapp/features/marketplace/presentation/widgets/interactive_overlay_area.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/core/services/socket_service.dart';
import 'package:newsapp/features/user/data/models/notification_model.dart';

/// Marketplace/Dashboard Screen
///
/// Main screen after login showing only background image
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final SocketService _socketService = SocketService();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _initializeSocketConnection();
  }

  @override
  void dispose() {
    // Keep socket alive for the session
    super.dispose();
  }

  /// Initialize Socket.IO connection for real-time notifications
  Future<void> _initializeSocketConnection() async {
    try {
      final accessToken = await AuthStorageService.getToken();
      if (accessToken != null) {
        // Connect to Socket.IO
        await _socketService.connect(accessToken);

        // Listen for notifications
        _socketService.notificationStream.listen((notification) {
          _handleIncomingNotification(notification);
        });

        // Listen for connection status
        _socketService.connectionStatusStream.listen((isConnected) {
          debugPrint('Socket connection status: $isConnected');
        });

        // Listen for errors
        _socketService.errorStream.listen((error) {
          debugPrint('Socket error: $error');
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize socket connection: $e');
    }
  }

  /// Handle incoming real-time notification
  void _handleIncomingNotification(NotificationModel notification) {
    setState(() {
      _unreadNotifications++;
    });

    // Show in-app notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      notification.body,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.newsStand);
            },
          ),
        ),
      );
    }
  }

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = MarketplaceOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;
      final isCircular = MarketplaceOverlays.isCircular(label);
      final color = MarketplaceOverlays.getColor(label);
      final icon = MarketplaceOverlays.getIcon(label);

      // Determine the route based on the label
      String route;
      switch (label) {
        case 'Social Bar':
          route = AppRoutes.leftZoneDetail;
          break;
        case 'Training Ground':
          route = AppRoutes.centerHubDetail;
          break;
        case 'Hall of Fame':
          route = AppRoutes.rightTopZoneDetail;
          break;
        case 'Office Building':
          route = AppRoutes.rightBottomZoneDetail;
          break;
        case 'News Stall':
          route = AppRoutes.bottomRightActionDetail;
          break;
        default:
          route = AppRoutes.marketplace;
      }

      return overlay.copyWith(
        customWidget: InteractiveOverlayArea(
          overlay: overlay,
          isCircular: isCircular,
          color: color,
          icon: icon,
          onTap: () => Navigator.pushNamed(context, route),
        ),
      );
    }).toList();
  }

  /// Handle sign out
  Future<void> _handleSignOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      // Clear authentication data
      await AuthStorageService.clearAuth();

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      // Show success message
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'Signed out successfully',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with overlays
          ImageRelativeBackground(
            imagePath: AppAssets.backgroundImage,
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // Notification bell icon (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _unreadNotifications = 0;
                });
                await Navigator.pushNamed(context, AppRoutes.newsStand);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Unread badge
                  if (_unreadNotifications > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          _unreadNotifications > 99
                              ? '99+'
                              : _unreadNotifications.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSignOut,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
