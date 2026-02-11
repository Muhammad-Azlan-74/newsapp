import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/flippable_game_card.dart';

/// Reward Card Selection Screen
///
/// After winning a match, the winner can pick one card from the loser's lineup.
/// Has a countdown timer - if time expires, a random card is auto-awarded server-side.
class RewardCardSelectionScreen extends StatefulWidget {
  final String matchId;
  final String opponentName;
  final DateTime? cardSelectionDeadline;
  final bool isAttacker;

  const RewardCardSelectionScreen({
    super.key,
    required this.matchId,
    required this.opponentName,
    required this.isAttacker,
    this.cardSelectionDeadline,
  });

  @override
  State<RewardCardSelectionScreen> createState() =>
      _RewardCardSelectionScreenState();
}

class _RewardCardSelectionScreenState extends State<RewardCardSelectionScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  bool _isLoading = true;
  String? _error;
  List<UserCard> _opponentCards = [];
  String? _selectedCardId;
  bool _isSubmitting = false;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (widget.cardSelectionDeadline == null) return;

    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (widget.cardSelectionDeadline == null) return;

    final now = DateTime.now();
    final remaining = widget.cardSelectionDeadline!.difference(now);

    if (remaining.isNegative) {
      _countdownTimer?.cancel();
      if (mounted) {
        setState(() => _remainingTime = Duration.zero);
        _showTimeExpiredDialog();
      }
      return;
    }

    if (mounted) {
      setState(() => _remainingTime = remaining);
    }
  }

  void _showTimeExpiredDialog() {
    // Ensure dialog is only shown after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Time Expired',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'The selection period has ended. A random card has been auto-awarded.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(this.context, true); // pop screen with result
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _loadMatchDetails() async {
    try {
      List<UserCard> cards = [];
      
      try {
        // Try the new opponent lineup endpoint first
        cards = await _cardRepository.getOpponentLineup(widget.matchId);
        debugPrint('RewardCardSelection: Using opponent-lineup endpoint');
      } catch (e) {
        debugPrint('RewardCardSelection: opponent-lineup failed, falling back to match-details');
        debugPrint('Error: $e');
        
        // Fallback to getMatchDetails if opponent-lineup endpoint doesn't exist yet
        final matchDetail = await _cardRepository.getMatchDetails(widget.matchId);
        
        debugPrint('RewardCardSelection: isAttacker=${widget.isAttacker}');
        debugPrint('RewardCardSelection: Attacker ID=${matchDetail.attacker.id}');
        debugPrint('RewardCardSelection: Defender ID=${matchDetail.defender.id}');
        
        // IMPORTANT: The winner gets to pick from the LOSER's lineup
        // If we're the attacker, we take from the defender's lineup
        // If we're the defender, we take from the attacker's lineup
        final opponentLineup = widget.isAttacker
            ? matchDetail.defenderLineup  // Attacker takes from defender
            : matchDetail.attackerLineup; // Defender takes from attacker
        cards = opponentLineup?.playerCards ?? [];
        debugPrint('RewardCardSelection: Using match-details fallback');
      }

      debugPrint('RewardCardSelection: Loaded ${cards.length} opponent cards');
      debugPrint('RewardCardSelection: Selected lineup type: ${widget.isAttacker ? "DEFENDER" : "ATTACKER"}');
      for (final c in cards) {
        debugPrint('  Card: id=${c.id}, cardId=${c.cardId}, userId=${c.userId}, name=${c.cardName}, type=${c.cardType}');
      }

      if (mounted) {
        setState(() {
          _opponentCards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load opponent cards: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedCardId == null) return;

    final selectedCard = _opponentCards.firstWhere((c) => c.id == _selectedCardId);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Confirm Selection',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to claim "${selectedCard.cardName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
            ),
            child: const Text('Claim Card',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      await _cardRepository.selectRewardCard(
        matchId: widget.matchId,
        cardId: _selectedCardId!,
      );

      if (!mounted) return;

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You claimed "${selectedCard.cardName}"!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              AppAssets.conferenceRoom,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),
          // Content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                : _error != null
                    ? _buildErrorView()
                    : _buildSelectionView(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      children: [
        // Header with back button and countdown
        _buildHeader(),
        const SizedBox(height: 16),
        // Instruction text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Choose a card from ${widget.opponentName}\'s lineup as your reward',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Cards grid
        Expanded(
          child: _opponentCards.isEmpty
              ? const Center(
                  child: Text(
                    'No cards available',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : _buildCardsGrid(),
        ),
        // Confirm button
        if (_selectedCardId != null) _buildConfirmButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Your Reward',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'vs ${widget.opponentName}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Countdown timer
          if (widget.cardSelectionDeadline != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 1
                    ? Colors.red.withOpacity(0.3)
                    : Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _remainingTime.inMinutes < 1
                      ? Colors.red.withOpacity(0.6)
                      : Colors.amber.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: _remainingTime.inMinutes < 1
                        ? Colors.red
                        : Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_remainingTime),
                    style: TextStyle(
                      color: _remainingTime.inMinutes < 1
                          ? Colors.red
                          : Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _opponentCards.length,
        itemBuilder: (context, index) {
          final card = _opponentCards[index];
          final isSelected = card.id == _selectedCardId;

          return FlippableGameCard(
            card: card,
            isSelected: isSelected,
            canSelect: !_isSubmitting,
            onTap: () {
              setState(() {
                _selectedCardId = isSelected ? null : card.id;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _confirmSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.amber[700]!.withOpacity(0.5),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Claim This Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
