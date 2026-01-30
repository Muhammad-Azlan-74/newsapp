import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/card_storage_service.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:newsapp/core/constants/man_cave_overlay_coordinates.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/features/user/data/repositories/card_repository.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/features/marketplace/presentation/pages/user_cards_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/rookie_draft_screen.dart';

/// Man Cave Screen
///
/// Displays the man cave background image with interactive overlays
class ManCaveScreen extends StatefulWidget {
  const ManCaveScreen({super.key});

  @override
  State<ManCaveScreen> createState() => _ManCaveScreenState();
}

class _ManCaveScreenState extends State<ManCaveScreen> {
  bool _isLoadingCards = false;
  bool _isLoadingDraft = false;
  bool _showHelpLabels = false;
  final CardRepository _cardRepository = CardRepository(ApiClient());

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

  /// Fetch user cards from API and navigate to cards screen
  Future<void> _fetchAndShowCards() async {
    if (_isLoadingCards) return;

    setState(() {
      _isLoadingCards = true;
    });

    try {
      // Fetch cards from API and save to local DB
      final cards = await _cardRepository.fetchAndSaveUserCards();

      if (!mounted) return;

      // Navigate to cards screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserCardsScreen(cards: cards),
        ),
      );
    } on UnauthorizedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view your cards'),
          backgroundColor: Colors.red,
        ),
      );
    } on NetworkException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cards: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCards = false;
        });
      }
    }
  }

  /// Perform rookie draft and navigate to draft screen
  Future<void> _performRookieDraft() async {
    if (_isLoadingDraft) return;

    setState(() {
      _isLoadingDraft = true;
    });

    try {
      // Attempt to perform rookie draft
      final draftResponse = await _cardRepository.performRookieDraft();

      if (!mounted) return;

      // Navigate to draft screen with the new cards
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RookieDraftScreen(cards: draftResponse.data),
        ),
      );
    } on RookieDraftCooldownException catch (e) {
      if (!mounted) return;

      // Get cooldown info from local storage
      final remainingTime = await CardStorageService.getRookieDraftCooldownRemaining();
      final nextAvailable = await CardStorageService.getNextRookieDraftTime();

      if (!mounted) return;

      if (remainingTime != null) {
        // Navigate to cooldown screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RookieDraftCooldownScreen(
              remainingTime: remainingTime,
              nextAvailableTime: nextAvailable,
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on UnauthorizedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to perform rookie draft'),
          backgroundColor: Colors.red,
        ),
      );
    } on NetworkException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      // Check if it's a cooldown error from API
      if (e.message.toLowerCase().contains('20 minutes') ||
          e.message.toLowerCase().contains('once every') ||
          e.message.toLowerCase().contains('cooldown')) {
        // Try to show cooldown screen
        final remainingTime = await CardStorageService.getRookieDraftCooldownRemaining();
        final nextAvailable = await CardStorageService.getNextRookieDraftTime();

        if (!mounted) return;

        if (remainingTime != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RookieDraftCooldownScreen(
                remainingTime: remainingTime,
                nextAvailableTime: nextAvailable,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to perform rookie draft: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDraft = false;
        });
      }
    }
  }

  /// Handle overlay tap based on label
  void _handleOverlayTap(String label) {
    if (label == 'Overlay 1') {
      // Fetch and show user cards
      _fetchAndShowCards();
    } else if (label == 'Overlay 2') {
      // Perform rookie draft
      _performRookieDraft();
    } else {
      // Default behavior for other overlays
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label tapped!')),
      );
    }
  }

  /// Build the list of interactive overlays
  List<BuildingOverlay> _buildOverlays() {
    final overlays = ManCaveOverlays.all;

    return overlays.map((overlay) {
      final label = overlay.label;

      return overlay.copyWith(
        customWidget: GestureDetector(
          onTap: () => _handleOverlayTap(label ?? ''),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build a help label widget (same design as marketplace labels)
  Widget _buildHelpLabel(String text) {
    return AnimatedOpacity(
      opacity: _showHelpLabels ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                fontSize: 10,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate label positions based on overlay coordinates (positioned at top of overlay)
    // Overlay 1 (All Cards): left: 0.65, top: 0.08, width: 0.2, height: 0.37
    // Overlay 2 (Rookie Draft): left: 0.47, top: 0.5, width: 0.38, height: 0.13
    final overlay1Left = 0.65 * screenWidth + 5;
    final overlay1Top = 0.08 * screenHeight + 5;
    final overlay2Left = 0.47 * screenWidth + 5;
    final overlay2Top = 0.5 * screenHeight + 5;

    return Scaffold(
      body: Stack(
        children: [
          ImageRelativeBackground(
            imagePath: AppAssets.manCave,
            opacity: AppConstants.dashboardBackgroundOpacity,
            overlays: _buildOverlays(),
            child: Container(),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: const GlassyBackButton(),
          ),
          // Help button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: GlassyHelpButton(onPressed: _toggleHelpLabels),
          ),
          // Help label for Overlay 1 (All Cards)
          if (_showHelpLabels)
            Positioned(
              left: overlay1Left,
              top: overlay1Top,
              child: _buildHelpLabel('All Cards'),
            ),
          // Help label for Overlay 2 (Rookie Draft)
          if (_showHelpLabels)
            Positioned(
              left: overlay2Left,
              top: overlay2Top,
              child: _buildHelpLabel('Rookie Draft'),
            ),
        ],
      ),
    );
  }
}
