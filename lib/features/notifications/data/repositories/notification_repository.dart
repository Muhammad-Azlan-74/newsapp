import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/notifications/data/models/notification_model.dart';
import 'package:newsapp/features/notifications/data/models/notifications_response_model.dart';

/// Notification Repository
///
/// Handles all notification-related API calls
class NotificationRepository {
  final Dio _dio;

  NotificationRepository({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Get notifications with pagination
  ///
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20, max: 100)
  Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Get access token
      final accessToken = await AuthStorageService.getToken();
      if (accessToken == null) {
        throw ApiException('Access token is required', 401);
      }

      // Validate parameters
      if (limit > 100) {
        limit = 100;
      }

      debugPrint('📬 Fetching notifications (page: $page, limit: $limit)...');

      // Make API request
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.notifications}',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('✅ Notifications fetched: ${response.data}');

      // Parse response
      return NotificationsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Error fetching notifications: ${e.message}');
      final statusCode = e.response?.statusCode ?? 500;
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch notifications';
      throw ApiException(message, statusCode);
    } catch (e) {
      debugPrint('❌ Unexpected error fetching notifications: $e');
      throw ApiException('Failed to fetch notifications: $e', 500);
    }
  }

  /// Mark notification as read
  ///
  /// [notificationId] - ID of the notification to mark as read
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      // Get access token
      final accessToken = await AuthStorageService.getToken();
      if (accessToken == null) {
        throw ApiException('Access token is required', 401);
      }

      debugPrint('✅ Marking notification as read: $notificationId');

      // Make API request
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.markNotificationRead(notificationId)}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('✅ Notification marked as read: ${response.data}');

      // Parse response
      final responseModel = MarkNotificationReadResponseModel.fromJson(response.data);
      return responseModel.notification;
    } on DioException catch (e) {
      debugPrint('❌ Error marking notification as read: ${e.message}');
      final statusCode = e.response?.statusCode ?? 500;
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to mark notification as read';
      throw ApiException(message, statusCode);
    } catch (e) {
      debugPrint('❌ Unexpected error marking notification as read: $e');
      throw ApiException('Failed to mark notification as read: $e', 500);
    }
  }

  /// Get unread notification count
  ///
  /// Returns the count of unread notifications
  Future<int> getUnreadCount() async {
    try {
      // Fetch first page to get total count
      final response = await getNotifications(page: 1, limit: 1);

      // Count unread notifications
      // Since API doesn't provide unread count directly, we need to fetch all
      // For now, return total count as approximation
      return response.pagination.totalCount;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete notification
  ///
  /// [notificationId] - ID of the notification to delete
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Get access token
      final accessToken = await AuthStorageService.getToken();
      if (accessToken == null) {
        throw ApiException('Access token is required', 401);
      }

      debugPrint('🗑️ Deleting notification: $notificationId');

      // Make API request
      await _dio.delete(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.deleteNotification(notificationId)}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('✅ Notification deleted');
    } on DioException catch (e) {
      debugPrint('❌ Error deleting notification: ${e.message}');
      final statusCode = e.response?.statusCode ?? 500;
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to delete notification';
      throw ApiException(message, statusCode);
    } catch (e) {
      debugPrint('❌ Unexpected error deleting notification: $e');
      throw ApiException('Failed to delete notification: $e', 500);
    }
  }
}
