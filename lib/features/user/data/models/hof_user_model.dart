/// Hall of Fame User Model
///
/// Represents a user in the Hall of Fame
class HofUser {
  final String id;
  final String fullName;

  const HofUser({
    required this.id,
    required this.fullName,
  });

  factory HofUser.fromJson(Map<String, dynamic> json) {
    return HofUser(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
    };
  }
}

/// Hall of Fame Users Response
///
/// Response model for the HOF users API endpoint
class HofUsersResponse {
  final List<HofUser> users;

  const HofUsersResponse({required this.users});

  factory HofUsersResponse.fromJson(Map<String, dynamic> json) {
    final usersList = json['users'] as List<dynamic>;
    return HofUsersResponse(
      users: usersList
          .map((user) => HofUser.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}
