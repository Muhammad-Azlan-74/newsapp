import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/app/theme/app_colors.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/conference_room_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/features/marketplace/presentation/pages/lineup_selection_screen.dart';
import 'package:newsapp/core/services/match_storage_service.dart';
import 'package:newsapp/features/marketplace/presentation/pages/attack_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/defense_lineup_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/matches_history_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/attack_lineup_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/defense_lineup_selection_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/attack_lineup_view_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/defense_lineup_view_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/match_result_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/conference_room_users_screen.dart';
import 'package:newsapp/core/services/match_result_service.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Conference Room Screen
///
/// Displays the conference room background image with interactive overlays
class ConferenceRoomScreen extends StatefulWidget {
  const ConferenceRoomScreen({super.key});

  @override
  State<ConferenceRoomScreen> createState() => _ConferenceRoomScreenState();
}

class _ConferenceRoomScreenState extends State<ConferenceRoomScreen> {
  bool _isLoadingCards = false;
  bool _showLabels = false;
  final CardRepository _cardRepository = CardRepository(ApiClient());

  /// Timer for auto-hiding labels
  Timer? _labelTimer;

  @override
  void initState() {
    super.initState();
    // Check for pending match results after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingMatchResult();
    });
  }

  @override
  void dispose() {
    _labelTimer?.cancel();
    super.dispose();
  }

  /// Show labels for all overlays for 5 seconds
  void _showLabelsTemporarily() {
    // Cancel any existing timer
    _labelTimer?.cancel();

    // Show labels
    setState(() {
      _showLabels = true;
    });

    // Hide after 5 seconds
    _labelTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showLabels = false;
        });
      }
    });
  }

  /// Handle question icon tap - show labels only
  void _onQuestionTap() {
    _showLabelsTemporarily();
  }

  /// Check if there's a completed match result to show
  Future<void> _checkPendingMatchResult() async {
    final pendingResult = await MatchResultService.getPendingResult();
    if (pendingResult != null && mounted) {
      // Show the result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchResultScreen(
            matchId: pendingResult.matchId,
            opponentName: pendingResult.opponentName,
            isAttacker: pendingResult.isAttacker,
          ),
        ),
      );
    }
  }

  /// Labels for each overlay
  static const Map<String, String> _overlayLabels = {
    'Overlay 4': 'Attack History',
    'Overlay 5': 'Defense History',
    'Overlay 6': 'Attack Lineup',
    'Overlay 7': 'Defense Lineup',
    'Overlay 8': 'Choose Opponent',
  };

  /// Show game rules dialog
  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Game Rules',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          'Parley isn\'t a fight. It\'s a meeting.\n'
                          'Set your cards, defend your office, and strengthen your team.\n\n'
                          'Each manager plays 5 cards for attack or defense.\n'
                          'Cards affect 10 different stats (Power, Route IQ, and more).\n\n'
                          'Each stat is scored individually.\n'
                          'Win the stat. Get the point.\n'
                          'Most points wins the Parley.\n\n'
                          'Choose your cards wisely and pick your opponent.\n'
                          'The winner claims one card from the loser.\n\n'
                          'Three identical player cards merge into the next tier:\n'
                          'Bronze → Silver → Gold → Legend\n\n'
                          'Level up to unlock your real-world Legendary trading card set.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Got it!'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Fetch user cards from API and navigate to cards screen
  Future<void> _fetchAndShowCards() async {
    if (_isLoadingCards) return;

    setState(() {
      _isLoadingCards = true;
    });

    try {
      final cards = await _cardRepository.fetchAndSaveUserCards();

      // Debug: Log the cards received
      debugPrint('ConferenceRoom: Fetched ${cards.length} cards');
      for (final card in cards) {
        debugPrint('  Card: id=${card.id}, type=${card.cardType}, name=${card.cardName}, isPlayer=${card.isPlayerCard}');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LineupSelectionScreen(cards: cards),
        ),
      );
    } on UnauthorizedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view your cards'),
          backgroundColor: AppColors.red,
        ),
      );
    } on NetworkException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: AppColors.red,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cards: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCards = false;
        });
      }
    }
  }

  /// Handle overlay 2 tap - check for active match or navigate to attack
  Future<void> _handleOverlay2Tap() async {
    final match = await MatchStorageService.getActiveMatch();
    if (!mounted) return;

    if (match != null) {
      _showMatchStatusDialog(match);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AttackScreen(),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Show match status dialog with preparation and attack times
  void _showMatchStatusDialog(ActiveMatchInfo match) {
    final remaining = match.preparationDeadline.difference(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  children: [
                    const Icon(
                      Icons.sports_mma,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Active Attack',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'vs ${match.defenderName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Preparation time
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer, color: Colors.orange, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Preparation Time Remaining',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            remaining.inSeconds > 0
                                ? _formatDuration(remaining)
                                : 'Preparation ended',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Attack started time
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, color: Colors.red, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Attack Started',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match.createdAt.toLocal().toString().substring(0, 16),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show attack/defense selection dialog
  void _showAttackDefenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  children: [
                    const Text(
                      'Select Lineup',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Attack Box
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AttackLineupScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.7),
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sports_mma,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'ATTACK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Defense Box
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DefenseLineupSelectionScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.7),
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'DEFENSE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show no attacks dialog
  void _showNoAttacksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  children: [
                    const Icon(
                      Icons.shield,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You\'re Safe!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No one is attacking you',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = ConferenceRoomOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      // Make all overlays invisible but tappable
      final isInvisible = true;

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () {
            if (label == 'Overlay 4') {
              // All and Attack history only
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchesHistoryScreen(
                    allowedFilters: [null, 'attack'],
                  ),
                ),
              );
            } else if (label == 'Overlay 5') {
              // All and Defense history only
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchesHistoryScreen(
                    allowedFilters: [null, 'defense'],
                  ),
                ),
              );
            } else if (label == 'Overlay 6') {
              // Attack Lineup View
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttackLineupViewScreen(),
                ),
              );
            } else if (label == 'Overlay 7') {
              // Defense Lineup View
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefenseLineupViewScreen(),
                ),
              );
            } else if (label == 'Overlay 8') {
              // Attack Users Screen (formerly Match History)
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Use ConferenceRoomUsersScreen which will now list attackable users
                  builder: (context) => const ConferenceRoomUsersScreen(),
                ),
              );
            }
          },
          child: Container(
            decoration: isInvisible
                ? null
                : BoxDecoration(
                    color: Colors.blue.withOpacity(0.3), // Semi-transparent
                    borderRadius: BorderRadius.circular(8),
                  ),
            color: isInvisible ? Colors.transparent : null,
          ),
        ),
      );
    }).toList();
  }

  /// Build a help label widget (same design as mancave labels)
  Widget _buildHelpLabel(String text, {VoidCallback? onTap}) {
    return AnimatedOpacity(
      opacity: _showLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: _showLabels ? onTap : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate label positions for all overlays
    // These should match the values in conference_room_overlay_coordinates.dart
    final overlay4Left = 0.12 * screenWidth;
    final overlay4Top = 0.15 * screenHeight;
    final overlay5Left = 0.75 * screenWidth;
    final overlay5Top = 0.15 * screenHeight;
    final overlay6Left = 0.05 * screenWidth;
    final overlay6Top = 0.48 * screenHeight;
    final overlay7Left = 0.5 * screenWidth;
    final overlay7Top = 0.48 * screenHeight;
    final overlay8Left = 0.25 * screenWidth;
    final overlay8Top = 0.11 * screenHeight;

    return Scaffold(
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: AppAssets.conferenceRoom,
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
          // Info icon - shows labels for 5 seconds
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(
              icon: Icons.info_outline,
              iconColor: _showLabels ? Colors.amber : Colors.black,
              onPressed: _onQuestionTap,
            ),
          ),
          // Eye icon - shows rules
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 10,
            child: GlassyHelpButton(
              icon: Icons.visibility,
              onPressed: _showRulesDialog,
            ),
          ),
          // Labels for all overlays (shown for 5 seconds when help is tapped)
          if (_showLabels) ...[
            // Overlay 4 - Attack History
            Positioned(
              left: overlay4Left,
              top: overlay4Top,
              child: _buildHelpLabel('Attack\nHistory', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchesHistoryScreen(
                      allowedFilters: [null, 'attack'],
                    ),
                  ),
                );
              }),
            ),
            // Overlay 5 - Defense History
            Positioned(
              left: overlay5Left,
              top: overlay5Top,
              child: _buildHelpLabel('Defense\nHistory', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchesHistoryScreen(
                      allowedFilters: [null, 'defense'],
                    ),
                  ),
                );
              }),
            ),
            // Overlay 6 - Attack Lineup
            Positioned(
              left: overlay6Left,
              top: overlay6Top,
              child: _buildHelpLabel('Attack\nLineup', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttackLineupViewScreen(),
                  ),
                );
              }),
            ),
            // Overlay 7 - Defense Lineup
            Positioned(
              left: overlay7Left,
              top: overlay7Top,
              child: _buildHelpLabel('Defense\nLineup', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DefenseLineupViewScreen(),
                  ),
                );
              }),
            ),
            // Overlay 8 - Choose Opponent
            Positioned(
              left: overlay8Left,
              top: overlay8Top,
              child: _buildHelpLabel('Choose\nOpponent', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConferenceRoomUsersScreen(),
                  ),
                );
              }),
            ),
          ],
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

