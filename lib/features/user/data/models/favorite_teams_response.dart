import 'team_model.dart';

/// Favorite Teams Response Model
///
/// Response from GET /api/user/preferences/favorite-teams
class FavoriteTeamsResponse {
  final List<Team> favoriteTeams;

  const FavoriteTeamsResponse({
    required this.favoriteTeams,
  });

  /// Create from JSON
  factory FavoriteTeamsResponse.fromJson(Map<String, dynamic> json) {
    final favoriteTeamsJson = json['favoriteTeams'] as List<dynamic>? ?? [];
    final favoriteTeams = favoriteTeamsJson
        .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
        .toList();

    return FavoriteTeamsResponse(
      favoriteTeams: favoriteTeams,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'favoriteTeams': favoriteTeams.map((team) => team.toJson()).toList(),
    };
  }
}
