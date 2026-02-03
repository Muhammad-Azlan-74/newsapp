/// Fantasy Source Model
///
/// Represents a fantasy football platform
class FantasySource {
  final String name;
  final String url;
  final bool active;

  FantasySource({
    required this.name,
    required this.url,
    required this.active,
  });

  factory FantasySource.fromJson(Map<String, dynamic> json) {
    return FantasySource(
      name: json['name'] as String,
      url: json['url'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'active': active,
    };
  }
}

/// Fantasy Sources Response
class FantasySourcesResponse {
  final List<FantasySource> sources;

  FantasySourcesResponse({
    required this.sources,
  });

  factory FantasySourcesResponse.fromJson(List<dynamic> json) {
    return FantasySourcesResponse(
      sources: json.map((item) => FantasySource.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}
