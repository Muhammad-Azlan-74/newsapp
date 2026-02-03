import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking match results that need to be shown
class MatchResultService {
  static const String _keyPendingMatchId = 'pending_result_match_id';
  static const String _keyPendingOpponentName = 'pending_result_opponent_name';
  static const String _keyPendingIsAttacker = 'pending_result_is_attacker';
  static const String _keyPendingMatchEndTime = 'pending_result_end_time';

  /// Save a pending match result to show later
  static Future<void> savePendingResult({
    required String matchId,
    required String opponentName,
    required bool isAttacker,
    required DateTime matchEndTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingMatchId, matchId);
    await prefs.setString(_keyPendingOpponentName, opponentName);
    await prefs.setBool(_keyPendingIsAttacker, isAttacker);
    await prefs.setString(_keyPendingMatchEndTime, matchEndTime.toIso8601String());
  }

  /// Check if there's a pending result to show
  static Future<PendingMatchResult?> getPendingResult() async {
    final prefs = await SharedPreferences.getInstance();
    final matchId = prefs.getString(_keyPendingMatchId);
    final opponentName = prefs.getString(_keyPendingOpponentName);
    final isAttacker = prefs.getBool(_keyPendingIsAttacker);
    final endTimeStr = prefs.getString(_keyPendingMatchEndTime);

    if (matchId == null || endTimeStr == null) {
      return null;
    }

    final endTime = DateTime.parse(endTimeStr);

    // Only return if the match has actually ended
    if (endTime.isAfter(DateTime.now())) {
      return null;
    }

    return PendingMatchResult(
      matchId: matchId,
      opponentName: opponentName ?? 'Unknown',
      isAttacker: isAttacker ?? true,
      matchEndTime: endTime,
    );
  }

  /// Clear pending result after it's been shown
  static Future<void> clearPendingResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingMatchId);
    await prefs.remove(_keyPendingOpponentName);
    await prefs.remove(_keyPendingIsAttacker);
    await prefs.remove(_keyPendingMatchEndTime);
  }

  /// Check if we have any pending result (even if not yet ended)
  static Future<bool> hasPendingResult() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPendingMatchId) != null;
  }
}

/// Model for pending match result
class PendingMatchResult {
  final String matchId;
  final String opponentName;
  final bool isAttacker;
  final DateTime matchEndTime;

  const PendingMatchResult({
    required this.matchId,
    required this.opponentName,
    required this.isAttacker,
    required this.matchEndTime,
  });
}
