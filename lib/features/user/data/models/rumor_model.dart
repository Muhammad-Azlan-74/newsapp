import 'package:newsapp/core/utils/date_formatter.dart';

/// Rumor Model
///
/// Represents a rumor (news with red color and "Other" type)
class Rumor {
  final String id;
  final String teamId;
  final String title;
  final String description;
  final String summary;
  final String _publishedDate;
  final String type;
  final Map<String, dynamic> source;
  final String color;
  final String league;
  final String createdAt;
  final String updatedAt;

  Rumor({
    required this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.summary,
    required String publishedDate,
    required this.type,
    required this.source,
    required this.color,
    required this.league,
    required this.createdAt,
    required this.updatedAt,
  }) : _publishedDate = publishedDate;

  /// Get formatted published date (HH:mm dd,MMM)
  String get publishedDate => DateFormatter.format(_publishedDate);

  factory Rumor.fromJson(Map<String, dynamic> json) {
    return Rumor(
      id: json['_id'] ?? '',
      teamId: json['teamId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      summary: json['summary'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      type: json['type'] ?? 'Other',
      source: json['source'] ?? {},
      color: json['color'] ?? 'Red',
      league: json['league'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'teamId': teamId,
      'title': title,
      'description': description,
      'summary': summary,
      'publishedDate': _publishedDate,
      'type': type,
      'source': source,
      'color': color,
      'league': league,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Single Rumor Response Model
///
/// API now returns a single rumor in the data field
class RumorResponse {
  final Rumor? rumor;

  RumorResponse({
    required this.rumor,
  });

  factory RumorResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return RumorResponse(
      rumor: data != null ? Rumor.fromJson(data) : null,
    );
  }
}
