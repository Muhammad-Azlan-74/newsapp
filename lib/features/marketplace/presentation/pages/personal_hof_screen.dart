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
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

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

  /// Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
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
                    const Text(
                      'Choose Image Source',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Camera option
                    InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, color: Colors.blue.shade700, size: 28),
                            const SizedBox(width: 16),
                            const Text(
                              'Take a Photo',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Gallery option
                    InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.photo_library, color: Colors.green.shade700, size: 28),
                            const SizedBox(width: 16),
                            const Text(
                              'Choose from Gallery',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
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

    if (source != null) {
      _uploadPicture(source);
    }
  }

  Future<void> _uploadPicture(ImageSource source) async {
    try {
      // Pick image from selected source
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image == null) {
        return; // User cancelled the picker
      }

      // NOW ask if the picture is for sale (BEFORE uploading)
      final isForSale = await _askIfForSale();
      double? saleAmount;
      
      if (isForSale == true) {
        // Ask for the sale amount
        saleAmount = await _askForSaleAmount();
        
        if (saleAmount == null) {
          return; // User cancelled amount input
        }
      }

      // Set uploading state
      setState(() {
        _isUploading = true;
      });

      // Show uploading message
      if (mounted) {
        CustomSnackbar.show(context, 'Uploading picture...');
      }

      // Upload the image to backend with sale information
      final response = await _hofRepository.uploadPicture(
        image.path,
        isForSale: isForSale ?? false,
        saleAmount: saleAmount,
      );

      // Hide loading snackbar and show success
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show success message
        if (isForSale == true) {
          CustomSnackbar.show(context, 'Picture uploaded and listed for sale!');
        } else {
          CustomSnackbar.show(context, 'Picture uploaded successfully!');
        }

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

  /// Ask if the picture is for sale
  Future<bool?> _askIfForSale() async {
    return await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sell,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Is this picture for sale?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  /// Ask for the sale amount in dollars
  Future<double?> _askForSaleAmount() async {
    final TextEditingController amountController = TextEditingController();

    return await showDialog<double>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sale Amount',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the sale amount in dollars',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: 'Enter amount',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(amountController.text);
                              if (amount == null || amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid amount'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context, amount);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

        // Large centered image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Large image
                Expanded(
                  child: Center(
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
                ),

                const SizedBox(height: 8),

                // Sale status label
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedImage.isForSale
                            ? Colors.green.withOpacity(0.25)
                            : Colors.red.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedImage.isForSale
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selectedImage.isForSale ? Icons.attach_money : Icons.block,
                            color: selectedImage.isForSale ? Colors.green.shade800 : Colors.red.shade800,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            selectedImage.isForSale
                                ? 'For Sale: \$${selectedImage.saleAmount?.toStringAsFixed(0) ?? "0"}'
                                : 'Not For Sale',
                            style: TextStyle(
                              color: selectedImage.isForSale ? Colors.green.shade900 : Colors.red.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Horizontal thumbnail list at bottom
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
                      color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
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
          // Upload button in bottom right
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: 16,
            child: GlassyButton(
              onPressed: _isUploading ? () {} : _showImageSourceDialog,
              text: 'Upload Picture',
              icon: Icons.upload,
              isFullWidth: false,
              isLoading: _isUploading,
            ),
          ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

