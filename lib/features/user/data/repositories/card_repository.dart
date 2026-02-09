import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/services/card_storage_service.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';

/// Card Repository
///
/// Handles all card-related API calls and local storage
class CardRepository {
  final ApiClient _apiClient;

  CardRepository(this._apiClient);

  /// Get all user cards from API and save to local storage
  ///
  /// Requires authentication and email verification
  /// Returns the list of user cards and saves them locally
  Future<List<UserCard>> fetchAndSaveUserCards() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      debugPrint('CardRepository.fetchAndSaveUserCards: Fetching cards from server...');

      final response = await _apiClient.dio.get(
        ApiEndpoints.userCards,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('CardRepository.fetchAndSaveUserCards: Raw response: ${response.data}');

      final cardsResponse =
          UserCardsResponse.fromJson(response.data as Map<String, dynamic>);

      debugPrint('CardRepository.fetchAndSaveUserCards: Parsed ${cardsResponse.data.length} cards');
      for (final card in cardsResponse.data) {
        debugPrint('  Server card: id=${card.id}, cardId=${card.cardId}, type=${card.cardType}, name=${card.cardName}');
      }

      // Save cards to local storage
      await CardStorageService.saveCards(cardsResponse.data);

      return cardsResponse.data;
    } on DioException catch (e) {
      debugPrint('CardRepository.fetchAndSaveUserCards: ERROR - ${e.message}');
      debugPrint('CardRepository.fetchAndSaveUserCards: Response - ${e.response?.data}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get user cards - tries local storage first, then API if needed
  ///
  /// [forceRefresh] - If true, always fetches from API
  Future<List<UserCard>> getUserCards({bool forceRefresh = false}) async {
    // If force refresh, fetch from API
    if (forceRefresh) {
      return fetchAndSaveUserCards();
    }

    // Check if we have cards locally and they're not stale
    final hasCards = await CardStorageService.hasCards();
    final needsRefresh = await CardStorageService.needsRefresh();

    if (hasCards && !needsRefresh) {
      // Return from local storage
      return CardStorageService.getCards();
    }

    // Fetch from API and save locally
    return fetchAndSaveUserCards();
  }

  /// Get cards from local storage only (no API call)
  Future<List<UserCard>> getLocalCards() async {
    return CardStorageService.getCards();
  }

  /// Get a specific card by ID from local storage
  Future<UserCard?> getCardById(String cardId) async {
    return CardStorageService.getCardById(cardId);
  }

  /// Get all player cards from local storage
  Future<List<UserCard>> getPlayerCards() async {
    return CardStorageService.getPlayerCards();
  }

  /// Get all synergy cards from local storage
  Future<List<UserCard>> getSynergyCards() async {
    return CardStorageService.getSynergyCards();
  }

  /// Get cards by position from local storage
  Future<List<UserCard>> getCardsByPosition(String position) async {
    return CardStorageService.getCardsByPosition(position);
  }

  /// Get cards by tier from local storage
  Future<List<UserCard>> getCardsByTier(String tier) async {
    return CardStorageService.getCardsByTier(tier);
  }

  /// Clear local card cache
  Future<void> clearCache() async {
    await CardStorageService.clearCards();
  }

  /// Perform rookie draft - get 5 new random cards
  ///
  /// Requires authentication and email verification
  /// Can only be done once every 20 minutes
  /// Returns the drafted cards and saves them locally
  /// Throws RookieDraftCooldownException if on cooldown
  Future<RookieDraftResponse> performRookieDraft() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.rookieDraft,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final draftResponse =
          RookieDraftResponse.fromJson(response.data as Map<String, dynamic>);

      // Save drafted cards to local storage
      await CardStorageService.addCards(draftResponse.data);

      // Note: Draft time is now saved when cards are actually revealed in RookieDraftScreen
      // This prevents cooldown from starting if user leaves without viewing cards

      return draftResponse;
    } on DioException catch (e) {
      _handleRookieDraftDioError(e);
      rethrow;
    }
  }

  /// Check if rookie draft is available
  Future<bool> isRookieDraftAvailable() async {
    return CardStorageService.isRookieDraftAvailable();
  }

  /// Get remaining cooldown time for rookie draft
  Future<Duration?> getRookieDraftCooldown() async {
    return CardStorageService.getRookieDraftCooldownRemaining();
  }

  /// Get next available rookie draft time
  Future<DateTime?> getNextRookieDraftTime() async {
    return CardStorageService.getNextRookieDraftTime();
  }

