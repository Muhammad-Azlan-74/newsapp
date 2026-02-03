import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Lineup Selection Screen
///
/// Allows users to select 4 player cards + 1 synergy card for attack and defense
class LineupSelectionScreen extends StatefulWidget {
  final List<UserCard> cards;

  const LineupSelectionScreen({
    super.key,
    required this.cards,
  });

  @override
  State<LineupSelectionScreen> createState() => _LineupSelectionScreenState();
}

class _LineupSelectionScreenState extends State<LineupSelectionScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  // Toggle state: true = Attack, false = Defense
  bool _isAttackMode = true;

  // Attack lineup selections
  final List<UserCard> _attackPlayerCards = [];
  UserCard? _attackSynergyCard;

  // Defense lineup selections
  final List<UserCard> _defensePlayerCards = [];
  UserCard? _defenseSynergyCard;

  bool _isSaving = false;
  bool _isLoadingLineups = true;

  List<UserCard> get _playerCards =>
      widget.cards.where((c) => c.isPlayerCard).toList();

  List<UserCard> get _synergyCards =>
      widget.cards.where((c) => c.isSynergyCard).toList();

  @override
  void initState() {
    super.initState();
    _loadExistingLineups();
  }

  Future<void> _loadExistingLineups() async {
    try {
      final results = await Future.wait([
        _cardRepository.getAttackLineup(),
        _cardRepository.getDefenseLineup(),
      ]);

      final attackResponse = results[0];
      final defenseResponse = results[1];

      if (!mounted) return;

      setState(() {
        // Pre-populate attack lineup
        if (attackResponse.data != null) {
          for (final savedCard in attackResponse.data!.playerCards) {
            final match = widget.cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == savedCard.id,
              orElse: () => null,
            );
            if (match != null && !_attackPlayerCards.contains(match)) {
              _attackPlayerCards.add(match);
            }
          }
          if (attackResponse.data!.synergyCard != null) {
            _attackSynergyCard = widget.cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == attackResponse.data!.synergyCard!.id,
              orElse: () => null,
            );
          }
        }

        // Pre-populate defense lineup
        if (defenseResponse.data != null) {
          for (final savedCard in defenseResponse.data!.playerCards) {
            final match = widget.cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == savedCard.id,
              orElse: () => null,
            );
            if (match != null && !_defensePlayerCards.contains(match)) {
              _defensePlayerCards.add(match);
            }
          }
          if (defenseResponse.data!.synergyCard != null) {
            _defenseSynergyCard = widget.cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == defenseResponse.data!.synergyCard!.id,
              orElse: () => null,
            );
          }
        }

        _isLoadingLineups = false;
      });
    } catch (e) {
      debugPrint('LineupSelection: Failed to load existing lineups: $e');
      if (mounted) {
        setState(() {
          _isLoadingLineups = false;
        });
      }
    }
  }

  // Current mode getters
  List<UserCard> get _currentPlayerCards =>
      _isAttackMode ? _attackPlayerCards : _defensePlayerCards;

  UserCard? get _currentSynergyCard =>
      _isAttackMode ? _attackSynergyCard : _defenseSynergyCard;

  // Other mode getters (for checking if card is used in other lineup)
  List<UserCard> get _otherPlayerCards =>
      _isAttackMode ? _defensePlayerCards : _attackPlayerCards;

  UserCard? get _otherSynergyCard =>
      _isAttackMode ? _defenseSynergyCard : _attackSynergyCard;

  bool get _isCurrentComplete =>
      _currentPlayerCards.length == 4 && _currentSynergyCard != null;

  // Check if a player card is used in the other lineup (by ID)
  bool _isPlayerCardUsedInOtherLineup(UserCard card) {
    if (_isAttackMode) {
      return _defensePlayerCards.any((c) => c.id == card.id);
    } else {
      return _attackPlayerCards.any((c) => c.id == card.id);
    }
  }

  // Check if a card with the same cardId is already selected in the current lineup
  bool _isCardIdAlreadySelectedInCurrentLineup(UserCard card) {
    final currentCards = _isAttackMode ? _attackPlayerCards : _defensePlayerCards;
    // Check if any selected card has the same cardId (but different instance id)
    return currentCards.any((c) => c.cardId == card.cardId && c.id != card.id);
  }

  // Check if a synergy card is used in the other lineup (by ID)
  bool _isSynergyCardUsedInOtherLineup(UserCard card) {
    if (_isAttackMode) {
      return _defenseSynergyCard != null && _defenseSynergyCard!.id == card.id;
    } else {
      return _attackSynergyCard != null && _attackSynergyCard!.id == card.id;
    }
  }

  void _togglePlayerCard(UserCard card) {
    // Check if this card is already selected in current lineup (allow deselection)
    final isAlreadySelected = _isAttackMode
        ? _attackPlayerCards.contains(card)
        : _defensePlayerCards.contains(card);

    // If already selected, allow deselection regardless of other lineup status
    if (isAlreadySelected) {
      setState(() {
        if (_isAttackMode) {
          _attackPlayerCards.remove(card);
        } else {
          _defensePlayerCards.remove(card);
        }
      });
      return;
    }

    // For new selections, don't allow if card is used in other lineup
    if (_isPlayerCardUsedInOtherLineup(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This card is already used in ${_isAttackMode ? 'Defense' : 'Attack'} lineup',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Don't allow selection if a card with the same cardId is already selected
    if (_isCardIdAlreadySelectedInCurrentLineup(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A card of this type is already selected. Choose a different card type.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Don't allow if max selection reached
    final currentCards = _isAttackMode ? _attackPlayerCards : _defensePlayerCards;
    if (currentCards.length >= 4) {
      return;
    }

    setState(() {
      if (_isAttackMode) {
        _attackPlayerCards.add(card);
      } else {
        _defensePlayerCards.add(card);
      }
    });
  }

  void _selectSynergyCard(UserCard card) {
    // Check if this card is already selected in current lineup (allow deselection)
    final isAlreadySelected = _isAttackMode
        ? _attackSynergyCard == card
        : _defenseSynergyCard == card;

    // If already selected, allow deselection regardless of other lineup status
    if (isAlreadySelected) {
      setState(() {
        if (_isAttackMode) {
          _attackSynergyCard = null;
        } else {
          _defenseSynergyCard = null;
        }
      });
      return;
    }

    // For new selections, don't allow if card is used in other lineup
    if (_isSynergyCardUsedInOtherLineup(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This card is already used in ${_isAttackMode ? 'Defense' : 'Attack'} lineup',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (_isAttackMode) {
        _attackSynergyCard = card;
      } else {
        _defenseSynergyCard = card;
      }
    });
  }

  Future<void> _saveLineup() async {
    if (!_isCurrentComplete || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isAttackMode) {
        // Debug: Log selected cards
        debugPrint('LineupSelection: Saving ATTACK lineup');
        for (final card in _attackPlayerCards) {
          debugPrint('  Player card: id=${card.id}, cardId=${card.cardId}, type=${card.cardType}, isPlayer=${card.isPlayerCard}');
        }
        debugPrint('  Synergy card: id=${_attackSynergyCard!.id}, cardId=${_attackSynergyCard!.cardId}, type=${_attackSynergyCard!.cardType}, isSynergy=${_attackSynergyCard!.isSynergyCard}');

        await _cardRepository.updateAttackLineup(
          playerCardIds: _attackPlayerCards.map((c) => c.id).toList(),
          synergyCardId: _attackSynergyCard!.id,
        );
      } else {
        // Debug: Log selected cards
        debugPrint('LineupSelection: Saving DEFENSE lineup');
        for (final card in _defensePlayerCards) {
          debugPrint('  Player card: id=${card.id}, cardId=${card.cardId}, type=${card.cardType}, isPlayer=${card.isPlayerCard}');
        }
        debugPrint('  Synergy card: id=${_defenseSynergyCard!.id}, cardId=${_defenseSynergyCard!.cardId}, type=${_defenseSynergyCard!.cardType}, isSynergy=${_defenseSynergyCard!.isSynergyCard}');

        await _cardRepository.updateDefenseLineup(
          playerCardIds: _defensePlayerCards.map((c) => c.id).toList(),
          synergyCardId: _defenseSynergyCard!.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_isAttackMode ? 'Attack' : 'Defense'} lineup saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on UnauthorizedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to save lineup'),
          backgroundColor: Colors.red,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save lineup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            AppAssets.conferenceRoom,
            fit: BoxFit.cover,
          ),
        ),
        // White overlay
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        // Scaffold with content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: GlassyBackButton(),
            ),
            title: const Text(
              'Select Lineup',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: GlassyHelpButton(),
              ),
            ],
          ),
          body: _isLoadingLineups
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading existing lineups...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
            children: [
              // Card selection area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusItem(
                              'Players',
                              '${_currentPlayerCards.length}/4',
                              _currentPlayerCards.length == 4
                                  ? Colors.green
                                  : Colors.amber,
                            ),
                            _buildStatusItem(
                              'Synergy',
                              _currentSynergyCard != null ? '1/1' : '0/1',
                              _currentSynergyCard != null
                                  ? Colors.green
                                  : Colors.amber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Player Cards Section
                      const Text(
                        'Select 4 Player Cards',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCardGrid(
                        cards: _playerCards,
                        selectedCards: _currentPlayerCards,
                        onCardTap: _togglePlayerCard,
                        maxSelection: 4,
                      ),
                      const SizedBox(height: 24),

                      // Synergy Cards Section
                      const Text(
                        'Select 1 Synergy Card',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSynergyCardGrid(
                        cards: _synergyCards,
                        selectedCard: _currentSynergyCard,
                        onCardTap: _selectSynergyCard,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom section with toggle and save button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Attack/Defense Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAttackMode = true;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isAttackMode
                                        ? Colors.red
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sports_mma,
                                        color: _isAttackMode
                                            ? Colors.white
                                            : Colors.white54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ATTACK',
                                        style: TextStyle(
                                          color: _isAttackMode
                                              ? Colors.white
                                              : Colors.white54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAttackMode = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isAttackMode
                                        ? Colors.blue
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield,
                                        color: !_isAttackMode
                                            ? Colors.white
                                            : Colors.white54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'DEFENSE',
                                        style: TextStyle(
                                          color: !_isAttackMode
                                              ? Colors.white
                                              : Colors.white54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCurrentComplete && !_isSaving
                              ? _saveLineup
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isAttackMode ? Colors.red : Colors.blue,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Save ${_isAttackMode ? 'Attack' : 'Defense'} Lineup',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Top stats strip
        const TopStatsStrip(),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid({
    required List<UserCard> cards,
    required List<UserCard> selectedCards,
    required Function(UserCard) onCardTap,
    required int maxSelection,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = selectedCards.contains(card);
        final isUsedInOtherLineup = _isPlayerCardUsedInOtherLineup(card);
        final isDuplicateCardId = !isSelected && _isCardIdAlreadySelectedInCurrentLineup(card);
        // Allow tap if: already selected (for deselection) OR can be newly selected
        final canSelect = isSelected ||
                          ((selectedCards.length < maxSelection) &&
                           !isUsedInOtherLineup &&
                           !isDuplicateCardId);

        return _buildSelectableCard(
          card: card,
          isSelected: isSelected,
          canSelect: canSelect,
          isUsedInOtherLineup: isUsedInOtherLineup && !isSelected,
          isDuplicateCardId: isDuplicateCardId,
          onTap: () => onCardTap(card),
          selectionIndex: isSelected ? selectedCards.indexOf(card) + 1 : null,
        );
      },
    );
  }

  Widget _buildSynergyCardGrid({
    required List<UserCard> cards,
    required UserCard? selectedCard,
    required Function(UserCard) onCardTap,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = selectedCard == card;
        final isUsedInOtherLineup = _isSynergyCardUsedInOtherLineup(card);
        // Allow tap if: already selected (for deselection) OR not used in other lineup
        final canSelect = isSelected || !isUsedInOtherLineup;

        return _buildSelectableCard(
          card: card,
          isSelected: isSelected,
          canSelect: canSelect,
          isUsedInOtherLineup: isUsedInOtherLineup && !isSelected,
          onTap: () => onCardTap(card),
          selectionIndex: isSelected ? 1 : null,
        );
      },
    );
  }

  Widget _buildSelectableCard({
    required UserCard card,
    required bool isSelected,
    required bool canSelect,
    required VoidCallback onTap,
    bool isUsedInOtherLineup = false,
    bool isDuplicateCardId = false,
    int? selectionIndex,
  }) {
    final tierColor = _getTierColor(card.tier);

    return GestureDetector(
      onTap: canSelect ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUsedInOtherLineup
                ? (_isAttackMode ? Colors.blue : Colors.red)
                : (isSelected ? Colors.green : tierColor.withOpacity(0.5)),
            width: isSelected || isUsedInOtherLineup ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Card content
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tierColor.withOpacity(0.3),
                      const Color(0xFF2D2D44),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card image
                    Expanded(
                      flex: 3,
                      child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: card.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: Icon(
                                card.isPlayerCard
                                    ? Icons.person
                                    : Icons.auto_awesome,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                    ),
                    // Card info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              card.cardName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (card.tier != null || card.type != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: tierColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  (card.tier ?? card.type ?? '').toUpperCase(),
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Selection overlay for cards that can't be selected (max reached)
            if (!canSelect && !isSelected && !isUsedInOtherLineup && !isDuplicateCardId)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            // Overlay for cards with duplicate cardId (same card type already selected)
            if (isDuplicateCardId)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'SAME TYPE',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Overlay for cards used in other lineup
            if (isUsedInOtherLineup)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isAttackMode ? Icons.shield : Icons.sports_mma,
                          color: _isAttackMode ? Colors.blue : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isAttackMode ? 'DEF' : 'ATK',
                          style: TextStyle(
                            color: _isAttackMode ? Colors.blue : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Selection badge
            if (isSelected && selectionIndex != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      selectionIndex.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.purple;
    }
  }
}

