/// Notifications Settings Model
///
/// Represents user's notification preferences
class NotificationsSettings {
  final bool email;
  final bool push;

  const NotificationsSettings({
    required this.email,
    required this.push,
  });

  /// Create from JSON
  factory NotificationsSettings.fromJson(Map<String, dynamic> json) {
    return NotificationsSettings(
      email: json['email'] as bool? ?? true,
      push: json['push'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'push': push,
    };
  }
}
