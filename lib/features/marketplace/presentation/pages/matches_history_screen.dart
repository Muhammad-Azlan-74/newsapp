import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Matches History Screen
///
/// Displays the user's match history with filters for attack/defense
class MatchesHistoryScreen extends StatefulWidget {
  /// Initial filter to apply (null = all, 'attack', 'defense')
  final String? initialFilter;

  /// List of allowed filters to show in tabs
  /// If null, all filters are shown [null, 'attack', 'defense']
  /// Example: [null, 'attack'] shows only All and Attack tabs
  final List<String?>? allowedFilters;

  const MatchesHistoryScreen({
    super.key,
    this.initialFilter,
    this.allowedFilters,
  });

  @override
  State<MatchesHistoryScreen> createState() => _MatchesHistoryScreenState();
}

class _MatchesHistoryScreenState extends State<MatchesHistoryScreen> {
  final CardRepository _cardRepository = CardRepository(ApiClient());

  bool _isLoading = true;
  String? _errorMessage;
  List<MatchHistoryItem> _matches = [];
  String? _currentUserId;
  String? _currentUserEmail;

  // Filter: null = all, 'attack', 'defense'
  String? _selectedFilter;

  // Default allowed filters if not specified
  late final List<String?> _allowedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _allowedFilters = widget.allowedFilters ?? [null, 'attack', 'defense'];
    _loadUserAndMatches();
  }

  Future<void> _loadUserAndMatches() async {
    // Get current user data - check both 'id' and '_id' keys
    final userData = await AuthStorageService.getUserData();
    _currentUserId = userData?['_id'] as String? ?? userData?['id'] as String?;
    _currentUserEmail = userData?['email'] as String?;

    await _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _cardRepository.getMatchesHistory(type: _selectedFilter);

      if (!mounted) return;

      // Remove duplicates by match ID
      final uniqueMatches = <String, MatchHistoryItem>{};
      for (final match in response.data) {
        uniqueMatches[match.id] = match;
      }

      setState(() {
        _matches = uniqueMatches.values.toList();
        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please login to view match history';
      });
    } on NetworkException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No internet connection';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load matches: $e';
      });
    }
  }

  void _setFilter(String? filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      _loadMatches();
    }
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
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        // Content
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
              'Match History',
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
          body: Column(
            children: [
              // Filter tabs
              _buildFilterTabs(),
              // Matches list
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (_allowedFilters.contains(null)) _buildFilterTab('All', null),
          if (_allowedFilters.contains('attack')) _buildFilterTab('Attack', 'attack'),
          if (_allowedFilters.contains('defense')) _buildFilterTab('Defense', 'defense'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String? filter) {
    final isSelected = _selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (filter == 'attack'
                    ? Colors.red
                    : filter == 'defense'
                        ? Colors.blue
                        : Colors.purple)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 16),
            Text(
              'Loading matches...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadMatches,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == null
                  ? 'Start attacking other players!'
                  : _selectedFilter == 'attack'
                      ? 'You haven\'t attacked anyone yet'
                      : 'No one has attacked you yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(_matches[index]);
      },
    );
  }

  Widget _buildMatchCard(MatchHistoryItem match) {
    // Determine if current user is the attacker by comparing emails and IDs
    bool isAttacker = false;
    MatchUserInfo opponent;

    // First try email comparison (most reliable)
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      if (match.attacker.email.toLowerCase() == _currentUserEmail!.toLowerCase()) {
        isAttacker = true;
        opponent = match.defender;
      } else if (match.defender.email.toLowerCase() == _currentUserEmail!.toLowerCase()) {
        isAttacker = false;
        opponent = match.attacker;
      } else {
        // Email didn't match, try ID
        if (_currentUserId != null && match.attacker.id == _currentUserId) {
          isAttacker = true;
          opponent = match.defender;
        } else if (_currentUserId != null && match.defender.id == _currentUserId) {
          isAttacker = false;
          opponent = match.attacker;
        } else {
          // No match - default to showing attacker as opponent
          isAttacker = false;
          opponent = match.attacker;
        }
      }
    } else if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      // No email, try ID comparison
      if (match.attacker.id == _currentUserId) {
        isAttacker = true;
        opponent = match.defender;
      } else {
        isAttacker = false;
        opponent = match.attacker;
      }
    } else {
      // No current user info - show attacker as opponent
      opponent = match.attacker;
    }

    final didWin = _currentUserId != null ? match.didWin(_currentUserId!) : null;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText = match.status;

    switch (match.status) {
      case 'PREPARATION':
        statusColor = Colors.orange;
        statusIcon = Icons.timer;
        statusText = 'Preparation';
        break;
      case 'IN_PROGRESS':
        statusColor = Colors.blue;
        statusIcon = Icons.sports_mma;
        statusText = 'In Progress';
        break;
      case 'COMPLETED':
        if (didWin == true) {
          statusColor = Colors.green;
          statusIcon = Icons.emoji_events;
          statusText = 'Victory';
        } else if (didWin == false) {
          statusColor = Colors.red;
          statusIcon = Icons.close;
          statusText = 'Defeat';
        } else {
          statusColor = Colors.grey;
          statusIcon = Icons.check;
          statusText = 'Completed';
        }
        break;
      case 'DRAW':
        statusColor = Colors.grey;
        statusIcon = Icons.handshake;
        statusText = 'Draw';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Attack/Defense indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAttacker
                            ? Colors.red.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAttacker ? Icons.sports_mma : Icons.shield,
                            color: isAttacker ? Colors.red : Colors.blue,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAttacker ? 'ATK' : 'DEF',
                            style: TextStyle(
                              color: isAttacker ? Colors.red : Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Opponent info
                Row(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Opponent name and match type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs ${opponent.fullName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opponent.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Score
                    if (match.status == 'COMPLETED' || match.status == 'DRAW')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${match.attackerScore} - ${match.defenderScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Footer with date and preparation deadline
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(match.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    if (match.status == 'PREPARATION' &&
                        match.preparationDeadline != null) ...[
                      const Spacer(),
                      Icon(
                        Icons.timer,
                        color: Colors.orange.withOpacity(0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ends: ${_formatDate(match.preparationDeadline)}',
                        style: TextStyle(
                          color: Colors.orange.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

