import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing active match data locally
class MatchStorageService {
  static const String _keyMatchId = 'active_match_id';
  static const String _keyDefenderName = 'active_match_defender_name';
  static const String _keyStatus = 'active_match_status';
  static const String _keyPreparationDeadline = 'active_match_prep_deadline';
  static const String _keyCreatedAt = 'active_match_created_at';

  /// Save active match data
  static Future<void> saveMatch({
    required String matchId,
    required String defenderName,
    required String status,
    required DateTime preparationDeadline,
    required DateTime createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMatchId, matchId);
    await prefs.setString(_keyDefenderName, defenderName);
    await prefs.setString(_keyStatus, status);
    await prefs.setString(_keyPreparationDeadline, preparationDeadline.toIso8601String());
    await prefs.setString(_keyCreatedAt, createdAt.toIso8601String());
  }

  /// Check if there's an active match with future preparation deadline
  static Future<bool> hasActiveMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final deadlineStr = prefs.getString(_keyPreparationDeadline);
    if (deadlineStr == null) return false;
    final deadline = DateTime.parse(deadlineStr);
    return deadline.isAfter(DateTime.now());
  }

  /// Get active match data, returns null if no active match
  static Future<ActiveMatchInfo?> getActiveMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final matchId = prefs.getString(_keyMatchId);
    final defenderName = prefs.getString(_keyDefenderName);
    final deadlineStr = prefs.getString(_keyPreparationDeadline);
    final createdAtStr = prefs.getString(_keyCreatedAt);
    final status = prefs.getString(_keyStatus);

    if (matchId == null || deadlineStr == null || createdAtStr == null) {
      return null;
    }

    final deadline = DateTime.parse(deadlineStr);
    // If deadline has passed, match is no longer in preparation
    if (deadline.isBefore(DateTime.now())) {
      return null;
    }

    return ActiveMatchInfo(
      matchId: matchId,
      defenderName: defenderName ?? 'Unknown',
      status: status ?? 'PREPARATION',
      preparationDeadline: deadline,
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  /// Clear active match data
  static Future<void> clearMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMatchId);
    await prefs.remove(_keyDefenderName);
    await prefs.remove(_keyStatus);
    await prefs.remove(_keyPreparationDeadline);
    await prefs.remove(_keyCreatedAt);
  }
}

/// Simple model for active match info
class ActiveMatchInfo {
  final String matchId;
  final String defenderName;
  final String status;
  final DateTime preparationDeadline;
  final DateTime createdAt;

  const ActiveMatchInfo({
    required this.matchId,
    required this.defenderName,
    required this.status,
    required this.preparationDeadline,
    required this.createdAt,
  });
}
