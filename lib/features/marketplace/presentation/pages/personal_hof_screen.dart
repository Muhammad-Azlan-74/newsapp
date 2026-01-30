import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/shared/widgets/glassy_button.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/custom_snackbar.dart';
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
  int _selectedIndex = 0;
  final ScrollController _thumbnailScrollController = ScrollController();
  final TextEditingController _captionController = TextEditingController();
  bool _isSavingCaption = false;

  @override
  void initState() {
    super.initState();
    _hofRepository = HofRepository(ApiClient());
    _loadHallOfFame();
  }

  @override
  void dispose() {
    _thumbnailScrollController.dispose();
    _captionController.dispose();
    super.dispose();
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
        _selectedIndex = 0;
        // Set caption controller with first image's caption
        if (_hallOfFame != null && _hallOfFame!.images.isNotEmpty) {
          _captionController.text = _hallOfFame!.images[0].caption ?? '';
        }
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

      // Show uploading message
      if (mounted) {
        CustomSnackbar.show(context, 'Uploading picture...');
      }

      // Upload the image to backend
      final response = await _hofRepository.uploadPicture(image.path);

      // Hide loading snackbar and show success
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show success message
        CustomSnackbar.show(context, 'Picture uploaded successfully!');

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
        CustomSnackbar.show(
          context,
          'Upload failed: ${e.toString().replaceAll('ApiException: ', '')}',
          isError: true,
        );

        // Clear uploading state
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _onThumbnailTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Update caption controller with selected image's caption
    if (_hallOfFame != null && _hallOfFame!.images.isNotEmpty) {
      _captionController.text = _hallOfFame!.images[index].caption ?? '';
    }
    // Scroll to center the selected thumbnail
    _scrollToCenter(index);
  }

  Future<void> _saveCaption() async {
    if (_hallOfFame == null || _hallOfFame!.images.isEmpty) return;

    final selectedImage = _hallOfFame!.images[_selectedIndex];
    final caption = _captionController.text.trim();

    try {
      setState(() {
        _isSavingCaption = true;
      });

      await _hofRepository.addCaption(selectedImage.id, caption);

      if (mounted) {
        CustomSnackbar.show(context, 'Caption saved successfully!');
        // Reload to get updated data
        await _loadHallOfFame();
        // Restore the selected index and caption
        if (_hallOfFame != null && _hallOfFame!.images.length > _selectedIndex) {
          _captionController.text = _hallOfFame!.images[_selectedIndex].caption ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to save caption: ${e.toString().replaceAll('ApiException: ', '')}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCaption = false;
        });
      }
    }
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
            children: const [
              Icon(Icons.photo_library_outlined, size: 64, color: Colors.black54),
              SizedBox(height: 16),
              Text(
                'No pictures yet',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upload your first picture to get started!',
                style: TextStyle(color: Colors.black87),
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

        // Large centered image
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

                const SizedBox(height: 8),

                // Caption text field with save button
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _captionController,
                              decoration: const InputDecoration(
                                hintText: 'Add a caption...',
                                hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              style: const TextStyle(color: Colors.black, fontSize: 13),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Save button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSavingCaption ? null : _saveCaption,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _isSavingCaption
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
              ],
            ),
          ),
        ),
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
          // Upload button in bottom right
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: 16,
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
