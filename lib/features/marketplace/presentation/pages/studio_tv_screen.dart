import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/team_avatar_widget.dart';
import 'package:newsapp/shared/widgets/welcome_chat_bubble.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/tv_studio_news_repository.dart';
import 'package:newsapp/features/user/data/models/tv_studio_news_model.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';

/// Studio TV Screen
///
/// Displays studio TV background with TV Studio news
class StudioTvScreen extends StatefulWidget {
  const StudioTvScreen({super.key});

  @override
  State<StudioTvScreen> createState() => _StudioTvScreenState();
}

class _StudioTvScreenState extends State<StudioTvScreen> {
  bool _showNews = false;
  bool _showHelpBubble = false;
  late final TvStudioNewsRepository _tvStudioNewsRepository;
  List<TvStudioNews>? _tvStudioNews;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tvStudioNewsRepository = TvStudioNewsRepository(ApiClient());
    _scrollController.addListener(_onScroll);

    // Show welcome message after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showHelpBubble = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _currentPage < _totalPages) {
        _loadMoreTvStudioNews();
      }
    }
  }

  Future<void> _loadTvStudioNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get selected team ID if available
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _tvStudioNewsRepository.getTvStudioNews(
        page: 1,
        limit: 10,
        teamId: teamId,
      );

      setState(() {
        _tvStudioNews = response.tvStudioNews;
        _currentPage = response.pagination.currentPage;
        _totalPages = response.pagination.totalPages;
        _isLoading = false;
        _showNews = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _showNews = true;
      });
    }
  }

  Future<void> _loadMoreTvStudioNews() async {
    try {
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _tvStudioNewsRepository.getTvStudioNews(
        page: _currentPage + 1,
        limit: 10,
        teamId: teamId,
      );

      setState(() {
        _tvStudioNews?.addAll(response.tvStudioNews);
        _currentPage = response.pagination.currentPage;
      });
    } catch (e) {
      // Silently fail for pagination errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, // White background
              image: DecorationImage(
                image: AssetImage(AppAssets.studioTv),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // TV Studio news overlay
          if (_showNews) _buildNewsOverlay(),
          // Team anchor avatar in bottom left
          TeamAvatarWidget(
            imageType: 'anchor',
            onTap: () {
              if (_showNews) {
                setState(() {
                  _showNews = false;
                });
              } else {
                _loadTvStudioNews();
              }
            },
          ),
          // Help chat bubble (appears on screen load)
          if (_showHelpBubble && !_showNews)
            WelcomeChatBubble(
              isFirstTime: false,
              customMessage: 'Hi! How can I help you?',
              onDismissed: () {
                setState(() {
                  _showHelpBubble = false;
                });
              },
            ),
          // Back button
          const Positioned(
            top: 40,
            left: 16,
            child: GlassyBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tv, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'TV Studio News',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Expanded(
                          child: _buildContent(),
                        ),
                      ],
                    ),
                    // Close button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _showNews = false;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _tvStudioNews == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading TV Studio news',
                style: TextStyle(
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
                onPressed: _loadTvStudioNews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tvStudioNews == null || _tvStudioNews!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tv_off, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'No TV Studio news available',
              style: TextStyle(
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
      padding: const EdgeInsets.all(16),
      itemCount: _tvStudioNews!.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _tvStudioNews!.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final news = _tvStudioNews![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'TV STUDIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            news.league,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        news.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.summary,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.publishedDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
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
