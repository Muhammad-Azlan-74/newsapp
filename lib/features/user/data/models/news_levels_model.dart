/// News Levels Model
///
/// Represents user's news level preferences
class NewsLevels {
  final bool green;
  final bool yellow;
  final bool red;
  final bool blue;

  const NewsLevels({
    required this.green,
    required this.yellow,
    required this.red,
    required this.blue,
  });

  /// Create from JSON
  factory NewsLevels.fromJson(Map<String, dynamic> json) {
    return NewsLevels(
      green: json['green'] as bool? ?? true,
      yellow: json['yellow'] as bool? ?? true,
      red: json['red'] as bool? ?? true,
      blue: json['blue'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'green': green,
      'yellow': yellow,
      'red': red,
      'blue': blue,
    };
  }
}
