import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/features/user/data/repositories/rumor_repository.dart';
import 'package:newsapp/features/user/data/models/rumor_model.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// Rumour Garage Screen
///
/// Displays the garage background image with a single rumor on topsecret image
class RumourGarageScreen extends StatefulWidget {
  const RumourGarageScreen({super.key});

  @override
  State<RumourGarageScreen> createState() => _RumourGarageScreenState();
}

class _RumourGarageScreenState extends State<RumourGarageScreen> {
  late final RumorRepository _rumorRepository;
  Rumor? _rumor;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _rumorRepository = RumorRepository(ApiClient());
    _loadRumor();
  }

  Future<void> _loadRumor() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get selected team ID if available
      final teamId = await AuthStorageService.getSelectedTeam();

      final response = await _rumorRepository.getRumor(
        teamId: teamId,
      );

      setState(() {
        _rumor = response.rumor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          // Top secret image in center with rumor data on it
          Center(
            child: _buildSecretWithRumor(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }

  Widget _buildSecretWithRumor() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageWidth = screenWidth * 0.85;
    final imageHeight = screenHeight * 0.55;

    return GestureDetector(
      onTap: () {
        if (_rumor != null) {
          _showRumorDetailsDialog(_rumor!);
        }
      },
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: Stack(
          children: [
            // Top secret image as background
            Positioned.fill(
              child: Image.asset(
                'assets/images/topsecret.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'TOP SECRET',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Rumor content overlaid on the right half of image
            Positioned(
              top: imageHeight * 0.28,
              bottom: imageHeight * 0.25,
              left: imageWidth * 0.45,
              right: imageWidth * 0.01,
              child: _buildRumorContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _showRumorDetailsDialog(Rumor rumor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.5),
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
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RUMOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
                        const SizedBox(width: 12),
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
                            rumor.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            rumor.description.isNotEmpty
                                ? rumor.description
                                : rumor.summary,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            rumor.publishedDate,
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
      ),
    );
  }

  Widget _buildRumorContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_errorMessage != null) {
      final isAuthError = _errorMessage!.contains('401') ||
                          _errorMessage!.contains('Unauthorized') ||
                          _errorMessage!.contains('UnauthorizedException');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              isAuthError ? 'Session expired' : 'Error loading rumor',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (isAuthError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please login again',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadRumor,
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (_rumor == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.red),
            SizedBox(height: 12),
            Text(
              'No rumors available',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return _buildRumorText(_rumor!);
  }

  /// Build rumor text content to overlay on the secret image
  Widget _buildRumorText(Rumor rumor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          rumor.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            height: 1.3,
          ),
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 100,
        ),
      ),
    );
  }
}

