import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/hof_repository.dart';
import 'package:newsapp/features/user/data/models/hall_of_fame_model.dart';
import 'package:newsapp/shared/widgets/glassy_button.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/utils/jwt_decoder.dart';

/// Friend HOF Screen
///
/// Displays a friend's Hall of Fame room with hof_room.png background at 40% opacity
class FriendHofScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const FriendHofScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<FriendHofScreen> createState() => _FriendHofScreenState();
}

class _FriendHofScreenState extends State<FriendHofScreen> {
  late final HofRepository _hofRepository;
  HallOfFameModel? _hallOfFame;
  bool _isLoading = true;
  bool _isLiking = false;
  String? _errorMessage;
  String? _currentUserId;
  int _selectedIndex = 0;
  final ScrollController _thumbnailScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _hofRepository = HofRepository(ApiClient());
    _loadCurrentUserId();
    _loadHallOfFame();
  }

  @override
  void dispose() {
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token != null) {
        final userId = JwtDecoder.getUserId(token);
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadHallOfFame() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _hofRepository.getHofDetails(widget.userId);

      setState(() {
        _hallOfFame = response.hallOfFame;
        _isLoading = false;
        _selectedIndex = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool get _hasLiked {
    if (_hallOfFame == null || _currentUserId == null) return false;
    return _hallOfFame!.likedBy.contains(_currentUserId);
  }

  Future<void> _handleLike() async {
    if (_hallOfFame == null) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final response = _hasLiked
          ? await _hofRepository.unlikeHofEntry(widget.userId)
          : await _hofRepository.likeHofEntry(widget.userId);

      if (mounted) {
        // Update the likes count and likedBy list
        setState(() {
          _hallOfFame = HallOfFameModel(
            userId: _hallOfFame!.userId,
            images: _hallOfFame!.images,
            likes: response.likes,
            likedBy: _hasLiked
                ? _hallOfFame!.likedBy.where((id) => id != _currentUserId).toList()
                : [..._hallOfFame!.likedBy, _currentUserId!],
            createdAt: _hallOfFame!.createdAt,
            updatedAt: _hallOfFame!.updatedAt,
          );
          _isLiking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('ApiException: ', '')}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onThumbnailTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _scrollToCenter(index);
  }

  void _scrollToCenter(int index) {
    if (_hallOfFame == null || _hallOfFame!.images.isEmpty) return;
    if (!_thumbnailScrollController.hasClients) return;

    const thumbnailWidth = 60.0;
    const thumbnailSpacing = 8.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * (thumbnailWidth + thumbnailSpacing)) -
        (screenWidth / 2) + (thumbnailWidth / 2) + 16;

    _thumbnailScrollController.animateTo(
      targetOffset.clamp(0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
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
                'Error loading Hall of Fame',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHallOfFame,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hallOfFame == null || _hallOfFame!.images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined, size: 64, color: Colors.black54),
              const SizedBox(height: 16),
              const Text(
                'No pictures yet',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.userName} hasn\'t uploaded any pictures yet.',
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final selectedImage = _hallOfFame!.images[_selectedIndex];

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 60),

        // Horizontal thumbnail list at top
        SizedBox(
          height: 70,
          child: ListView.builder(
            controller: _thumbnailScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _hallOfFame!.images.length,
            itemBuilder: (context, index) {
              final image = _hallOfFame!.images[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () => _onThumbnailTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: image.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: const Icon(Icons.error, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Large centered image with caption
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Large image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: selectedImage.url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),

                // Caption display (if exists)
                if (selectedImage.caption != null && selectedImage.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            selectedImage.caption!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image with 40% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/hof_room.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          _buildContent(),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: const GlassyBackButton(),
          ),
          // Likes count (replaced help button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_hallOfFame?.likes ?? 0}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Like button in bottom right
          if (_hallOfFame != null && _hallOfFame!.images.isNotEmpty)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: GlassyButton(
                onPressed: _isLiking ? () {} : _handleLike,
                text: _hasLiked ? 'Unlike' : 'Like',
                icon: _hasLiked ? Icons.favorite : Icons.favorite_border,
                isFullWidth: false,
                isLoading: _isLiking,
              ),
            ),
        ],
      ),
    );
  }
}
