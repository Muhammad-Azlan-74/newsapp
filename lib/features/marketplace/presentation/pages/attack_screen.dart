import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/match_storage_service.dart';
import 'package:newsapp/core/services/match_result_service.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Attack Screen
///
/// Multi-step flow for attacking other users:
/// 1. Show attack lineup cards (saved cards for attack)
/// 2. When user clicks "Next", show all users from Hall of Fame
/// 3. When user clicks on a user, initiate attack
class AttackScreen extends StatefulWidget {
  const AttackScreen({super.key});

  @override
  State<AttackScreen> createState() => _AttackScreenState();
}

enum AttackScreenState {
  loadingLineup,
  showingLineup,
  loadingUsers,
  showingUsers,
  attacking,
  showingResult,
  error,
}

class _AttackScreenState extends State<AttackScreen>
    with TickerProviderStateMixin {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  AttackScreenState _screenState = AttackScreenState.loadingLineup;
  String? _errorMessage;

  List<AttackUser> _users = [];
  AttackUser? _selectedUser;
  LineupData? _attackLineup;
  MatchData? _matchData;

  // Flip animation controllers keyed by card id
  final Map<String, AnimationController> _flipControllers = {};

  @override
  void initState() {
    super.initState();
    _loadAttackLineup();
  }

  @override
  void dispose() {
    for (final controller in _flipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getFlipController(String cardId) {
    return _flipControllers.putIfAbsent(
      cardId,
      () => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _toggleFlip(String cardId) {
    final controller = _getFlipController(cardId);
    if (controller.isCompleted) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  Future<void> _loadAttackLineup() async {
    setState(() {
      _screenState = AttackScreenState.loadingLineup;
      _errorMessage = null;
    });

    try {
      debugPrint('AttackScreen: Fetching attack lineup...');
      final response = await _cardRepository.getAttackLineup();
      debugPrint('AttackScreen: Response received - data is ${response.data == null ? "NULL" : "present"}');
      if (response.data != null) {
        debugPrint('AttackScreen: playerCards count: ${response.data!.playerCards.length}');
        debugPrint('AttackScreen: synergyCard: ${response.data!.synergyCard != null ? "present" : "null"}');
      }
      if (!mounted) return;

      if (response.data == null || response.data!.playerCards.isEmpty) {
        setState(() {
          _screenState = AttackScreenState.error;
          _errorMessage = 'You need to set up your attack lineup first. Go to Conference Room Overlay 1 to configure your lineup.';
        });
        return;
      }

      setState(() {
        _attackLineup = response.data;
        _screenState = AttackScreenState.showingLineup;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Please login to view attack lineup';
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'No internet connection';
      });
    } on ApiException catch (e) {
      debugPrint('AttackScreen: ApiException - ${e.message} (code: ${e.statusCode})');
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = '${e.message} (code: ${e.statusCode})';
      });
    } catch (e, stackTrace) {
      debugPrint('AttackScreen: Unexpected error: $e');
      debugPrint('AttackScreen: Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Failed to load attack lineup: $e';
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _screenState = AttackScreenState.loadingUsers;
      _errorMessage = null;
    });

    try {
      final response = await _cardRepository.getAttackUsers();
      if (!mounted) return;

      setState(() {
        _users = response.users;
        _screenState = AttackScreenState.showingUsers;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Please login to view users';
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'No internet connection';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Failed to load users: $e';
      });
    }
  }

  Future<void> _initiateAttack(AttackUser user) async {
    setState(() {
      _selectedUser = user;
      _screenState = AttackScreenState.attacking;
      _errorMessage = null;
    });

    try {
      final response = await _cardRepository.initiateAttack(user.id);
      if (!mounted) return;

      // Save match data locally
      if (response.data != null) {
        final deadline = response.data!.preparationDeadline ?? DateTime.now().add(const Duration(hours: 60));

        await MatchStorageService.saveMatch(
          matchId: response.data!.id,
          defenderName: user.fullName,
          status: response.data!.status,
          preparationDeadline: deadline,
          createdAt: response.data!.createdAt ?? DateTime.now(),
        );

        // Save pending result for showing when match ends
        await MatchResultService.savePendingResult(
          matchId: response.data!.id,
          opponentName: user.fullName,
          isAttacker: true,
          matchEndTime: deadline,
        );
      }

      if (!mounted) return;
      setState(() {
        _matchData = response.data;
        _screenState = AttackScreenState.showingResult;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Please login to attack';
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'No internet connection';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = AttackScreenState.error;
        _errorMessage = 'Failed to attack: $e';
      });
    }
  }

  void _goBackToLineup() {
    setState(() {
      _selectedUser = null;
      _matchData = null;
      _screenState = AttackScreenState.showingLineup;
    });
  }

  void _goBackToUsers() {
    setState(() {
      _selectedUser = null;
      _matchData = null;
      _screenState = AttackScreenState.showingUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image - Conference Room
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
        // Scaffold with content
        Positioned.fill(
          child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassyBackButton(
                onPressed: () {
                  if (_screenState == AttackScreenState.showingUsers) {
                    _goBackToLineup();
                  } else if (_screenState == AttackScreenState.showingResult) {
                    _goBackToUsers();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            title: Text(
              _getAppBarTitle(),
              style: const TextStyle(
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
        ),
        // Top stats strip
        const TopStatsStrip(),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (_screenState) {
      case AttackScreenState.loadingLineup:
      case AttackScreenState.showingLineup:
        return 'Your Attack Lineup';
      case AttackScreenState.loadingUsers:
      case AttackScreenState.showingUsers:
        return 'Select Opponent';
      case AttackScreenState.attacking:
        return 'Attacking...';
      case AttackScreenState.showingResult:
        return 'Attack Started';
      case AttackScreenState.error:
        return 'Attack';
    }
  }

  Widget _buildBody() {
    switch (_screenState) {
      case AttackScreenState.loadingLineup:
      case AttackScreenState.loadingUsers:
      case AttackScreenState.attacking:
        return _buildLoadingState();
      case AttackScreenState.showingLineup:
        return _buildLineupView();
      case AttackScreenState.showingUsers:
        return _buildUsersList();
      case AttackScreenState.showingResult:
        return _buildResultView();
      case AttackScreenState.error:
        return _buildErrorState();
    }
  }

  Widget _buildLoadingState() {
    String message;
    switch (_screenState) {
      case AttackScreenState.loadingLineup:
        message = 'Loading attack lineup...';
        break;
      case AttackScreenState.loadingUsers:
        message = 'Loading opponents...';
        break;
      case AttackScreenState.attacking:
        message = 'Attacking ${_selectedUser?.fullName ?? "opponent"}...';
        break;
      default:
        message = 'Loading...';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _errorMessage ?? 'An error occurred',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_attackLineup != null) {
                  _goBackToLineup();
                } else {
                  _loadAttackLineup();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                _attackLineup != null ? 'Go Back' : 'Retry',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineupView() {
    if (_attackLineup == null) {
      return const Center(
        child: Text(
          'No lineup configured',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'These are your selected cards for attack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Player cards
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player cards grid
                const Text(
                  'Player Cards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _attackLineup!.playerCards.length,
                  itemBuilder: (context, index) {
                    return _buildLineupCard(_attackLineup!.playerCards[index]);
                  },
                ),
                const SizedBox(height: 24),

                // Synergy card
                if (_attackLineup!.synergyCard != null) ...[
                  const Text(
                    'Synergy Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 150,
                    height: 214,
                    child: _buildLineupCard(_attackLineup!.synergyCard!),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Next button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NEXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineupCard(UserCard card) {
    final tierColor = _getTierColor(card.tier);
    final controller = _getFlipController(card.id);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final angle = controller.value * math.pi;
        final showBack = angle > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _buildCardBack(card, tierColor),
                )
              : _buildCardFront(card, tierColor),
        );
      },
    );
  }

  Widget _buildCardFront(UserCard card, Color tierColor) {
    final displayName = card.cardName.isNotEmpty
        ? card.cardName
        : (card.position ?? card.cardType.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full card image
            if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: card.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildCardPlaceholder(card, tierColor),
              )
            else
              _buildCardPlaceholder(card, tierColor),

            // Bottom gradient with name
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Info icon button
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _toggleFlip(card.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(UserCard card, Color tierColor) {
    final displayName = card.cardName.isNotEmpty
        ? card.cardName
        : (card.position ?? card.cardType.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tierColor.withOpacity(0.25),
                const Color(0xFF1A1A2E),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Card details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 36, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Position & Tier row
                      Row(
                        children: [
                          if (card.position != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                card.position!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (card.position != null) const SizedBox(width: 6),
                          if (card.tier != null || card.type != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (card.tier ?? card.type ?? '').toUpperCase(),
                                style: TextStyle(
                                  color: tierColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Team
                      if (card.team != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.shield, color: Colors.white54, size: 12),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  card.team!.name,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Base / Max
                      if (card.base != null || card.max != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              if (card.base != null)
                                _buildStatChip('Base', '${card.base}', Colors.blue),
                              if (card.base != null && card.max != null)
                                const SizedBox(width: 8),
                              if (card.max != null)
                                _buildStatChip('Max', '${card.max}', Colors.green),
                            ],
                          ),
                        ),

                      // Stats (player cards)
                      if (card.stats != null && card.stats!.isNotEmpty) ...[
                        const Text(
                          'STATS',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...card.stats!.map(
                          (stat) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stat.statName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${stat.statValue}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Boost (synergy cards)
                      if (card.boost != null && card.boost!.isNotEmpty) ...[
                        const Text(
                          'BOOST',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...card.boost!.map(
                          (boost) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  boost.stat,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '+${boost.value}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Info icon to flip back
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _toggleFlip(card.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder(UserCard card, Color tierColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tierColor.withOpacity(0.4),
            tierColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              card.isPlayerCard ? Icons.person : Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
            if (card.position != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.position!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No opponents available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select an opponent to attack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Users list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(AttackUser user) {
    return GestureDetector(
      onTap: () => _initiateAttack(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 42,
            backgroundColor: Colors.red.withOpacity(0.3),
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: const Text(
            'Tap to attack',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_mma,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
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

  Widget _buildResultView() {
    final deadline = _matchData?.preparationDeadline;
    final createdAt = _matchData?.createdAt;
    final remaining = deadline != null ? deadline.difference(DateTime.now()) : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Attack icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
                border: Border.all(
                  color: Colors.red,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.sports_mma,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),

            // Attack started text
            const Text(
              'ATTACK STARTED!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // User name
            Text(
              'Attack on ${_selectedUser?.fullName ?? "opponent"} started',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Preparation time info
            if (remaining != null && remaining.inSeconds > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.orange, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'PREPARATION TIME',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can modify your lineup until the preparation ends',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Attack time info
            if (createdAt != null)
              Text(
                'Attack started: ${createdAt.toLocal().toString().substring(0, 16)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 24),

            // Done button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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

