import 'team_model.dart';
import 'news_levels_model.dart';
import 'notifications_settings_model.dart';

/// User Preferences Model
///
/// Represents all user preferences from GET /api/user/preferences
class UserPreferences {
  final List<Team> favoriteTeams;
  final NewsLevels newsLevels;
  final NotificationsSettings notifications;

  const UserPreferences({
    required this.favoriteTeams,
    required this.newsLevels,
    required this.notifications,
  });

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final preferencesData = json['preferences'] as Map<String, dynamic>? ?? json;

    final favoriteTeamsJson = preferencesData['favoriteTeams'] as List<dynamic>? ?? [];
    final favoriteTeams = favoriteTeamsJson
        .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
        .toList();

    return UserPreferences(
      favoriteTeams: favoriteTeams,
      newsLevels: NewsLevels.fromJson(
        preferencesData['newsLevels'] as Map<String, dynamic>? ?? {},
      ),
      notifications: NotificationsSettings.fromJson(
        preferencesData['notifications'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'favoriteTeams': favoriteTeams.map((team) => team.toJson()).toList(),
      'newsLevels': newsLevels.toJson(),
      'notifications': notifications.toJson(),
    };
  }
}
