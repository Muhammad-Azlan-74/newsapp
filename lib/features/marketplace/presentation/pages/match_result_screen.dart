import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/services/match_result_service.dart';
import 'package:newsapp/core/services/match_storage_service.dart';
import 'package:newsapp/features/marketplace/presentation/pages/reward_card_selection_screen.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';

/// Match Result Screen
///
/// Shows the result of a completed parley match
/// Winner is decided by comparing 10 stats; draw if 5-5
class MatchResultScreen extends StatefulWidget {
  final String matchId;
  final String opponentName;
  final bool isAttacker;

  const MatchResultScreen({
    super.key,
    required this.matchId,
    required this.opponentName,
    required this.isAttacker,
  });

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen>
    with SingleTickerProviderStateMixin {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  bool _isLoading = true;
  String? _error;
  MatchHistoryItem? _match;
  String? _currentUserId;

  // Stats comparison
  Map<String, int> _userStats = {};
  Map<String, int> _opponentStats = {};
  int _userWins = 0;
  int _opponentWins = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadMatchResult();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMatchResult() async {
    try {
      // Get current user ID
      final userData = await AuthStorageService.getUserData();
      _currentUserId = userData?['_id'] as String? ?? userData?['id'] as String?;

      // Get match history to find this specific match
      final historyResponse = await _cardRepository.getMatchesHistory();

      // Find the match by ID
      final match = historyResponse.data.cast<MatchHistoryItem?>().firstWhere(
        (m) => m!.id == widget.matchId,
        orElse: () => null,
      );

      if (match == null) {
        setState(() {
          _error = 'Match not found';
          _isLoading = false;
        });
        return;
      }

      // Check if match is actually finished
      if (match.status == 'PREPARATION' || match.status == 'IN_PROGRESS') {
        setState(() {
          _match = match;
          _isLoading = false;
          _error = null;
        });
        return; // Do not clear lock or start animation yet
      }

      // Calculate stats comparison based on scores
      // The API should have already calculated the scores
      _calculateStatsFromScores(match);

      setState(() {
        _match = match;
        _isLoading = false;
      });

      // Clear the pending result and active match ONLY status is final
      await MatchResultService.clearPendingResult();
      await MatchStorageService.clearMatch();

      // Start animation
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load match result: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateStatsFromScores(MatchHistoryItem match) {
    // Use the scores from the API
    if (widget.isAttacker) {
      _userWins = match.attackerScore;
      _opponentWins = match.defenderScore;
    } else {
      _userWins = match.defenderScore;
      _opponentWins = match.attackerScore;
    }
  }

  String get _resultText {
    if (_match?.status == 'PREPARATION' || _match?.status == 'IN_PROGRESS') {
      return 'PROCESSING';
    }
    if (_userWins > _opponentWins) {
      return 'VICTORY!';
    } else if (_userWins < _opponentWins) {
      return 'DEFEAT';
    } else {
      return 'DRAW';
    }
  }

  Color get _resultColor {
    if (_match?.status == 'PREPARATION' || _match?.status == 'IN_PROGRESS') {
      return Colors.blue;
    }
    if (_userWins > _opponentWins) {
      return Colors.green;
    } else if (_userWins < _opponentWins) {
      return Colors.red;
    } else {
      return Colors.amber;
    }
  }

  IconData get _resultIcon {
    if (_match?.status == 'PREPARATION' || _match?.status == 'IN_PROGRESS') {
      return Icons.hourglass_top;
    }
    if (_userWins > _opponentWins) {
      return Icons.emoji_events;
    } else if (_userWins < _opponentWins) {
      return Icons.sentiment_dissatisfied;
    } else {
      return Icons.handshake;
    }
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
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          // Content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _error != null
                    ? _buildErrorView()
                    : _buildResultView(),
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

  Widget _buildResultView() {
    // If processing, show simpler view
    if (_match?.status == 'PREPARATION' || _match?.status == 'IN_PROGRESS') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, color: Colors.blue, size: 80),
            const SizedBox(height: 24),
            const Text(
              'PROCESSING RESULT',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'The match has ended locally, but the server is still calculating the results. Please wait...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Try to force calculation if deadline passed
                if (_match != null && _match!.id.isNotEmpty) {
                  try {
                    await _cardRepository.calculateMatchResult(_match!.id);
                  } catch (e) {
                    debugPrint('Calculation trigger failed (might be too early): $e');
                  }
                }
                // Then reload
                _loadMatchResult();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Check Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Result header
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildResultHeader(),
              ),
              const SizedBox(height: 30),
              // Score display
              _buildScoreDisplay(),
              const SizedBox(height: 30),
              // Match info
              _buildMatchInfo(),
              const Spacer(),
              // Continue button
              _buildContinueButton(),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        // Result icon with glow
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _resultColor.withOpacity(0.3),
                _resultColor.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _resultColor.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Icon(
            _resultIcon,
            size: 80,
            color: _resultColor,
          ),
        ),
        const SizedBox(height: 20),
        // Result text
        Text(
          _resultText,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _resultColor,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: _resultColor.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // User score
          _buildScoreColumn(
            label: 'YOU',
            score: _userWins,
            isWinner: _userWins > _opponentWins,
          ),
          // VS divider
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Opponent score
          _buildScoreColumn(
            label: widget.opponentName.split(' ').first.toUpperCase(),
            score: _opponentWins,
            isWinner: _opponentWins > _userWins,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn({
    required String label,
    required int score,
    required bool isWinner,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isWinner ? _resultColor : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: TextStyle(
            color: isWinner ? _resultColor : Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'stats won',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isAttacker ? Icons.sports_mma : Icons.shield,
                color: widget.isAttacker ? Colors.red : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isAttacker ? 'You attacked' : 'You defended against',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.opponentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_userWins > _opponentWins) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard, color: Colors.amber, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'You won a card!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _isWinner =>
      _match != null &&
      _currentUserId != null &&
      _match!.winnerId == _currentUserId;

  bool get _hasCardSelectionPending =>
      _isWinner && _match!.cardSelectionStatus == 'PENDING';

  bool get _hasCardSelectionDone =>
      _isWinner &&
      (_match!.cardSelectionStatus == 'SELECTED' ||
          _match!.cardSelectionStatus == 'AUTO_AWARDED');

  Widget _buildContinueButton() {
    if (_hasCardSelectionPending) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardCardSelectionScreen(
                        matchId: _match!.id,
                        opponentName: _match!.getOpponent(_currentUserId!).fullName,
                        isAttacker: widget.isAttacker,
                        cardSelectionDeadline: _match!.cardSelectionDeadline,
                      ),
                    ),
                  );
                  if (result == true) {
                    // Reload to update status
                    setState(() => _isLoading = true);
                    _loadMatchResult();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Select Your Reward Card',
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
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      );
    }

    if (_hasCardSelectionDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _match!.cardSelectionStatus == 'SELECTED'
                        ? 'Card claimed!'
                        : 'Card auto-awarded',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _resultColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _resultColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
