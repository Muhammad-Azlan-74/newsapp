import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/rumor_repository.dart';
import 'package:newsapp/features/user/data/models/rumor_model.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';

/// Rumour Garage Screen
///
/// Displays the garage background image with rumors list
class RumourGarageScreen extends StatefulWidget {
  const RumourGarageScreen({super.key});

  @override
  State<RumourGarageScreen> createState() => _RumourGarageScreenState();
}

class _RumourGarageScreenState extends State<RumourGarageScreen> {
  late final RumorRepository _rumorRepository;
  List<Rumor>? _rumors;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _rumorRepository = RumorRepository(ApiClient());
    _loadRumors();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _currentPage < _totalPages) {
        _loadMoreRumors();
      }
    }
  }

  Future<void> _loadRumors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get selected team ID if available
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _rumorRepository.getRumors(
        page: 1,
        limit: 10,
        teamId: teamId,
      );

      setState(() {
        _rumors = response.rumors;
        _currentPage = response.pagination.currentPage;
        _totalPages = response.pagination.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreRumors() async {
    try {
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _rumorRepository.getRumors(
        page: _currentPage + 1,
        limit: 10,
        teamId: teamId,
      );

      setState(() {
        _rumors?.addAll(response.rumors);
        _currentPage = response.pagination.currentPage;
      });
    } catch (e) {
      // Silently fail for pagination errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          // Background image with BoxFit.cover
          Positioned.fill(
            child: Image.asset(
              AppAssets.garage,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading garage image: $error',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Shaddy avatar (larger size)
          Positioned(
            left: 20,
            bottom: 40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.shaddy,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 70,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Rumors list
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            bottom: 180,
            child: _buildRumorsList(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildRumorsList() {
    if (_isLoading && _rumors == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading rumors',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRumors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rumors == null || _rumors!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'No rumors available',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _rumors!.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _rumors!.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final rumor = _rumors![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RUMOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            rumor.league,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rumor.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rumor.summary,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
