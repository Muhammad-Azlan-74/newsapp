import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/fantasy_repository.dart';
import 'package:newsapp/features/user/data/models/sleeper_user_model.dart';
import 'package:newsapp/features/user/data/models/fantasy_league_models.dart';
import 'package:newsapp/shared/widgets/league_details_screen.dart';

/// User Leagues Screen
/// 
/// Displays all fantasy leagues for a specific Sleeper user with glass effect like signout button
class UserLeaguesScreen extends StatefulWidget {
  final SleeperUser user;
  final String season;

  const UserLeaguesScreen({
    super.key,
    required this.user,
    required this.season,
  });

  @override
  State<UserLeaguesScreen> createState() => _UserLeaguesScreenState();
}

class _UserLeaguesScreenState extends State<UserLeaguesScreen> {
  late final FantasyRepository _repository;
  List<League>? _leagues;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = FantasyRepository(ApiClient());
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    try {
      final leagues = await _repository.getUserLeagues(widget.user.userId, widget.season);
      setState(() {
        _leagues = leagues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.user.displayName}\'s Leagues'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _loadLeagues();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _leagues == null || _leagues!.isEmpty
                    ? const Center(
                        child: Text('No leagues found for this season'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _leagues!.length,
                        itemBuilder: (context, index) {
                          final league = _leagues![index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12, top: index == 0 ? 80 : 0),
                            child: ClipRRect(
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
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LeagueDetailsScreen(
                                              leagueId: league.leagueId,
                                              leagueName: league.name,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                color: Colors.white.withOpacity(0.2),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: league.avatar != null
                                                    ? Image.network(
                                                        league.avatar!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.sports_football,
                                                        color: Colors.black,
                                                        size: 30,
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    league.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${league.totalRosters} teams • ${league.season}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Status: ${league.status.toUpperCase()}',
                                                    style: TextStyle(
                                                      color: league.status == 'complete'
                                                          ? Colors.grey.shade600
                                                          : Colors.green.shade700,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Arrow
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
