import 'package:flutter/material.dart';
import 'dart:ui';
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

  /// Labels for each overlay
  static const Map<String, String> _overlayLabels = {
    'Overlay 1': 'Select Lineup',
    'Overlay 2': 'Attack',
    'Overlay 3': 'Defense',
    'Overlay 4': 'History',
  };

  /// Show labels for 5 seconds
  void _showLabelsTemporarily() {
    setState(() {
      _showLabels = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showLabels = false;
        });
      }
    });
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

    // Filter out overlay 5
    final filteredOverlays = overlays.where((o) => o.label != 'Overlay 5').toList();

    return filteredOverlays.map((overlay) {
      final label = overlay.label;
      final displayLabel = _overlayLabels[label] ?? label ?? '';

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () {
            if (label == 'Overlay 1') {
              _showAttackDefenseDialog();
            } else if (label == 'Overlay 2') {
              _handleOverlay2Tap();
            } else if (label == 'Overlay 3') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefenseLineupScreen(),
                ),
              );
            } else if (label == 'Overlay 4') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchesHistoryScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label tapped!')),
              );
            }
          },
          child: AnimatedOpacity(
            opacity: _showLabels ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    displayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          // Help button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(
              onPressed: _showLabelsTemporarily,
            ),
          ),
        ],
      ),
    );
  }
}
