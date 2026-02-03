/// Card Model
///
/// Models for user cards from the game API

/// Card stat model
class CardStat {
  final String? id;
  final String statName;
  final int statValue;

  const CardStat({
    this.id,
    required this.statName,
    required this.statValue,
  });

  factory CardStat.fromJson(Map<String, dynamic> json) {
    return CardStat(
      id: json['_id'] as String?,
      statName: json['statName'] as String? ?? '',
      statValue: json['statValue'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'statName': statName,
      'statValue': statValue,
    };
  }
}

/// Synergy boost model
class SynergyBoost {
  final String? id;
  final String stat;
  final int value;

  const SynergyBoost({
    this.id,
    required this.stat,
    required this.value,
  });

  factory SynergyBoost.fromJson(Map<String, dynamic> json) {
    return SynergyBoost(
      id: json['_id'] as String?,
      stat: json['stat'] as String? ?? '',
      value: json['value'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stat': stat,
      'value': value,
    };
  }
}

/// Card team model
class CardTeam {
  final String id;
  final String name;

  const CardTeam({
    required this.id,
    required this.name,
  });

  factory CardTeam.fromJson(Map<String, dynamic> json) {
    return CardTeam(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

/// User card model - supports both player and synergy card types
class UserCard {
  final String id;
  final String? odooId;
  final String userId;
  final String cardId;
  final String cardType;
  final String cardName;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Player card specific fields
  final String? position;
  final String? tier;
  final List<CardStat>? stats;
  final int? base;
  final int? max;
  final CardTeam? team;

  // Synergy card specific fields
  final String? type;
  final List<SynergyBoost>? boost;

  const UserCard({
    required this.id,
    this.odooId,
    required this.userId,
    required this.cardId,
    required this.cardType,
    required this.cardName,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.position,
    this.tier,
    this.stats,
    this.base,
    this.max,
    this.team,
    this.type,
    this.boost,
  });

  bool get isPlayerCard => cardType == 'player';
  bool get isSynergyCard => cardType == 'synergy';

  factory UserCard.fromJson(Map<String, dynamic> json) {
    // Parse stats if present
    List<CardStat>? stats;
    if (json['stats'] != null) {
      stats = (json['stats'] as List<dynamic>)
          .map((e) => CardStat.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse boost if present
    List<SynergyBoost>? boost;
    if (json['boost'] != null) {
      boost = (json['boost'] as List<dynamic>)
          .map((e) => SynergyBoost.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse team if present
    CardTeam? team;
    if (json['team'] != null && json['team'] is Map<String, dynamic>) {
      team = CardTeam.fromJson(json['team'] as Map<String, dynamic>);
    }

    // Handle cardId - can be string or object with nested imageUrl
    String cardId = '';
    String? imageUrl = json['imageUrl'] as String?;

    if (json['cardId'] != null) {
      if (json['cardId'] is String) {
        cardId = json['cardId'] as String;
      } else if (json['cardId'] is Map<String, dynamic>) {
        final cardIdObj = json['cardId'] as Map<String, dynamic>;
        cardId = cardIdObj['_id'] as String? ?? '';
        // If imageUrl is not at root level, get it from cardId object
        imageUrl ??= cardIdObj['imageUrl'] as String?;
      }
    }

    return UserCard(
      id: json['_id'] as String? ?? '',
      odooId: json['odooId'] as String?,
      userId: json['userId'] as String? ?? '',
      cardId: cardId,
      cardType: json['cardType'] as String? ?? '',
      cardName: json['cardName'] as String? ?? '',
      imageUrl: imageUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      position: json['position'] as String?,
      tier: json['tier'] as String?,
      stats: stats,
      base: json['base'] as int?,
      max: json['max'] as int?,
      team: team,
      type: json['type'] as String?,
      boost: boost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'odooId': odooId,
      'userId': userId,
      'cardId': cardId,
      'cardType': cardType,
      'cardName': cardName,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'position': position,
      'tier': tier,
      'stats': stats?.map((e) => e.toJson()).toList(),
      'base': base,
      'max': max,
      'team': team?.toJson(),
      'type': type,
      'boost': boost?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Response model for get all user cards API
class UserCardsResponse {
  final List<UserCard> data;

  const UserCardsResponse({
    required this.data,
  });

  factory UserCardsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return UserCardsResponse(
      data: dataList
          .map((e) => UserCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Response model for rookie draft API
class RookieDraftResponse {
  final String message;
  final List<UserCard> data;

  const RookieDraftResponse({
    required this.message,
    required this.data,
  });

  factory RookieDraftResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return RookieDraftResponse(
      message: json['message'] as String? ?? '',
      data: dataList
          .map((e) => UserCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Exception for rookie draft cooldown
class RookieDraftCooldownException implements Exception {
  final String message;
  final Duration? remainingTime;
  final DateTime? nextAvailableTime;

  RookieDraftCooldownException({
    required this.message,
    this.remainingTime,
    this.nextAvailableTime,
  });

  @override
  String toString() => message;
}

/// Lineup data model
class LineupData {
  final String id;
  final String userId;
  final String lineupType;
  final List<UserCard> playerCards;
  final UserCard? synergyCard;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LineupData({
    required this.id,
    required this.userId,
    required this.lineupType,
    required this.playerCards,
    this.synergyCard,
    this.createdAt,
    this.updatedAt,
  });

  factory LineupData.fromJson(Map<String, dynamic> json) {
    final playerCardsList = json['playerCards'] as List<dynamic>? ?? [];

    // Handle both populated objects and string IDs
    final parsedPlayerCards = <UserCard>[];
    for (final e in playerCardsList) {
      if (e is Map<String, dynamic>) {
        parsedPlayerCards.add(UserCard.fromJson(e));
      } else if (e is String) {
        // API returned just the ID string, create a minimal card
        parsedPlayerCards.add(UserCard(
          id: e,
          userId: '',
          cardId: e,
          cardType: 'player',
          cardName: '',
        ));
      }
    }

    // Handle synergyCard as either populated object or string ID
    UserCard? synergyCard;
    if (json['synergyCard'] != null) {
      if (json['synergyCard'] is Map<String, dynamic>) {
        synergyCard = UserCard.fromJson(json['synergyCard'] as Map<String, dynamic>);
      } else if (json['synergyCard'] is String) {
        final sid = json['synergyCard'] as String;
        synergyCard = UserCard(
          id: sid,
          userId: '',
          cardId: sid,
          cardType: 'synergy',
          cardName: '',
        );
      }
    }

    return LineupData(
      id: json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      lineupType: json['lineupType'] as String? ?? '',
      playerCards: parsedPlayerCards,
      synergyCard: synergyCard,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'lineupType': lineupType,
      'playerCards': playerCards.map((e) => e.toJson()).toList(),
      'synergyCard': synergyCard?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Response model for lineup update APIs
class LineupResponse {
  final String message;
  final LineupData data;

  const LineupResponse({
    required this.message,
    required this.data,
  });

  factory LineupResponse.fromJson(Map<String, dynamic> json) {
    return LineupResponse(
      message: json['message'] as String? ?? '',
      data: LineupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Response model for get attack lineup API
class AttackLineupResponse {
  final LineupData? data;

  const AttackLineupResponse({
    this.data,
  });

  factory AttackLineupResponse.fromJson(Map<String, dynamic> json) {
    return AttackLineupResponse(
      data: json['data'] != null
          ? LineupData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

/// Attack user model - represents a user that can be attacked
class AttackUser {
  final String id;
  final String fullName;
  final String? profilePicture;
  final int? level;
  final int? totalWins;
  final int? totalLosses;

  const AttackUser({
    required this.id,
    required this.fullName,
    this.profilePicture,
    this.level,
    this.totalWins,
    this.totalLosses,
  });

  factory AttackUser.fromJson(Map<String, dynamic> json) {
    return AttackUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? 'Unknown',
      profilePicture: json['profilePicture'] as String?,
      level: json['level'] as int?,
      totalWins: json['totalWins'] as int?,
      totalLosses: json['totalLosses'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'level': level,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
    };
  }
}

/// Response model for get attack users API
class AttackUsersResponse {
  final List<AttackUser> users;

  const AttackUsersResponse({required this.users});

  factory AttackUsersResponse.fromJson(Map<String, dynamic> json) {
    final usersList = json['users'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return AttackUsersResponse(
      users: usersList
          .map((user) => AttackUser.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}

/// Response model for attack initiation API
class AttackResponse {
  final String message;
  final MatchData? data;

  const AttackResponse({
    required this.message,
    this.data,
  });

  factory AttackResponse.fromJson(Map<String, dynamic> json) {
    return AttackResponse(
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? MatchData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Match data returned from attack API
class MatchData {
  final String id;
  final String attackerId;
  final String defenderId;
  final String status;
  final DateTime? preparationDeadline;
  final int attackerScore;
  final int defenderScore;
  final DateTime? createdAt;

  const MatchData({
    required this.id,
    required this.attackerId,
    required this.defenderId,
    required this.status,
    this.preparationDeadline,
    required this.attackerScore,
    required this.defenderScore,
    this.createdAt,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      id: json['_id'] as String? ?? '',
      attackerId: json['attackerId'] as String? ?? '',
      defenderId: json['defenderId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      preparationDeadline: json['preparationDeadline'] != null
          ? DateTime.parse(json['preparationDeadline'] as String)
          : null,
      attackerScore: (json['attackerScore'] as num?)?.toInt() ?? 0,
      defenderScore: (json['defenderScore'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

/// User info in defense match
class MatchUserInfo {
  final String id;
  final String fullName;
  final String email;

  const MatchUserInfo({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory MatchUserInfo.fromJson(Map<String, dynamic> json) {
    return MatchUserInfo(
      id: json['_id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

/// Defense match data with full attacker/defender info
class DefenseMatchData {
  final String id;
  final MatchUserInfo attacker;
  final MatchUserInfo defender;
  final LineupData? attackerLineup;
  final LineupData? defenderLineup;
  final String status;
  final DateTime? preparationDeadline;
  final int attackerScore;
  final int defenderScore;
  final String? winnerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DefenseMatchData({
    required this.id,
    required this.attacker,
    required this.defender,
    this.attackerLineup,
    this.defenderLineup,
    required this.status,
    this.preparationDeadline,
    required this.attackerScore,
    required this.defenderScore,
    this.winnerId,
    this.createdAt,
    this.updatedAt,
  });

  factory DefenseMatchData.fromJson(Map<String, dynamic> json) {
    return DefenseMatchData(
      id: json['_id'] as String? ?? '',
      attacker: MatchUserInfo.fromJson(json['attackerId'] as Map<String, dynamic>),
      defender: MatchUserInfo.fromJson(json['defenderId'] as Map<String, dynamic>),
      attackerLineup: json['attackerLineup'] != null
          ? LineupData.fromJson(json['attackerLineup'] as Map<String, dynamic>)
          : null,
      defenderLineup: json['defenderLineup'] != null
          ? LineupData.fromJson(json['defenderLineup'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? '',
      preparationDeadline: json['preparationDeadline'] != null
          ? DateTime.parse(json['preparationDeadline'] as String)
          : null,
      attackerScore: (json['attackerScore'] as num?)?.toInt() ?? 0,
      defenderScore: (json['defenderScore'] as num?)?.toInt() ?? 0,
      winnerId: json['winnerId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Response model for defense match API
class DefenseMatchResponse {
  final DefenseMatchData? data;

  const DefenseMatchResponse({this.data});

  factory DefenseMatchResponse.fromJson(Map<String, dynamic> json) {
    return DefenseMatchResponse(
      data: json['data'] != null
          ? DefenseMatchData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasActiveMatch => data != null;
}

/// Match history item model
class MatchHistoryItem {
  final String id;
  final MatchUserInfo attacker;
  final MatchUserInfo defender;
  final String status;
  final DateTime? preparationDeadline;
  final int attackerScore;
  final int defenderScore;
  final String? winnerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MatchHistoryItem({
    required this.id,
    required this.attacker,
    required this.defender,
    required this.status,
    this.preparationDeadline,
    required this.attackerScore,
    required this.defenderScore,
    this.winnerId,
    this.createdAt,
    this.updatedAt,
  });

  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return MatchHistoryItem(
      id: json['_id'] as String? ?? '',
      attacker: MatchUserInfo.fromJson(json['attackerId'] as Map<String, dynamic>),
      defender: MatchUserInfo.fromJson(json['defenderId'] as Map<String, dynamic>),
      status: json['status'] as String? ?? '',
      preparationDeadline: json['preparationDeadline'] != null
          ? DateTime.parse(json['preparationDeadline'] as String)
          : null,
      attackerScore: (json['attackerScore'] as num?)?.toInt() ?? 0,
      defenderScore: (json['defenderScore'] as num?)?.toInt() ?? 0,
      winnerId: json['winnerId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Check if current user is the attacker
  bool isAttacker(String currentUserId) => attacker.id == currentUserId;

  /// Check if current user won the match
  bool? didWin(String currentUserId) {
    if (winnerId == null) return null;
    return winnerId == currentUserId;
  }

  /// Get opponent based on current user
  MatchUserInfo getOpponent(String currentUserId) {
    return isAttacker(currentUserId) ? defender : attacker;
  }

  /// Get user's score based on current user
  int getUserScore(String currentUserId) {
    return isAttacker(currentUserId) ? attackerScore : defenderScore;
  }

  /// Get opponent's score based on current user
  int getOpponentScore(String currentUserId) {
    return isAttacker(currentUserId) ? defenderScore : attackerScore;
  }
}

/// Response model for matches history API
class MatchesHistoryResponse {
  final List<MatchHistoryItem> data;

  const MatchesHistoryResponse({required this.data});

  factory MatchesHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return MatchesHistoryResponse(
      data: dataList
          .map((e) => MatchHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
