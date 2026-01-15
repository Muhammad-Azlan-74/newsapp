import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/notification_model.dart';
import 'package:newsapp/features/user/data/models/notifications_response_model.dart';

/// Notification Repository
///
/// Handles all notification-related API calls
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Register FCM token with backend
  ///
  /// Requires authentication
  Future<void> registerFcmToken({
    required String fcmToken,
    required String deviceId,
    required String platform,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.post(
        ApiEndpoints.registerFcmToken,
        data: {
          'fcmToken': fcmToken,
          'deviceId': deviceId,
          'platform': platform,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Remove FCM token from backend (on logout)
  ///
  /// Requires authentication
  Future<void> removeFcmToken(String fcmToken) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.delete(
        ApiEndpoints.removeFcmToken,
        data: {
          'fcmToken': fcmToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get user's notifications with pagination
  ///
  /// Requires authentication
  Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return NotificationsResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Mark notification as read
  ///
  /// Requires authentication
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.put(
        ApiEndpoints.markNotificationRead(notificationId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Delete notification
  ///
  /// Requires authentication
  Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.delete(
        ApiEndpoints.deleteNotification(notificationId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update notification settings
  ///
  /// Requires authentication
  Future<void> updateNotificationSettings({
    required bool email,
    required bool push,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.patch(
        ApiEndpoints.notificationSettings,
        data: {
          'email': email,
          'push': push,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException();
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException();
    }

    // Extract error message from response
    String errorMessage = 'An error occurred';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response!.statusCode;

      // Try to extract message from response
      if (e.response!.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] as String? ??
              data['error'] as String? ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        }
      }

      // Handle specific status codes
      if (statusCode == 401) {
        throw UnauthorizedException();
      } else if (statusCode == 403) {
        throw ForbiddenException(errorMessage);
      } else if (statusCode == 404) {
        throw NotFoundException(errorMessage);
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }
}
