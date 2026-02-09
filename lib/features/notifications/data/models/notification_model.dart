/// Notification Model
///
/// Represents a notification received by the user
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationData? data;
  final bool read;
  final DateTime sentAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.sentAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      read: json['read'] as bool? ?? false,
      sentAt: DateTime.parse(json['sentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type.value,
      'title': title,
      'body': body,
      'data': data?.toJson(),
      'read': read,
      'sentAt': sentAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    NotificationData? data,
    bool? read,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      read: read ?? this.read,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Notification Data
///
/// Additional data associated with a notification
class NotificationData {
  final String? newsId;
  final String? teamId;
  final String? hofId;
  final String? matchId;
  final String? offerId;
  final Map<String, dynamic>? extras;

  NotificationData({
    this.newsId,
    this.teamId,
    this.hofId,
    this.matchId,
    this.offerId,
    this.extras,
  });

  /// Create from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      newsId: json['newsId'] as String?,
      teamId: json['teamId'] as String?,
      hofId: json['hofId'] as String?,
      matchId: json['matchId'] as String?,
      offerId: json['offerId'] as String?,
      extras: json,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (newsId != null) data['newsId'] = newsId;
    if (teamId != null) data['teamId'] = teamId;
    if (hofId != null) data['hofId'] = hofId;
    if (matchId != null) data['matchId'] = matchId;
    if (offerId != null) data['offerId'] = offerId;
    if (extras != null) data.addAll(extras!);
    return data;
  }
}

/// Notification Type Enum
enum NotificationType {
  newsPublished('NEWS_PUBLISHED'),
  hofLiked('HOF_LIKED'),
  hofOfferReceived('HOF_OFFER_RECEIVED'),
  matchCompleted('MATCH_COMPLETED'),
  unknown('UNKNOWN');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    switch (value) {
      case 'NEWS_PUBLISHED':
        return NotificationType.newsPublished;
      case 'HOF_LIKED':
        return NotificationType.hofLiked;
      case 'HOF_OFFER_RECEIVED':
        return NotificationType.hofOfferReceived;
      case 'MATCH_COMPLETED':
        return NotificationType.matchCompleted;
      default:
        return NotificationType.unknown;
    }
  }

  /// Get display title for notification type
  String get displayTitle {
    switch (this) {
      case NotificationType.newsPublished:
        return 'News Update';
      case NotificationType.hofLiked:
        return 'Hall of Fame';
      case NotificationType.hofOfferReceived:
        return 'HOF Offer';
      case NotificationType.matchCompleted:
        return 'Match Result';
      case NotificationType.unknown:
        return 'Notification';
    }
  }
}
