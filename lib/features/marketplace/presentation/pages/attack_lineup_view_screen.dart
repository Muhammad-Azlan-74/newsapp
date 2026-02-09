import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/match_storage_service.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/flippable_game_card.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Attack Lineup View Screen
///
/// Shows attack lineup with:
/// - Stats display on top (5 stats on each side)
/// - Scrollable cards grid in the middle
/// - 5 selection slots at the bottom (4 players + 1 synergy)
/// - Filter chips for card types
class AttackLineupViewScreen extends StatefulWidget {
  const AttackLineupViewScreen({super.key});

  @override
  State<AttackLineupViewScreen> createState() => _AttackLineupViewScreenState();
}

class _AttackLineupViewScreenState extends State<AttackLineupViewScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  List<UserCard> _availableCards = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Track if lineup was modified
  bool _hasChanges = false;

  // Attack status
  ActiveMatchInfo? _activeMatch;
  Timer? _statusTimer;

  // Selected cards for lineup (4 players + 1 synergy = 5 slots)
  final List<UserCard?> _selectedSlots = List.filled(5, null);

  // Current filter
  String? _currentFilter; // null = all, or QB, RB, WR, TE, K, DEF, SYNERGY

  // All 10 stat names (must match API response)
  static const List<String> _allStatNames = [
    'Accuracy',
    'IQ',
    'Clutch',
    'Speed',
    'Agility',
    'Power',
    'Hands',
    'Route',
    'Blocking',
    'Tackling',
  ];

  // Filter options
  static const List<String> _playerFilters = ['QB', 'RB', 'WR', 'TE', 'K', 'DEF'];

  List<UserCard> get _filteredCards {
    if (_currentFilter == null) {
      return _availableCards;
    }
    if (_currentFilter == 'SYNERGY') {
      return _availableCards.where((c) => c.isSynergyCard).toList();
    }
    return _availableCards
        .where((c) => c.isPlayerCard && c.position?.toUpperCase() == _currentFilter)
        .toList();
  }

  int get _selectedPlayerCount =>
      _selectedSlots.take(4).where((c) => c != null).length;

  UserCard? get _selectedSynergyCard => _selectedSlots[4];

  bool get _isLineupComplete => _selectedPlayerCount == 4 && _selectedSynergyCard != null;

  /// Calculate total stats from selected cards
  Map<String, int> get _totalStats {
    final stats = <String, int>{};

    // Initialize all stats to 0
    for (final statName in _allStatNames) {
      stats[statName] = 0;
    }

    // Sum stats from selected player cards (slots 0-3)
    for (int i = 0; i < 4; i++) {
      final card = _selectedSlots[i];
      if (card != null && card.stats != null) {
        for (final stat in card.stats!) {
          final normalizedName = _normalizeStatName(stat.statName);
          stats[normalizedName] = (stats[normalizedName] ?? 0) + stat.statValue;
        }
      }
    }

    // Add synergy card boosts (slot 4)
    final synergyCard = _selectedSlots[4];
    if (synergyCard != null && synergyCard.boost != null) {
      for (final boost in synergyCard.boost!) {
        final normalizedName = _normalizeStatName(boost.stat);
        stats[normalizedName] = (stats[normalizedName] ?? 0) + boost.value;
      }
    }

    return stats;
  }

  String _normalizeStatName(String name) {
    // Capitalize first letter
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  int get _totalPower => _totalStats.values.fold(0, (sum, v) => sum + v);

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAttackStatus();
    // Update status every second for countdown
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAttackStatus() async {
    final match = await MatchStorageService.getActiveMatch();
    if (mounted) {
      setState(() {
        _activeMatch = match;
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Ended';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _loadData() async {
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
          int slotIndex = 0;
          for (final savedCard in attackLineup.data!.playerCards) {
            if (slotIndex >= 4) break;
            final match = cards.cast<UserCard?>().firstWhere(
              (c) => c!.id == savedCard.id,
              orElse: () => null,
            );
            if (match != null) {
              _selectedSlots[slotIndex] = match;
              slotIndex++;
            }
          }
          if (attackLineup.data!.synergyCard != null) {
            _selectedSlots[4] = cards.cast<UserCard?>().firstWhere(
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

  bool _isCardSelected(UserCard card) {
    return _selectedSlots.any((c) => c?.id == card.id);
  }

  bool _isCardIdAlreadySelected(UserCard card) {
    return _selectedSlots
        .take(4)
        .any((c) => c != null && c.cardId == card.cardId && c.id != card.id);
  }

  void _onCardTap(UserCard card) {
    // If already selected, remove it
    final existingIndex = _selectedSlots.indexWhere((c) => c?.id == card.id);
    if (existingIndex != -1) {
      setState(() {
        _selectedSlots[existingIndex] = null;
        _hasChanges = true;
      });
      return;
    }

    // Check if it's a synergy card
    if (card.isSynergyCard) {
      setState(() {
        _selectedSlots[4] = card;
        _hasChanges = true;
      });
      return;
    }

    // It's a player card
    // Check for duplicate cardId
    if (_isCardIdAlreadySelected(card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A card of this player is already selected'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Find first empty player slot (0-3)
    final emptyIndex = _selectedSlots.take(4).toList().indexWhere((c) => c == null);
    if (emptyIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All player slots are filled. Tap a slot to remove.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedSlots[emptyIndex] = card;
      _hasChanges = true;
    });
  }

  void _onSlotTap(int index) {
    if (_selectedSlots[index] != null) {
      setState(() {
        _selectedSlots[index] = null;
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    // If lineup is complete and has changes, auto-save
    if (_isLineupComplete && _hasChanges) {
      await _saveLineup(showMessage: true);
      return true;
    }

    // If lineup is incomplete, show warning
    if (_hasChanges && !_isLineupComplete) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Incomplete Lineup',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Your attack lineup is incomplete (${_selectedPlayerCount}/4 players, ${_selectedSynergyCard != null ? "1" : "0"}/1 synergy). Changes will not be saved.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave Anyway', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }

    return true;
  }

  Future<void> _saveLineup({bool showMessage = false}) async {
    if (!_isLineupComplete || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _cardRepository.updateAttackLineup(
        playerCardIds: _selectedSlots.take(4).map((c) => c!.id).toList(),
        synergyCardId: _selectedSlots[4]!.id,
      );

      _hasChanges = false;

      if (!mounted) return;

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attack lineup saved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
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

  Future<void> _handleBackPress() async {
    final canPop = await _onWillPop();
    if (canPop && mounted) {
      Navigator.pop(context);
    }
  }

  void _showStatsInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Card Stats Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Each card has 10 stats that determine the outcome of a Parley:\n\n'
                    'Accuracy • IQ • Clutch • Speed • Agility\n'
                    'Power • Hands • Route • Blocking • Tackling\n\n'
                    'Select 4 player cards + 1 synergy card.\n'
                    'Each stat is compared individually.\n'
                    'Win the stat, get the point.\n'
                    'Most points wins the Parley.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Got it!'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              AppAssets.conferenceRoom,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // Main content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GlassyBackButton(onPressed: _handleBackPress),
              ),
              title: const Text(
                'Attack Lineup',
                style: TextStyle(
                  color: Colors.white,
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
      ),
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
              'Loading cards...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Attack status strip
        _buildStatusStrip(),
        const SizedBox(height: 8),
        // Top Stats Container with stats on sides
        _buildStatsContainer(),
        const SizedBox(height: 8),
        // Filter chips
        _buildFilterChips(),
        const SizedBox(height: 8),
        // Scrollable cards grid
        Expanded(
          child: _buildCardsGrid(),
        ),
        // Bottom: 5 selection slots
        _buildSelectionSlots(),
      ],
    );
  }

  Widget _buildStatusStrip() {
    final hasActiveAttack = _activeMatch != null;
    final remaining = hasActiveAttack
        ? _activeMatch!.preparationDeadline.difference(DateTime.now())
        : Duration.zero;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasActiveAttack
              ? [Colors.red.withOpacity(0.3), Colors.orange.withOpacity(0.3)]
              : [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasActiveAttack
              ? Colors.red.withOpacity(0.5)
              : Colors.green.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasActiveAttack ? Icons.sports_mma : Icons.check_circle_outline,
            color: hasActiveAttack ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasActiveAttack
                  ? 'Attacking ${_activeMatch!.defenderName}'
                  : 'Not attacking anyone',
              style: TextStyle(
                color: hasActiveAttack ? Colors.red[100] : Colors.green[100],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasActiveAttack && !remaining.isNegative)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatDuration(remaining),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsContainer() {
    final stats = _totalStats;
    final leftStats = _allStatNames.take(5).toList();
    final rightStats = _allStatNames.skip(5).take(5).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Left stats column
          Expanded(
            child: Column(
              children: leftStats.map((name) {
                return _buildStatRow(name, stats[name] ?? 0);
              }).toList(),
            ),
          ),
          // Center: Total Power
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withOpacity(0.3), Colors.orange.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                const Text(
                  'POWER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalPower',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_selectedPlayerCount}/4 + ${_selectedSynergyCard != null ? "1" : "0"}/1',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Right stats column
          Expanded(
            child: Column(
              children: rightStats.map((name) {
                return _buildStatRow(name, stats[name] ?? 0, alignRight: true);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String name, int value, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: alignRight
            ? [
                Text(
                  '$value',
                  style: TextStyle(
                    color: value > 0 ? Colors.greenAccent : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ]
            : [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$value',
                  style: TextStyle(
                    color: value > 0 ? Colors.greenAccent : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // All filter
          _buildFilterChip('ALL', null),
          const SizedBox(width: 6),
          // Player position filters
          ..._playerFilters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildFilterChip(filter, filter),
            );
          }),
          // Synergy filter
          _buildFilterChip('SYNERGY', 'SYNERGY'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _currentFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsGrid() {
    final cards = _filteredCards;

    if (cards.isEmpty) {
      return Center(
        child: Text(
          _currentFilter == null
              ? 'No cards available'
              : 'No ${_currentFilter} cards available',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = _isCardSelected(card);
        final isDuplicate = !isSelected && _isCardIdAlreadySelected(card);

        return _buildCardItem(card, isSelected, isDuplicate);
      },
    );
  }

  Widget _buildCardItem(UserCard card, bool isSelected, bool isDuplicate) {
    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: isSelected ? 2 : 0,
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
            // Card image
            ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 6 : 8),
              child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildCardPlaceholder(card),
                    )
                  : _buildCardPlaceholder(card),
            ),
            // Info button (top right) - shows large card overlay
            if (!isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => showLargeCardOverlay(context, card),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            // Selection checkmark
            if (isSelected)
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
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            // Duplicate overlay
            if (isDuplicate)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, color: Colors.amber, size: 20),
                        SizedBox(height: 2),
                        Text(
                          'SAME',
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
            // Position/Type badge
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.isSynergyCard ? 'SYN' : (card.position ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder(UserCard card) {
    return Container(
      color: card.isSynergyCard ? Colors.purple[900] : Colors.grey[800],
      child: Center(
        child: Icon(
          card.isSynergyCard ? Icons.auto_awesome : Icons.person,
          color: Colors.white38,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSelectionSlots() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'SELECTED LINEUP',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final card = _selectedSlots[index];
              final isSynergySlot = index == 4;
              return _buildSlot(index, card, isSynergySlot);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index, UserCard? card, bool isSynergySlot) {
    return GestureDetector(
      onTap: () => _onSlotTap(index),
      child: Container(
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: card != null
              ? Colors.transparent
              : (isSynergySlot
                  ? Colors.purple.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: card != null
                ? Colors.green
                : (isSynergySlot
                    ? Colors.purple.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3)),
            width: card != null ? 2 : 1,
          ),
        ),
        child: card != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: card.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : _buildCardPlaceholder(card),
                  ),
                  // Remove icon
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 10),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSynergySlot ? Icons.auto_awesome : Icons.add,
                    color: isSynergySlot
                        ? Colors.purple.withOpacity(0.5)
                        : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSynergySlot ? 'SYN' : 'P${index + 1}',
                    style: TextStyle(
                      color: isSynergySlot
                          ? Colors.purple.withOpacity(0.7)
                          : Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
