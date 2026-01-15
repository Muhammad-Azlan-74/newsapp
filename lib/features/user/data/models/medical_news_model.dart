/// Medical News Model
///
/// Represents medical news (type: "Medical")
class MedicalNews {
  final String id;
  final String teamId;
  final String title;
  final String description;
  final String summary;
  final String publishedDate;
  final String type;
  final Map<String, dynamic> source;
  final String color;
  final String league;
  final String createdAt;
  final String updatedAt;

  MedicalNews({
    required this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.summary,
    required this.publishedDate,
    required this.type,
    required this.source,
    required this.color,
    required this.league,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalNews.fromJson(Map<String, dynamic> json) {
    return MedicalNews(
      id: json['_id'] ?? '',
      teamId: json['teamId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      summary: json['summary'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      type: json['type'] ?? 'Medical',
      source: json['source'] ?? {},
      color: json['color'] ?? '',
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
      'publishedDate': publishedDate,
      'type': type,
      'source': source,
      'color': color,
      'league': league,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Medical News Response Model
class MedicalNewsResponse {
  final List<MedicalNews> medicalNews;
  final int count;
  final PaginationInfo pagination;

  MedicalNewsResponse({
    required this.medicalNews,
    required this.count,
    required this.pagination,
  });

  factory MedicalNewsResponse.fromJson(Map<String, dynamic> json) {
    return MedicalNewsResponse(
      medicalNews: (json['data'] as List?)
              ?.map((item) => MedicalNews.fromJson(item))
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
