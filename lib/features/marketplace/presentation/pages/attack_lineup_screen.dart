import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/flippable_game_card.dart';

/// Attack Lineup Screen
///
/// Allows users to select 4 player cards + 1 synergy card for attack
/// Uses attack-available-cards API (cards not in defense lineup)
class AttackLineupScreen extends StatefulWidget {
  const AttackLineupScreen({super.key});

  @override
  State<AttackLineupScreen> createState() => _AttackLineupScreenState();
}

class _AttackLineupScreenState extends State<AttackLineupScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  List<UserCard> _availableCards = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Attack lineup selections
  final List<UserCard> _selectedPlayerCards = [];
  UserCard? _selectedSynergyCard;

  List<UserCard> get _playerCards =>
      _availableCards.where((c) => c.isPlayerCard).toList();

  List<UserCard> get _synergyCards =>
      _availableCards.where((c) => c.isSynergyCard).toList();

  bool get _isLineupComplete =>
      _selectedPlayerCards.length == 4 && _selectedSynergyCard != null;

  /// Calculate total stats from selected player cards + synergy boosts
  Map<String, int> get _totalStats {
    final stats = <String, int>{};

    // Sum stats from all selected player cards
    for (final card in _selectedPlayerCards) {
      if (card.stats != null) {
        for (final stat in card.stats!) {
          stats[stat.statName] = (stats[stat.statName] ?? 0) + stat.statValue;
        }
      }
    }

    // Add synergy card boosts
    if (_selectedSynergyCard != null && _selectedSynergyCard!.boost != null) {
      for (final boost in _selectedSynergyCard!.boost!) {
        stats[boost.stat] = (stats[boost.stat] ?? 0) + boost.value;
      }
    }

    return stats;
  }

  int get _totalPower {
    return _totalStats.values.fold(0, (sum, value) => sum + value);
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableCards();
  }

  Future<void> _loadAvailableCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available cards and existing attack lineup in parallel
      final results = await Future.wait([
        _cardRepository.getAttackAvailableCards(),
        _cardRepository.getAttackLineup(),
      ]);

      final cards = results[0] as List<UserCard>;
      final attackLineup = results[1] as AttackLineupResponse;

      if (!mounted) return;

      setState(() {
        _availableCards = cards;

        // Pre-populate with existing attack lineup if any
        if (attackLineup.data != null) {
          for (final savedCard in attackLineup.data!.playerCards) {
            final match = cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == savedCard.id,
              orElse: () => null,
            );
            if (match != null && !_selectedPlayerCards.contains(match)) {
              _selectedPlayerCards.add(match);
            }
          }
          if (attackLineup.data!.synergyCard != null) {
            _selectedSynergyCard = cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == attackLineup.data!.synergyCard!.id,
              orElse: () => null,
            );
          }
        }

        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _error = 'Please login to view available cards';
        _isLoading = false;
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _error = 'No internet connection';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load cards: $e';
        _isLoading = false;
      });
    }
  }

  bool _isCardIdAlreadySelected(UserCard card) {
    return _selectedPlayerCards.any((c) => c.cardId == card.cardId && c.id != card.id);
  }

  void _togglePlayerCard(UserCard card) {
    final isAlreadySelected = _selectedPlayerCards.contains(card);

    if (isAlreadySelected) {
      setState(() {
        _selectedPlayerCards.remove(card);
      });
      return;
    }

    if (_isCardIdAlreadySelected(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A card of this type is already selected'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedPlayerCards.length >= 4) {
      return;
    }

    setState(() {
      _selectedPlayerCards.add(card);
    });
  }

  void _selectSynergyCard(UserCard card) {
    final isAlreadySelected = _selectedSynergyCard == card;

    if (isAlreadySelected) {
      setState(() {
        _selectedSynergyCard = null;
      });
      return;
    }

    setState(() {
      _selectedSynergyCard = card;
    });
  }

  Future<void> _saveLineup() async {
    if (!_isLineupComplete || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _cardRepository.updateAttackLineup(
        playerCardIds: _selectedPlayerCards.map((c) => c.id).toList(),
        synergyCardId: _selectedSynergyCard!.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attack lineup saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
              'Attack Lineup',
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
          body: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'Loading available cards...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAvailableCards,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_availableCards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No cards available for attack',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusItem(
                            'Players',
                            '${_selectedPlayerCards.length}/4',
                            _selectedPlayerCards.length == 4
                                ? Colors.green
                                : Colors.amber,
                          ),
                          _buildStatusItem(
                            'Synergy',
                            _selectedSynergyCard != null ? '1/1' : '0/1',
                            _selectedSynergyCard != null
                                ? Colors.green
                                : Colors.amber,
                          ),
                          _buildStatusItem(
                            'Total Power',
                            '$_totalPower',
                            Colors.red,
                          ),
                        ],
                      ),
                      if (_totalStats.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.black26),
                        const SizedBox(height: 12),
                        _buildStatsRow(),
                      ],
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
                  selectedCards: _selectedPlayerCards,
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
                  selectedCard: _selectedSynergyCard,
                  onCardTap: _selectSynergyCard,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Bottom save button
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLineupComplete && !_isSaving ? _saveLineup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Attack Lineup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
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

  Widget _buildStatsRow() {
    final stats = _totalStats;
    if (stats.isEmpty) return const SizedBox.shrink();

    // Define stat display info with icons
    final statInfo = {
      'speed': {'icon': Icons.speed, 'color': Colors.blue},
      'agility': {'icon': Icons.directions_run, 'color': Colors.green},
      'power': {'icon': Icons.fitness_center, 'color': Colors.red},
      'stamina': {'icon': Icons.battery_charging_full, 'color': Colors.orange},
      'technique': {'icon': Icons.star, 'color': Colors.purple},
      'defense': {'icon': Icons.shield, 'color': Colors.indigo},
      'attack': {'icon': Icons.sports_mma, 'color': Colors.deepOrange},
    };

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: stats.entries.map((entry) {
        final info = statInfo[entry.key.toLowerCase()] ??
            {'icon': Icons.analytics, 'color': Colors.grey};
        return _buildStatChip(
          entry.key,
          entry.value,
          info['icon'] as IconData,
          info['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildStatChip(String name, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${name[0].toUpperCase()}${name.substring(1)}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
        final isDuplicateCardId = !isSelected && _isCardIdAlreadySelected(card);
        final canSelect = isSelected ||
            ((selectedCards.length < maxSelection) && !isDuplicateCardId);

        return FlippableGameCard(
          card: card,
          isSelected: isSelected,
          canSelect: canSelect,
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

        return FlippableGameCard(
          card: card,
          isSelected: isSelected,
          canSelect: true,
          onTap: () => onCardTap(card),
          selectionIndex: isSelected ? 1 : null,
        );
      },
    );
  }
}
