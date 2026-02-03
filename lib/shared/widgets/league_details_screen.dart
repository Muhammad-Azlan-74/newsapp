import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/fantasy_repository.dart';
import 'package:newsapp/features/user/data/models/fantasy_league_models.dart';

/// League Details Screen with Glass Design (like signout button)
///
/// Displays detailed information about a fantasy league with tabs for rosters, users, and matchups
class LeagueDetailsScreen extends StatefulWidget {
  final String leagueId;
  final String leagueName;

  const LeagueDetailsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<LeagueDetailsScreen> createState() => _LeagueDetailsScreenState();
}

class _LeagueDetailsScreenState extends State<LeagueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final FantasyRepository _repository;
  late final TabController _tabController;
  
  League? _league;
  List<Roster>? _rosters;
  List<LeagueUser>? _users;
  List<Matchup>? _matchups;
  
  bool _isLoadingLeague = true;
  bool _isLoadingRosters = false;
  bool _isLoadingUsers = false;
  bool _isLoadingMatchups = false;
  
  String? _error;
  int _selectedWeek = 1;

  @override
  void initState() {
    super.initState();
    _repository = FantasyRepository(ApiClient());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLeagueDetails();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          if (_rosters == null) _loadRosters();
          break;
        case 1:
          if (_users == null) _loadUsers();
          break;
        case 2:
          if (_matchups == null) _loadMatchups(_selectedWeek);
          break;
      }
    }
  }

  Future<void> _loadLeagueDetails() async {
    try {
      final league = await _repository.getLeagueDetails(widget.leagueId);
      setState(() {
        _league = league;
        _isLoadingLeague = false;
      });
      _loadRosters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingLeague = false;
      });
    }
  }

  Future<void> _loadRosters() async {
    if (_isLoadingRosters) return;
    setState(() => _isLoadingRosters = true);
    try {
      final rosters = await _repository.getLeagueRosters(widget.leagueId);
      setState(() {
        _rosters = rosters;
        _isLoadingRosters = false;
      });
    } catch (e) {
      setState(() => _isLoadingRosters = false);
    }
  }

  Future<void> _loadUsers() async {
    if (_isLoadingUsers) return;
    setState(() => _isLoadingUsers = true);
    try {
      final users = await _repository.getLeagueUsers(widget.leagueId);
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _loadMatchups(int week) async {
    if (_isLoadingMatchups) return;
    setState(() => _isLoadingMatchups = true);
    try {
      final matchups = await _repository.getLeagueMatchups(widget.leagueId, week);
      setState(() {
        _matchups = matchups;
        _selectedWeek = week;
        _isLoadingMatchups = false;
      });
    } catch (e) {
      setState(() => _isLoadingMatchups = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.leagueName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black87,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey.shade600,
          dividerColor: Colors.white.withOpacity(0.3),
          tabs: const [
            Tab(text: 'Rosters', icon: Icon(Icons.people)),
            Tab(text: 'Users', icon: Icon(Icons.account_circle)),
            Tab(text: 'Matchups', icon: Icon(Icons.sports)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
          ),
        ),
        child: _isLoadingLeague
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRostersTab(),
                      _buildUsersTab(),
                      _buildMatchupsTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRostersTab() {
    if (_isLoadingRosters) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_rosters == null || _rosters!.isEmpty) {
      return const Center(child: Text('No rosters available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(top: 100),
      itemCount: _rosters!.length,
      itemBuilder: (context, index) {
        final roster = _rosters![index];
        final wins = roster.settings['wins'] ?? 0;
        final losses = roster.settings['losses'] ?? 0;
        final points = roster.settings['fpts'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildGlassCard(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.white.withOpacity(0.2),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                iconColor: Colors.black87,
                collapsedIconColor: Colors.black87,
                title: Text(
                  'Team ${roster.rosterId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Record: $wins-$losses • Points: $points',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                children: [
                  if (roster.starters.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...roster.starters.map((player) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade400,
                                              Colors.green.shade600,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          player.fantasyPositions.first,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${player.fullName} #${player.number}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              player.team,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: player.status == 'Active'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: player.status == 'Active'
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          player.status,
                                          style: TextStyle(
                                            color: player.status == 'Active'
                                                ? Colors.green.shade700
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_users == null || _users!.isEmpty) {
      return const Center(child: Text('No users available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(top: 100),
      itemCount: _users!.length,
      itemBuilder: (context, index) {
        final user = _users![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: user.avatar != null
                          ? Image.network(user.avatar!, fit: BoxFit.cover)
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade200,
                                    Colors.blue.shade400,
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'User ID: ${user.userId}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user.isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.amber.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OWNER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchupsTab() {
    return Column(
      children: [
        const SizedBox(height: 90),
        Container(
          margin: const EdgeInsets.all(16),
          child: _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Week:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(18, (index) {
                        final week = index + 1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _loadMatchups(week),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: _selectedWeek == week
                                      ? LinearGradient(
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.blue.shade600,
                                          ],
                                        )
                                      : null,
                                  color: _selectedWeek != week
                                      ? Colors.white.withOpacity(0.15)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedWeek == week
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$week',
                                  style: TextStyle(
                                    color: _selectedWeek == week
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoadingMatchups
              ? const Center(child: CircularProgressIndicator())
              : _matchups == null || _matchups!.isEmpty
                  ? const Center(
                      child: Text('No matchups for this week'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _matchups!.length,
                      itemBuilder: (context, index) {
                        final matchup = _matchups![index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildGlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Team ${matchup.rosterId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Matchup #${matchup.matchupId}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.blue.shade600,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${matchup.points.toStringAsFixed(2)} pts',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
