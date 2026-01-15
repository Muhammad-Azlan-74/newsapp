import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/shared/widgets/glassy_button.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/hof_repository.dart';
import 'package:newsapp/features/user/data/models/hall_of_fame_model.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/utils/jwt_decoder.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Personal HOF Screen
///
/// Displays the personal Hall of Fame room with hof_room.png background at 40% opacity
class PersonalHofScreen extends StatefulWidget {
  const PersonalHofScreen({super.key});

  @override
  State<PersonalHofScreen> createState() => _PersonalHofScreenState();
}

class _PersonalHofScreenState extends State<PersonalHofScreen> {
  final ImagePicker _picker = ImagePicker();
  late final HofRepository _hofRepository;
  HallOfFameModel? _hallOfFame;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _hofRepository = HofRepository(ApiClient());
    _loadHallOfFame();
  }

  Future<void> _loadHallOfFame() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get access token
      final token = await AuthStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      // Extract userId from JWT token
      final userId = JwtDecoder.getUserId(token);
      if (userId == null || userId.isEmpty) {
        throw Exception('Unable to extract user ID from token');
      }

      final response = await _hofRepository.getHofDetails(userId);

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

  Future<void> _uploadPicture() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) {
        return; // User cancelled the picker
      }

      // Set uploading state
      setState(() {
        _isUploading = true;
      });

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Uploading image...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Upload the image to backend
      final response = await _hofRepository.uploadPicture(image.path);

      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Reload the Hall of Fame to show the new image
        await _loadHallOfFame();

        // Clear uploading state
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().replaceAll('ApiException: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear uploading state
        setState(() {
          _isUploading = false;
        });
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
                'Upload your first picture to get started!',
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
          // Total likes in top right corner
          if (_hallOfFame != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // Upload button in bottom right
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            right: 24,
            child: GlassyButton(
              onPressed: _isUploading ? () {} : _uploadPicture,
              text: 'Upload Picture',
              icon: Icons.upload,
              isFullWidth: false,
              isLoading: _isUploading,
            ),
          ),
        ],
      ),
    );
  }
}
