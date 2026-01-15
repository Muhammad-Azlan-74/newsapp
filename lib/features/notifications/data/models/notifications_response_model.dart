import 'notification_model.dart';

/// Notifications Response Model
///
/// Response model for paginated notifications
class NotificationsResponseModel {
  final List<NotificationModel> data;
  final PaginationModel pagination;

  NotificationsResponseModel({
    required this.data,
    required this.pagination,
  });

  /// Create from JSON
  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// Pagination Model
///
/// Pagination information for list responses
class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });

  /// Create from JSON
  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalCount: json['totalCount'] as int,
      limit: json['limit'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalCount': totalCount,
      'limit': limit,
    };
  }

  /// Check if there are more pages
  bool get hasMore => currentPage < totalPages;

  /// Get next page number
  int? get nextPage => hasMore ? currentPage + 1 : null;
}

/// Mark Notification as Read Response Model
class MarkNotificationReadResponseModel {
  final String message;
  final NotificationModel notification;

  MarkNotificationReadResponseModel({
    required this.message,
    required this.notification,
  });

  /// Create from JSON
  factory MarkNotificationReadResponseModel.fromJson(Map<String, dynamic> json) {
    return MarkNotificationReadResponseModel(
      message: json['message'] as String,
      notification: NotificationModel.fromJson(json['notification'] as Map<String, dynamic>),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'notification': notification.toJson(),
    };
  }
}
