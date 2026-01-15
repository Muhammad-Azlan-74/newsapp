import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _hofRepository = HofRepository(ApiClient());
    _loadCurrentUserId();
    _loadHallOfFame();
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

  Widget _buildImageGallery() {
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
              Text(
                'Error loading Hall of Fame',
                style: const TextStyle(
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
              Text(
                'No pictures yet',
                style: const TextStyle(
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

    // Horizontal circular scroll for images with scale effect
    final pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _hallOfFame!.images.length * 1000, // Start in the middle for circular effect
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: PageView.builder(
        controller: pageController,
        itemCount: null, // Infinite scroll for circular effect
        itemBuilder: (context, index) {
          // Get actual image index using modulo for circular scroll
          final actualIndex = index % _hallOfFame!.images.length;
          final image = _hallOfFame!.images[actualIndex];

          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double value = 1.0;
              double offset = 0.0;

              if (pageController.position.haveDimensions) {
                value = pageController.page! - index;
                // Scale: items further from center are smaller
                double scale = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                // Vertical offset: items further from center move down in an arc
                offset = (value.abs() * 80); // Adjust this value to control arc height

                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(scale) * MediaQuery.of(context).size.height * 0.65,
                      width: Curves.easeInOut.transform(scale) * MediaQuery.of(context).size.width * 0.8,
                      child: child,
                    ),
                  ),
                );
              }

              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.fill,
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
          );
        },
      ),
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
          // Image gallery in center
          Center(
            child: _buildImageGallery(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: const GlassyBackButton(),
          ),
          // User name at the top center
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          // Total likes in top right corner
          if (_hallOfFame != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_hallOfFame!.likes}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Like button in bottom right - aligned with back button
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
