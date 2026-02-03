import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/fantasy_source_model.dart';
import 'package:newsapp/features/user/data/models/sleeper_user_model.dart';
import 'package:newsapp/features/user/data/models/fantasy_league_models.dart';

/// Repository for Fantasy data
class FantasyRepository {
  final ApiClient _apiClient;

  FantasyRepository(this._apiClient);

  /// Get all fantasy sources
  Future<FantasySourcesResponse> getFantasySources() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/sources',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.data is List) {
        return FantasySourcesResponse.fromJson(response.data as List<dynamic>);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Sleeper user by username
  Future<SleeperUser> getSleeperUser(String username) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/user/$username',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return SleeperUser.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all leagues for a user in a specific season
  Future<List<League>> getUserLeagues(String userId, String season) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/user/$userId/leagues/$season',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (response.data as List)
          .map((league) => League.fromJson(league as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information about a specific league
  Future<League> getLeagueDetails(String leagueId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/league/$leagueId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return League.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all rosters in a league with player details
  Future<List<Roster>> getLeagueRosters(String leagueId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/league/$leagueId/rosters',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (response.data as List)
          .map((roster) => Roster.fromJson(roster as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all users participating in a league
  Future<List<LeagueUser>> getLeagueUsers(String leagueId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/league/$leagueId/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (response.data as List)
          .map((user) => LeagueUser.fromJson(user as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all matchups for a specific week in a league
  Future<List<Matchup>> getLeagueMatchups(String leagueId, int week) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/league/$leagueId/matchups/$week',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return (response.data as List)
          .map((matchup) => Matchup.fromJson(matchup as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current state of the NFL season
  Future<NflState> getNflState() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await _apiClient.dio.get(
        '/api/fantasy/nfl/state',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return NflState.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
