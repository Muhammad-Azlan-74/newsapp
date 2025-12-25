/// Auth Response Model
///
/// Response from authentication API endpoints
class AuthResponse {
  final String accessToken;
  final String? message;
  final Map<String, dynamic>? user;

  const AuthResponse({
    required this.accessToken,
    this.message,
    this.user,
  });

  /// Create from JSON response
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      message: json['message'] as String?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'message': message,
      'user': user,
    };
  }
}
