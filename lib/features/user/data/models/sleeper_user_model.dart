/// Sleeper User Model
///
/// Represents a Sleeper fantasy football user
class SleeperUser {
  final String username;
  final String userId;
  final String displayName;
  final String avatar;

  SleeperUser({
    required this.username,
    required this.userId,
    required this.displayName,
    required this.avatar,
  });

  factory SleeperUser.fromJson(Map<String, dynamic> json) {
    return SleeperUser(
      username: json['username'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userId': userId,
      'displayName': displayName,
      'avatar': avatar,
    };
  }
}
