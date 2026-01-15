import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/models/notification_model.dart';
import 'package:newsapp/features/user/data/repositories/notification_repository.dart';
import 'package:newsapp/shared/widgets/background_widget.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/notification_item_widget.dart';

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

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load notifications from API
  Future<void> _loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      if (refresh) {
        _currentPage = 1;
        _notifications.clear();
        _hasMorePages = true;
      }
    });

    try {
      final response = await _repository.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _notifications = response.notifications;
        } else {
          _notifications.addAll(response.notifications);
        }
        _hasMorePages = response.pagination.hasNextPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
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
      body: BackgroundWidget(
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
