/// API Endpoints
///
/// Centralized constants for all API endpoints
class ApiEndpoints {
  // Base URL for the sports app backend
  static const String baseUrl = 'https://sportsapp-server.vercel.app';

  // Authentication endpoints (with /api/auth prefix)
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyResetOtp = '/api/auth/verify-reset-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';

  // User preferences endpoints
  static const String userPreferences = '/api/user/preferences';
  static const String favoriteTeams = '/api/user/preferences/favorite-teams';

  // Hall of Fame endpoints
  static const String hofUsers = '/api/halloffame/users';

  /// Get Hall of Fame details for a specific user
  /// Usage: ApiEndpoints.hofDetails('userId')
  static String hofDetails(String userId) => '/api/halloffame/$userId';

  /// Upload Hall of Fame picture
  static const String hofUploadPicture = '/api/halloffame/pictures';

  /// Like Hall of Fame entry
  static const String hofLike = '/api/halloffame/like';

  /// Unlike Hall of Fame entry
  static const String hofUnlike = '/api/halloffame/unlike';

  // News endpoints
  static const String rumors = '/api/news/rumors';
  static const String medicalNews = '/api/news/medical';
  static const String tvStudioNews = '/api/news/tv-studio'; // Try with hyphen

  // Notification endpoints
  static const String notifications = '/api/notifications';
  static const String registerFcmToken = '/api/notifications/register-token';
  static const String removeFcmToken = '/api/notifications/remove-token';
  static const String notificationSettings = '/api/notifications/settings';

  /// Mark notification as read
  /// Usage: ApiEndpoints.markNotificationRead('notificationId')
  static String markNotificationRead(String notificationId) =>
      '/api/notifications/$notificationId/read';

  /// Delete notification
  /// Usage: ApiEndpoints.deleteNotification('notificationId')
  static String deleteNotification(String notificationId) =>
      '/api/notifications/$notificationId';
}
