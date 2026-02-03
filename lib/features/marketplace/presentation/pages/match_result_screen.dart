import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/services/match_result_service.dart';
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

  // Stats comparison
  Map<String, int> _userStats = {};
  Map<String, int> _opponentStats = {};
  int _userWins = 0;
  int _opponentWins = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // All 10 stat names
  static const List<String> _allStatNames = [
    'Speed',
    'Agility',
    'Acceleration',
    'Strength',
    'Awareness',
    'Catching',
    'Throwing',
    'Carrying',
    'Tackling',
    'Blocking',
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

      // Calculate stats comparison based on scores
      // The API should have already calculated the scores
      _calculateStatsFromScores(match);

      setState(() {
        _match = match;
        _isLoading = false;
      });

      // Clear the pending result
      await MatchResultService.clearPendingResult();

      // Start animation
      _animationController.forward();
    } catch (e) {
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
    if (_userWins > _opponentWins) {
      return 'VICTORY!';
    } else if (_userWins < _opponentWins) {
      return 'DEFEAT';
    } else {
      return 'DRAW';
    }
  }

  Color get _resultColor {
    if (_userWins > _opponentWins) {
      return Colors.green;
    } else if (_userWins < _opponentWins) {
      return Colors.red;
    } else {
      return Colors.amber;
    }
  }

  IconData get _resultIcon {
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

  Widget _buildContinueButton() {
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
