import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:newsapp/features/user/data/models/card_model.dart';

/// Card Storage Service
///
/// Manages local storage of user cards data
class CardStorageService {
  static const String _keyUserCards = 'user_cards';
  static const String _keyCardsLastFetched = 'cards_last_fetched';
  static const String _keyLastRookieDraft = 'last_rookie_draft';
  static const Duration rookieDraftCooldown = Duration(minutes: 20);

  /// Save all user cards to local storage
  static Future<void> saveCards(List<UserCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = cards.map((card) => card.toJson()).toList();
    await prefs.setString(_keyUserCards, jsonEncode(cardsJson));
    await prefs.setString(_keyCardsLastFetched, DateTime.now().toIso8601String());
  }

  /// Get all saved user cards from local storage
  static Future<List<UserCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsString = prefs.getString(_keyUserCards);
    if (cardsString != null && cardsString.isNotEmpty) {
      final List<dynamic> cardsJson = jsonDecode(cardsString) as List<dynamic>;
      return cardsJson
          .map((e) => UserCard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get a specific card by ID
  static Future<UserCard?> getCardById(String cardId) async {
    final cards = await getCards();
    try {
      return cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  /// Get all player cards
  static Future<List<UserCard>> getPlayerCards() async {
    final cards = await getCards();
    return cards.where((card) => card.isPlayerCard).toList();
  }

  /// Get all synergy cards
  static Future<List<UserCard>> getSynergyCards() async {
    final cards = await getCards();
    return cards.where((card) => card.isSynergyCard).toList();
  }

  /// Get cards by position (for player cards)
  static Future<List<UserCard>> getCardsByPosition(String position) async {
    final cards = await getPlayerCards();
    return cards.where((card) => card.position == position).toList();
  }

  /// Get cards by tier (for player cards)
  static Future<List<UserCard>> getCardsByTier(String tier) async {
    final cards = await getPlayerCards();
    return cards.where((card) => card.tier == tier).toList();
  }

  /// Get cards by type (for synergy cards)
  static Future<List<UserCard>> getCardsByType(String type) async {
    final cards = await getSynergyCards();
    return cards.where((card) => card.type == type).toList();
  }

  /// Get last fetched timestamp
  static Future<DateTime?> getLastFetchedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchedString = prefs.getString(_keyCardsLastFetched);
    if (lastFetchedString != null) {
      return DateTime.tryParse(lastFetchedString);
    }
    return null;
  }

  /// Check if cards need refresh (older than specified duration)
  static Future<bool> needsRefresh({Duration maxAge = const Duration(hours: 1)}) async {
    final lastFetched = await getLastFetchedTime();
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched) > maxAge;
  }

  /// Check if cards exist in local storage
  static Future<bool> hasCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsString = prefs.getString(_keyUserCards);
    return cardsString != null && cardsString.isNotEmpty;
  }

  /// Get card count
  static Future<int> getCardCount() async {
    final cards = await getCards();
    return cards.length;
  }

  /// Clear all saved cards
  static Future<void> clearCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserCards);
    await prefs.remove(_keyCardsLastFetched);
  }

  /// Save a single card (adds or updates)
  static Future<void> saveCard(UserCard card) async {
    final cards = await getCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
    } else {
      cards.add(card);
    }
    await saveCards(cards);
  }

  /// Remove a single card by ID
  static Future<void> removeCard(String cardId) async {
    final cards = await getCards();
    cards.removeWhere((card) => card.id == cardId);
    await saveCards(cards);
  }

  /// Save the last rookie draft time
  static Future<void> saveLastRookieDraftTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRookieDraft, time.toIso8601String());
  }

  /// Get the last rookie draft time
  static Future<DateTime?> getLastRookieDraftTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_keyLastRookieDraft);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// Check if rookie draft is available (20 minutes cooldown)
  static Future<bool> isRookieDraftAvailable() async {
    final lastDraft = await getLastRookieDraftTime();
    if (lastDraft == null) return true;
    return DateTime.now().difference(lastDraft) >= rookieDraftCooldown;
  }

  /// Get remaining time until next rookie draft
  static Future<Duration?> getRookieDraftCooldownRemaining() async {
    final lastDraft = await getLastRookieDraftTime();
    if (lastDraft == null) return null;

    final nextAvailable = lastDraft.add(rookieDraftCooldown);
    final now = DateTime.now();

    if (now.isAfter(nextAvailable)) return null;
    return nextAvailable.difference(now);
  }

  /// Get the next available rookie draft time
  static Future<DateTime?> getNextRookieDraftTime() async {
    final lastDraft = await getLastRookieDraftTime();
    if (lastDraft == null) return null;
    return lastDraft.add(rookieDraftCooldown);
  }

  /// Add new cards to existing collection (for rookie draft)
  static Future<void> addCards(List<UserCard> newCards) async {
    final existingCards = await getCards();
    for (final card in newCards) {
      // Check if card already exists
      final index = existingCards.indexWhere((c) => c.id == card.id);
      if (index == -1) {
        existingCards.add(card);
      } else {
        existingCards[index] = card;
      }
    }
    await saveCards(existingCards);
  }
}
