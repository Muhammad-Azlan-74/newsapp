import 'package:newsapp/core/utils/date_formatter.dart';

/// TV Studio News Model
///
/// Represents TV Studio news (news with green color)
class TvStudioNews {
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

  TvStudioNews({
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

  factory TvStudioNews.fromJson(Map<String, dynamic> json) {
    return TvStudioNews(
      id: json['_id'] ?? '',
      teamId: json['teamId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      summary: json['summary'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? {},
      color: json['color'] ?? 'Green',
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

/// TV Studio News Response Model
class TvStudioNewsResponse {
  final List<TvStudioNews> tvStudioNews;
  final int count;
  final PaginationInfo pagination;

  TvStudioNewsResponse({
    required this.tvStudioNews,
    required this.count,
    required this.pagination,
  });

  factory TvStudioNewsResponse.fromJson(Map<String, dynamic> json) {
    return TvStudioNewsResponse(
      tvStudioNews: (json['data'] as List?)
              ?.map((item) => TvStudioNews.fromJson(item))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// Pagination Info Model
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}