  /// Update attack lineup
  ///
  /// Requires authentication and email verification
  /// [playerCardIds] - Array of exactly 4 player card IDs
  /// [synergyCardId] - Synergy card ID
  Future<LineupResponse> updateAttackLineup({
    required List<String> playerCardIds,
    required String synergyCardId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      debugPrint('CardRepository.updateAttackLineup: Sending request...');
      debugPrint('CardRepository.updateAttackLineup: playerCards = $playerCardIds');
      debugPrint('CardRepository.updateAttackLineup: synergyCard = $synergyCardId');

      final response = await _apiClient.dio.post(
        ApiEndpoints.updateAttack,
        data: {
          'playerCards': playerCardIds,
          'synergyCard': synergyCardId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('CardRepository.updateAttackLineup: Success! Response: ${response.data}');
      return LineupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('CardRepository.updateAttackLineup: ERROR!');
      debugPrint('CardRepository.updateAttackLineup: Status code: ${e.response?.statusCode}');
      debugPrint('CardRepository.updateAttackLineup: Response data: ${e.response?.data}');
      debugPrint('CardRepository.updateAttackLineup: Error message: ${e.message}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Update defense lineup
  ///
  /// Requires authentication and email verification
  /// [playerCardIds] - Array of exactly 4 player card IDs
  /// [synergyCardId] - Synergy card ID
  Future<LineupResponse> updateDefenseLineup({
    required List<String> playerCardIds,
    required String synergyCardId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      debugPrint('CardRepository.updateDefenseLineup: Sending request...');
      debugPrint('CardRepository.updateDefenseLineup: playerCards = $playerCardIds');
      debugPrint('CardRepository.updateDefenseLineup: synergyCard = $synergyCardId');

      final response = await _apiClient.dio.post(
        ApiEndpoints.updateDefense,
        data: {
          'playerCards': playerCardIds,
          'synergyCard': synergyCardId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('CardRepository.updateDefenseLineup: Success! Response: ${response.data}');
      return LineupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('CardRepository.updateDefenseLineup: ERROR!');
      debugPrint('CardRepository.updateDefenseLineup: Status code: ${e.response?.statusCode}');
      debugPrint('CardRepository.updateDefenseLineup: Response data: ${e.response?.data}');
      debugPrint('CardRepository.updateDefenseLineup: Error message: ${e.message}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get attack lineup
  ///
  /// Requires authentication and email verification
  /// Returns the user's current attack lineup configuration
  Future<AttackLineupResponse> getAttackLineup() async {
    try {
      final token = await AuthStorageService.getToken();
      debugPrint('CardRepository.getAttackLineup: Token ${token != null ? "present" : "NULL"}');
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.attackLineup,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('CardRepository.getAttackLineup: Raw response: ${response.data}');
      return AttackLineupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('CardRepository.getAttackLineup: DioException - ${e.message}');
      debugPrint('CardRepository.getAttackLineup: Response data - ${e.response?.data}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get attack available cards
  ///
  /// Returns cards that are available for attack lineup (not in defense lineup)
  /// Requires authentication and email verification
  Future<List<UserCard>> getAttackAvailableCards() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      debugPrint('CardRepository.getAttackAvailableCards: Fetching cards...');

      final response = await _apiClient.dio.get(
        ApiEndpoints.attackAvailableCards,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('CardRepository.getAttackAvailableCards: Raw response: ${response.data}');

      final cardsResponse =
          UserCardsResponse.fromJson(response.data as Map<String, dynamic>);

      debugPrint('CardRepository.getAttackAvailableCards: Parsed ${cardsResponse.data.length} cards');

      return cardsResponse.data;
    } on DioException catch (e) {
      debugPrint('CardRepository.getAttackAvailableCards: ERROR - ${e.message}');
      debugPrint('CardRepository.getAttackAvailableCards: Response - ${e.response?.data}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get defense available cards
  ///
  /// Returns cards that are available for defense lineup (not in attack lineup)
  /// Requires authentication and email verification
  Future<List<UserCard>> getDefenseAvailableCards() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      debugPrint('CardRepository.getDefenseAvailableCards: Fetching cards...');

      final response = await _apiClient.dio.get(
        ApiEndpoints.defenseAvailableCards,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('CardRepository.getDefenseAvailableCards: Raw response: ${response.data}');

      final cardsResponse =
          UserCardsResponse.fromJson(response.data as Map<String, dynamic>);

      debugPrint('CardRepository.getDefenseAvailableCards: Parsed ${cardsResponse.data.length} cards');

      return cardsResponse.data;
    } on DioException catch (e) {
      debugPrint('CardRepository.getDefenseAvailableCards: ERROR - ${e.message}');
      debugPrint('CardRepository.getDefenseAvailableCards: Response - ${e.response?.data}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get defense lineup
  ///
  /// Requires authentication and email verification
  /// Returns the user's current defense lineup configuration
  Future<AttackLineupResponse> getDefenseLineup() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.defenseLineup,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return AttackLineupResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get all users available for attack
  ///
  /// Requires authentication and email verification
  /// Returns list of users that can be attacked
  Future<AttackUsersResponse> getAttackUsers() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.attackUsers,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return AttackUsersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Initiate attack on a user
  ///
  /// Requires authentication and email verification
  /// [targetUserId] - The ID of the user to attack
  Future<AttackResponse> initiateAttack(String targetUserId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.initiateAttack,
        data: {
          'defenderId': targetUserId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return AttackResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get defense match
  ///
  /// Checks if the user is currently being attacked
  /// Returns the active defense match with PREPARATION status if any
  Future<DefenseMatchResponse> getDefenseMatch() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.defenseMatch,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return DefenseMatchResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // If 404 or no match found, return empty response
      if (e.response?.statusCode == 404) {
        return const DefenseMatchResponse(data: null);
      }
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get matches history
  ///
  /// Returns the user's match history filtered by type
  /// [type] - Optional filter: 'attack', 'defense', or null for all
  Future<MatchesHistoryResponse> getMatchesHistory({String? type}) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.matches,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return MatchesHistoryResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Manually force calculation of match result
  ///
  /// Used when match is in PREPARATION but deadline has passed
  /// [matchId] - ID of the match to calculate
  Future<void> calculateMatchResult(String matchId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.post(
        ApiEndpoints.calculateMatchResult,
        data: {
          'matchId': matchId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get match details with full lineup data
  ///
  /// Returns enriched match data including attacker/defender lineups with cards
  Future<MatchDetailResponse> getMatchDetails(String matchId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.matchDetails(matchId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('=== MATCH DETAIL RAW RESPONSE ===');
      debugPrint('${response.data}');
      debugPrint('=== END MATCH DETAIL ===');

      return MatchDetailResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get opponent lineup for a specific match
  ///
  /// Used by the winner to view available cards before making a selection
  /// [matchId] - The ID of the match
  Future<List<UserCard>> getOpponentLineup(String matchId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.opponentLineup,
        queryParameters: {
          'matchId': matchId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('=== OPPONENT LINEUP RAW RESPONSE ===');
      debugPrint('${response.data}');
      debugPrint('=== END OPPONENT LINEUP ===');

      // Parse the response
      if (response.data != null && response.data['data'] != null) {
        final cardsJson = response.data['data'] as List<dynamic>;
        final cards = cardsJson
            .map((json) => UserCard.fromJson(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('Parsed ${cards.length} opponent cards');
        return cards;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('getOpponentLineup ERROR: ${e.message}');
      debugPrint('getOpponentLineup Response: ${e.response?.data}');
      _handleDioError(e);
      rethrow;
    }
  }

  /// Select a reward card after winning a match
  ///
  /// [matchId] - The ID of the completed match
  /// [cardId] - The ID of the card to claim from the loser's lineup
  Future<Map<String, dynamic>> selectRewardCard({
    required String matchId,
    required String cardId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.selectRewardCard,
        data: {
          'matchId': matchId,
          'cardId': cardId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Handle Dio errors for rookie draft specifically
  void _handleRookieDraftDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException();
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException();
    }

    String errorMessage = 'An error occurred';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response!.statusCode;

      if (e.response!.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] as String? ??
              data['error'] as String? ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        }
      }

      if (statusCode == 401) {
        throw UnauthorizedException();
      } else if (statusCode == 403) {
        // Check if it's a cooldown error
        if (errorMessage.toLowerCase().contains('20 minutes') ||
            errorMessage.toLowerCase().contains('once every') ||
            errorMessage.toLowerCase().contains('cooldown')) {
          throw RookieDraftCooldownException(
            message: errorMessage,
            remainingTime: null,
          );
        }
        throw ApiException(errorMessage, statusCode);
      } else if (statusCode == 404) {
        throw ApiException('Rookie draft not available', statusCode);
      } else if (statusCode == 400) {
        throw ApiException(errorMessage, statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }

  /// Handle Dio errors and convert to custom exceptions
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException();
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException();
    }

    // Extract error message from response
    String errorMessage = 'An error occurred';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response!.statusCode;

      // Try to extract message from response
      if (e.response!.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] as String? ??
              data['error'] as String? ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        }
      }

      // Handle specific status codes
      if (statusCode == 401) {
        throw UnauthorizedException();
      } else if (statusCode == 403) {
        throw ApiException('Email verification required', statusCode);
      } else if (statusCode == 404) {
        throw ApiException('Cards not found', statusCode);
      } else if (statusCode == 400) {
        throw ApiException(errorMessage, statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }
}
