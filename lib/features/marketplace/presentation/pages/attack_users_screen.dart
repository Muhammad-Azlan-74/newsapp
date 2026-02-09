import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/match_storage_service.dart';
import 'package:newsapp/core/services/match_result_service.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/features/marketplace/presentation/pages/attack_lineup_view_screen.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Attack Users Screen
///
/// Shows list of attackable users. Clicking a user shows confirmation dialog.
/// - Yes → starts the attack
/// - No → takes user to attack lineup setup screen
class AttackUsersScreen extends StatefulWidget {
  const AttackUsersScreen({super.key});

  @override
  State<AttackUsersScreen> createState() => _AttackUsersScreenState();
}

class _AttackUsersScreenState extends State<AttackUsersScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  List<AttackUser> _users = [];
  bool _isLoading = true;
  bool _isAttacking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkActiveAttackAndLoad();
  }

  Future<void> _checkActiveAttackAndLoad() async {
    // First check if user is already attacking someone locally
    final activeMatch = await MatchStorageService.getActiveMatch();
    
    if (activeMatch != null) {
      // Verify with server
      try {
        final history = await _cardRepository.getMatchesHistory();
        final serverMatch = history.data.cast<MatchHistoryItem?>().firstWhere(
          (m) => m!.id == activeMatch.matchId,
          orElse: () => null,
        );

        if (serverMatch == null) {
          await MatchStorageService.clearMatch();
          if (mounted) _loadUsers();
          return;
        }

        if (serverMatch.status != 'PREPARATION' && serverMatch.status != 'IN_PROGRESS') {
          await MatchStorageService.clearMatch();
          if (mounted) _loadUsers();
          return;
        }

        if (mounted) {
          _showAlreadyAttackingDialog(activeMatch);
        }
      } catch (e) {
        if (mounted) {
          _showAlreadyAttackingDialog(activeMatch);
        }
      }
      return;
    }

    // Load attackable users
    _loadUsers();
  }

  void _showAlreadyAttackingDialog(ActiveMatchInfo match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sports_mma, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Active Attack',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are already attacking',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              match.defenderName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ends in ${_formatDuration(match.preparationDeadline.difference(DateTime.now()))}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Force calculation on server if needed
              try {
                if (match.preparationDeadline.isBefore(DateTime.now())) {
                  await _cardRepository.calculateMatchResult(match.matchId);
                }
              } catch (e) {
                debugPrint('Failed to trigger calculation: $e');
              }

              if (context.mounted) Navigator.pop(context);
              await _checkActiveAttackAndLoad();
            },
            child: const Text('Refresh Status', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from this screen
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Ended';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _cardRepository.getAttackUsers();
      if (!mounted) return;

      setState(() {
        _users = response.users;
        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _error = 'Please login to view users';
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
        _error = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  void _showUserConfirmationDialog(AttackUser user) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: user.profilePicture != null
                      ? CachedNetworkImageProvider(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white54)
                      : null,
                ),
                const SizedBox(height: 16),
                // User name
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Level
                if (user.level != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level ${user.level}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBox('Wins', '${user.totalWins ?? 0}', Colors.green),
                    const SizedBox(width: 16),
                    _buildStatBox('Losses', '${user.totalLosses ?? 0}', Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                // Confirmation text
                Text(
                  'Attack this player?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    // No button - go to lineup setup
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttackLineupViewScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Edit Lineup',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Yes button - start attack
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _initiateAttack(user);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Attack!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
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
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateAttack(AttackUser user) async {
    setState(() {
      _isAttacking = true;
    });

    try {
      final response = await _cardRepository.initiateAttack(user.id);
      if (!mounted) return;

      // Save match data locally
      if (response.data != null) {
        final deadline = response.data!.preparationDeadline ??
            DateTime.now().add(const Duration(minutes: 5));

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

      // Show success and go back
      _showAttackSuccessDialog(user, response.data);
    } on UnauthorizedException {
      if (!mounted) return;
      _showErrorSnackbar('Please login to attack');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to attack: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAttacking = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAttackSuccessDialog(AttackUser user, MatchData? match) {
    final deadline = match?.preparationDeadline ?? DateTime.now().add(const Duration(minutes: 5));
    final remaining = deadline.difference(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text(
              'Attack Started!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are now attacking',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              user.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Preparation: ${_formatDuration(remaining)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from this screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        // Main content
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
              'Choose Opponent',
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
        // Loading overlay
        if (_isAttacking)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Starting attack...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
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
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Loading opponents...',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'No opponents available',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(AttackUser user) {
    return GestureDetector(
      onTap: () => _showUserConfirmationDialog(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.profilePicture != null
                  ? CachedNetworkImageProvider(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? const Icon(Icons.person, size: 28, color: Colors.white54)
                  : null,
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user.level != null) ...[
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Lvl ${user.level}',
                          style: TextStyle(
                            color: Colors.amber.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.emoji_events, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${user.totalWins ?? 0}W',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${user.totalLosses ?? 0}L',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Attack icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_mma,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
