/// API Endpoints
///
/// Centralized constants for all API endpoints
class ApiEndpoints {
  // Base URL for the sports app backend
  static const String baseUrl = 'https://backend-j49h.onrender.com';

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

  /// Add caption to Hall of Fame picture
  static const String hofCaption = '/api/halloffame/caption';

  /// Make offer on Hall of Fame picture
  static const String hofOffer = '/api/halloffame/offer';

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

  // Game endpoints
  /// Get all user cards
  static const String userCards = '/api/game/cards';

  /// Rookie draft - get 5 new random cards (once per 20 minutes)
  static const String rookieDraft = '/api/game/rookie-draft';

  /// Update attack lineup (4 player cards + 1 synergy card)
  static const String updateAttack = '/api/game/update-attack';

  /// Update defense lineup (4 player cards + 1 synergy card)
  static const String updateDefense = '/api/game/update-defense';

  /// Get attack lineup (returns saved attack lineup)
  static const String attackLineup = '/api/game/attack-lineup';

  /// Get defense lineup (returns saved defense lineup)
  static const String defenseLineup = '/api/game/defense-lineup';

  /// Get attack available cards (cards not in defense lineup)
  static const String attackAvailableCards = '/api/game/attack-available-cards';

  /// Get defense available cards (cards not in attack lineup)
  static const String defenseAvailableCards = '/api/game/defense-available-cards';

  /// Get all users for attack
  static const String attackUsers = '/api/game/users';

  /// Initiate attack on a user
  static const String initiateAttack = '/api/game/attack';

  /// Get defense match (check if user is being attacked)
  static const String defenseMatch = '/api/game/defense-match';

  /// Get matches history (attack, defense, or all)
  static const String matches = '/api/game/matches';

  /// Calculate match result manually (if deadline passed)
  static const String calculateMatchResult = '/api/game/calculate-match-result';

  /// Get match details with full lineup data
  /// Usage: ApiEndpoints.matchDetails('matchId')
  static String matchDetails(String matchId) => '/api/game/match/$matchId';

  /// Select reward card after winning a match
  static const String selectRewardCard = '/api/game/select-reward-card';

  /// Get opponent lineup for a specific match
  static const String opponentLineup = '/api/game/opponent-lineup';
}
