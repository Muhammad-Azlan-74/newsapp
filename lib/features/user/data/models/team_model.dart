import 'team_images_model.dart';

/// Team Model
///
/// Represents a sports team
class Team {
  final String id;
  final String name;
  final String code;
  final String league;
  final TeamImages images;

  const Team({
    required this.id,
    required this.name,
    required this.code,
    required this.league,
    required this.images,
  });

  /// Create from JSON (for GET /api/user/preferences)
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      league: json['league'] as String? ?? '',
      images: TeamImages.fromJson(json['images'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'league': league,
      'images': images.toJson(),
    };
  }
}
