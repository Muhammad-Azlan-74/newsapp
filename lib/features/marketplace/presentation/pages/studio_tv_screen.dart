import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/team_avatar_widget.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/welcome_chat_bubble.dart';
import 'package:newsapp/shared/widgets/video_player_dialog.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/tv_studio_news_repository.dart';
import 'package:newsapp/features/user/data/models/tv_studio_news_model.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/constants/studio_tv_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

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
  bool _showHelpLabels = false;
  late final TvStudioNewsRepository _tvStudioNewsRepository;
  List<TvStudioNews>? _tvStudioNews;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _tvStudioNewsRepository = TvStudioNewsRepository(ApiClient());
    _scrollController.addListener(_onScroll);
    _loadTvStudioNews();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await AuthStorageService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _loadMoreTvStudioNews();
    }
  }

  Future<void> _loadTvStudioNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _tvStudioNewsRepository.getTvStudioNews(
        page: 1,
        limit: 20,
        teamId: teamId,
      );

      setState(() {
        _tvStudioNews = response.tvStudioNews;
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

  Future<void> _loadMoreTvStudioNews() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _tvStudioNewsRepository.getTvStudioNews(
        page: _currentPage + 1,
        limit: 20,
        teamId: teamId,
      );

      setState(() {
        _tvStudioNews?.addAll(response.tvStudioNews);
        _currentPage = response.pagination.currentPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Toggle help labels visibility for 5 seconds
  void _toggleHelpLabels() {
    if (_showHelpLabels) return; // Already showing

    setState(() {
      _showHelpLabels = true;
    });

    // Hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHelpLabels = false;
        });
      }
    });
  }

  /// Build a help label widget
  Widget _buildHelpLabel(String text) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  void _showNewsDetail(TvStudioNews news) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
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
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              news.description.isNotEmpty
                                  ? news.description
                                  : news.summary,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVideoDialog(String videoPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return VideoPlayerDialog(videoPath: videoPath);
      },
    );
  }

  /// Build the interactive chair overlays using normalized coordinates
  List<Widget> _buildChairOverlays(BuildContext context) {
    final overlays = StudioTvOverlays.all;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return overlays.map((overlay) {
      final label = overlay.label;
      final videoPath = StudioTvOverlays.getVideoPath(label);
      final color = StudioTvOverlays.getColor(label);

      // Calculate positions based on normalized coordinates
      final left = overlay.left * screenWidth;
      final top = overlay.top * screenHeight;
      final width = overlay.width * screenWidth;
      final height = overlay.height * screenHeight;

      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () {
            if (label == 'Breaking News') {
              // Show news dialog
              setState(() {
                _showNews = true;
              });
            } else if (videoPath != null) {
              // Play video
              _showVideoDialog(videoPath);
            }
          },
          child: Container(
            color: Colors.transparent,
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
          // Interactive overlays with normalized coordinates (includes Breaking News, Studio 1, and Studio 2)
          ..._buildChairOverlays(context),
          // TV Studio news overlay
          if (_showNews) _buildNewsOverlay(),
          // Team anchor avatar in bottom left
          TeamAvatarWidget(
            imageType: 'anchor',
            onTap: () {setState(() {
                _showHelpBubble = true;
              });
            },
          ),
          // Help chat bubble
          if (_showHelpBubble)
            WelcomeChatBubble(
              isFirstTime: false,
              customMessage: 'Hey ${_userName ?? 'there'}, click on the Breaking News board to read the latest stories!',
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
          // Help button
          Positioned(
            top: 40,
            right: 16,
            child: GlassyHelpButton(onPressed: _toggleHelpLabels),
          ),
          // Help label for Breaking News
          if (_showHelpLabels)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.24 + 10,
              left: MediaQuery.of(context).size.width * 0.5 + 10,
              child: _buildHelpLabel('Breaking News'),
            ),
          // Help labels for chair overlays
          if (_showHelpLabels)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38 + 10,
              left: MediaQuery.of(context).size.width * 0.09 + 10,
              child: _buildHelpLabel('Studio 1'),
            ),
          if (_showHelpLabels)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38 + 10,
              left: MediaQuery.of(context).size.width * 0.45 + 10,
              child: _buildHelpLabel('Studio 2'),
            ),
          // Top stats strip
          const TopStatsStrip(),
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
                          child: const Row(
                            children: [
                              Icon(Icons.tv, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
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

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tvStudioNews!.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        color: Colors.white.withOpacity(0.15),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        if (index == _tvStudioNews!.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        final news = _tvStudioNews![index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          title: Text(
            news.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              news.publishedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.5),
          ),
          onTap: () => _showNewsDetail(news),
        );
      },
    );
  }
}

