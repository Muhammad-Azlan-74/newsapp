/// League Model
class League {
  final int totalRosters;
  final String status;
  final String sport;
  final Map<String, dynamic> settings;
  final String seasonType;
  final String season;
  final Map<String, dynamic> scoringSettings;
  final List<String> rosterPositions;
  final String? previousLeagueId;
  final String name;
  final String leagueId;
  final String draftId;
  final String? avatar;

  League({
    required this.totalRosters,
    required this.status,
    required this.sport,
    required this.settings,
    required this.seasonType,
    required this.season,
    required this.scoringSettings,
    required this.rosterPositions,
    this.previousLeagueId,
    required this.name,
    required this.leagueId,
    required this.draftId,
    this.avatar,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      totalRosters: json['totalRosters'] as int,
      status: json['status'] as String,
      sport: json['sport'] as String,
      settings: json['settings'] as Map<String, dynamic>,
      seasonType: json['seasonType'] as String,
      season: json['season'] as String,
      scoringSettings: json['scoringSettings'] as Map<String, dynamic>,
      rosterPositions: List<String>.from(json['rosterPositions'] as List),
      previousLeagueId: json['previousLeagueId'] as String?,
      name: json['name'] as String,
      leagueId: json['leagueId'] as String,
      draftId: json['draftId'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

/// Player Model
class Player {
  final String status;
  final List<String> fantasyPositions;
  final int number;
  final String team;
  final String playerId;
  final String firstName;
  final String lastName;

  Player({
    required this.status,
    required this.fantasyPositions,
    required this.number,
    required this.team,
    required this.playerId,
    required this.firstName,
    required this.lastName,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      status: json['status'] as String,
      fantasyPositions: List<String>.from(json['fantasyPositions'] as List),
      number: json['number'] as int,
      team: json['team'] as String,
      playerId: json['playerId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  String get fullName => '$firstName $lastName';
}

/// Roster Model
class Roster {
  final List<Player> starters;
  final Map<String, dynamic> settings;
  final List<Player> players;
  final int rosterId;
  final List<Player> reserve;
  final String ownerId;
  final String leagueId;

  Roster({
    required this.starters,
    required this.settings,
    required this.players,
    required this.rosterId,
    required this.reserve,
    required this.ownerId,
    required this.leagueId,
  });

  factory Roster.fromJson(Map<String, dynamic> json) {
    return Roster(
      starters: (json['starters'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>,
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      rosterId: json['rosterId'] as int,
      reserve: (json['reserve'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      ownerId: json['ownerId'] as String,
      leagueId: json['leagueId'] as String,
    );
  }
}

/// League User Model
class LeagueUser {
  final String? avatar;
  final String displayName;
  final bool isBot;
  final bool isOwner;
  final String leagueId;
  final dynamic settings;
  final String userId;

  LeagueUser({
    this.avatar,
    required this.displayName,
    required this.isBot,
    required this.isOwner,
    required this.leagueId,
    this.settings,
    required this.userId,
  });

  factory LeagueUser.fromJson(Map<String, dynamic> json) {
    return LeagueUser(
      avatar: json['avatar'] as String?,
      displayName: json['display_name'] as String,
      isBot: json['is_bot'] as bool,
      isOwner: json['is_owner'] as bool,
      leagueId: json['league_id'] as String,
      settings: json['settings'],
      userId: json['user_id'] as String,
    );
  }
}

/// Matchup Model
class Matchup {
  final double points;
  final List<Player> players;
  final int rosterId;
  final dynamic customPoints;
  final int matchupId;
  final List<Player> starters;
  final List<double> startersPoints;
  final Map<String, double> playersPoints;

  Matchup({
    required this.points,
    required this.players,
    required this.rosterId,
    this.customPoints,
    required this.matchupId,
    required this.starters,
    required this.startersPoints,
    required this.playersPoints,
  });

  factory Matchup.fromJson(Map<String, dynamic> json) {
    return Matchup(
      points: (json['points'] as num).toDouble(),
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      rosterId: json['roster_id'] as int,
      customPoints: json['custom_points'],
      matchupId: json['matchup_id'] as int,
      starters: (json['starters'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      startersPoints: (json['starters_points'] as List)
          .map((p) => (p as num).toDouble())
          .toList(),
      playersPoints: Map<String, double>.from(
        (json['players_points'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
    );
  }
}

/// NFL State Model
class NflState {
  final int week;
  final int leg;
  final String season;
  final String seasonType;
  final String leagueSeason;
  final String previousSeason;
  final String seasonStartDate;
  final int displayWeek;
  final String leagueCreateSeason;
  final bool seasonHasScores;

  NflState({
    required this.week,
    required this.leg,
    required this.season,
    required this.seasonType,
    required this.leagueSeason,
    required this.previousSeason,
    required this.seasonStartDate,
    required this.displayWeek,
    required this.leagueCreateSeason,
    required this.seasonHasScores,
  });

  factory NflState.fromJson(Map<String, dynamic> json) {
    return NflState(
      week: json['week'] as int,
      leg: json['leg'] as int,
      season: json['season'] as String,
      seasonType: json['season_type'] as String,
      leagueSeason: json['league_season'] as String,
      previousSeason: json['previous_season'] as String,
      seasonStartDate: json['season_start_date'] as String,
      displayWeek: json['display_week'] as int,
      leagueCreateSeason: json['league_create_season'] as String,
      seasonHasScores: json['season_has_scores'] as bool,
    );
  }
}
