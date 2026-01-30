import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/models/notification_model.dart';
import 'package:newsapp/features/user/data/repositories/notification_repository.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/notification_item_widget.dart';
import 'package:newsapp/core/services/socket_service.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';

/// News Stand Screen (Notifications Screen)
///
/// Displays all notifications for the user
class NewsStandScreen extends StatefulWidget {
  const NewsStandScreen({super.key});

  @override
  State<NewsStandScreen> createState() => _NewsStandScreenState();
}

class _NewsStandScreenState extends State<NewsStandScreen> {
  final NotificationRepository _repository = NotificationRepository(ApiClient());
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
    // Socket.IO temporarily disabled - using polling instead
    // _initializeSocketConnection();

    // Auto-refresh every 10 seconds to check for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && !_isLoading) {
        debugPrint('📡 Checking for new notifications...');
        _loadNotifications(refresh: true, silent: true);
      }
    });
  }

  /// Initialize Socket.IO connection for real-time notifications
  Future<void> _initializeSocketConnection() async {
    try {
      final accessToken = await AuthStorageService.getToken();
      if (accessToken != null) {
        // Connect to Socket.IO
        await _socketService.connect(accessToken);

        // Listen for incoming notifications
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

  /// Handle incoming real-time notification from Socket.IO
  void _handleIncomingNotification(NotificationModel notification) {
    setState(() {
      // Add new notification to the top of the list
      _notifications.insert(0, notification);
    });

    // Show in-app notification snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pollingTimer?.cancel();
    // Keep socket alive - don't disconnect
    super.dispose();
  }

  /// Load notifications from API
  Future<void> _loadNotifications({bool refresh = false, bool silent = false}) async {
    if (_isLoading) return;

    if (!silent) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        if (refresh) {
          _currentPage = 1;
          _notifications.clear();
          _hasMorePages = true;
        }
      });
    }

    try {
      final response = await _repository.getNotifications(
        page: refresh ? 1 : _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          if (refresh || silent) {
            // Check if there are new notifications
            final newNotifications = response.notifications
                .where((newNotif) => !_notifications.any((existing) => existing.id == newNotif.id))
                .toList();

            if (newNotifications.isNotEmpty) {
              debugPrint('✅ Found ${newNotifications.length} new notification(s)!');
              // Add new notifications to the top
              _notifications.insertAll(0, newNotifications);
            }
          } else {
            _notifications.addAll(response.notifications);
          }
          _hasMorePages = response.pagination.hasNextPage;
          if (!silent) {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMorePages) {
      _currentPage++;
      _loadNotifications();
    }
  }

  /// Mark notification as read and navigate
  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read
    if (!notification.read) {
      try {
        await _repository.markNotificationAsRead(notification.id);
        setState(() {
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = notification.copyWith(read: true);
          }
        });
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }

    // Navigate based on notification type
    _navigateBasedOnType(notification);
  }

  /// Navigate to appropriate screen based on notification type
  void _navigateBasedOnType(NotificationModel notification) {
    switch (notification.type) {
      case 'NEWS_PUBLISHED':
        // TODO: Navigate to news detail screen
        // Navigator.pushNamed(context, '/news-detail', arguments: notification.newsId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to news: ${notification.newsId}'),
          ),
        );
        break;
      case 'HOF_LIKED':
        // TODO: Navigate to Hall of Fame screen
        // Navigator.pushNamed(context, '/hof-detail', arguments: notification.hofUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to HOF: ${notification.hofUserId}'),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification opened'),
          ),
        );
    }
  }

  /// Delete notification
  Future<void> _handleNotificationDelete(NotificationModel notification) async {
    try {
      await _repository.deleteNotification(notification.id);
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(
            opacity: AppConstants.authBackgroundOpacity,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Content
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
          // Newspaper logo in bottom right
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildNewspaperLogo(),
          ),
        ],
      ),
    );
  }

  /// Build newspaper logo widget that loads from API/cache
  Widget _buildNewspaperLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/newspaper.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image not loaded yet
            return Container(
              color: Colors.white,
              child: Icon(
                Icons.newspaper,
                size: 40,
                color: Colors.grey[700],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build header with back button and title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const GlassyBackButton(),
          const SizedBox(width: 16),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Unread count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              '${_notifications.where((n) => !n.read).length} unread',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const GlassyHelpButton(),
        ],
      ),
    );
  }

  /// Build main content area
  Widget _buildContent() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_hasError && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading notifications',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadNotifications(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      color: Colors.blue,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _notifications.length + (_hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          final notification = _notifications[index];
          return NotificationItemWidget(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDelete: () => _handleNotificationDelete(notification),
          );
        },
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications,\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
