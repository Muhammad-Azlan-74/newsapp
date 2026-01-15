/// Team Images Model
///
/// Represents the image URLs for a team
class TeamImages {
  final String anchor;
  final String doctor;
  final String newspaper;
  final String main;

  const TeamImages({
    required this.anchor,
    required this.doctor,
    required this.newspaper,
    required this.main,
  });

  /// Create from JSON
  factory TeamImages.fromJson(Map<String, dynamic> json) {
    return TeamImages(
      anchor: json['anchor'] as String? ?? '',
      doctor: json['doctor'] as String? ?? '',
      newspaper: json['newspaper'] as String? ?? '',
      main: json['main'] as String? ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'anchor': anchor,
      'doctor': doctor,
      'newspaper': newspaper,
      'main': main,
    };
  }
}
