import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/core/services/team_image_cache_service.dart';

/// Team Avatar Widget
///
/// Displays the user's selected team avatar in the bottom left corner
/// Can be used across all screens
class TeamAvatarWidget extends StatefulWidget {
  /// The type of team image to display (main, anchor, doctor, newspaper)
  final String imageType;

  /// Callback when avatar is tapped
  final VoidCallback? onTap;

  const TeamAvatarWidget({
    super.key,
    this.imageType = 'main',
    this.onTap,
  });

  @override
  State<TeamAvatarWidget> createState() => _TeamAvatarWidgetState();
}

class _TeamAvatarWidgetState extends State<TeamAvatarWidget> {
  String? _teamLogoPath;
  String? _teamName;
  String? _teamCode;
  bool _isNetworkImage = false;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    // Get selected team name
    final teamName = await AuthStorageService.getSelectedTeam();

    if (teamName != null && teamName.isNotEmpty) {
      final teamCode = _getTeamCode(teamName);

      // Try to get cached image from API first
      final cachedImagePath = await TeamImageCacheService.getCachedImagePath(
        teamCode,
        widget.imageType,
      );

      if (cachedImagePath != null && await File(cachedImagePath).exists()) {
        // Use cached network image
        setState(() {
          _teamName = teamName;
          _teamCode = teamCode;
          _teamLogoPath = cachedImagePath;
          _isNetworkImage = true;
        });
      } else {
        // Fallback to local asset
        final assetPath = _getTeamAssetLogo(teamName);
        setState(() {
          _teamName = teamName;
          _teamCode = teamCode;
          _teamLogoPath = assetPath;
          _isNetworkImage = false;
        });
      }
    } else {
      // Fallback to user data
      final userData = await AuthStorageService.getUserData();

      if (userData != null && userData['selectedTeam'] != null) {
        final teamNameFromData = userData['selectedTeam'] as String;
        final teamCode = _getTeamCode(teamNameFromData);

        // Try cached image
        final cachedImagePath = await TeamImageCacheService.getCachedImagePath(
          teamCode,
          widget.imageType,
        );

        if (cachedImagePath != null && await File(cachedImagePath).exists()) {
          setState(() {
            _teamName = teamNameFromData;
            _teamCode = teamCode;
            _teamLogoPath = cachedImagePath;
            _isNetworkImage = true;
          });
        } else {
          // Fallback to asset
          final assetPath = _getTeamAssetLogo(teamNameFromData);
          setState(() {
            _teamName = teamNameFromData;
            _teamCode = teamCode;
            _teamLogoPath = assetPath;
            _isNetworkImage = false;
          });
        }

        // Save it separately for next time
        await AuthStorageService.saveSelectedTeam(teamNameFromData);
      }
    }
  }

  String _getTeamCode(String teamIdOrName) {
    // Handle team IDs
    switch (teamIdOrName) {
      case '6947a3a8d9ba1ed105c021c1':
        return 'KC';
      case '6947a3a8d9ba1ed105c021c2':
        return 'DEN';
      case '6947a3a8d9ba1ed105c021c3':
        return 'LV';
      case '6947a3a8d9ba1ed105c021c4':
        return 'LAC';
    }

    // Handle team names (legacy support)
    switch (teamIdOrName) {
      case 'Kansas City Chiefs':
        return 'KC';
      case 'Denver Broncos':
        return 'DEN';
      case 'Las Vegas Raiders':
        return 'LV';
      case 'Los Angeles Chargers':
        return 'LAC';
      default:
        return 'TEAM';
    }
  }

  String _getTeamAssetLogo(String teamIdOrName) {
    // Team logos removed - return app logo as fallback
    return AppAssets.appLogo;
  }

  @override
  Widget build(BuildContext context) {
    if (_teamLogoPath == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 20,
      bottom: 30,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: _isNetworkImage
                ? Image.file(
                    File(_teamLogoPath!),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackIcon();
                    },
                  )
                : Image.asset(
                    _teamLogoPath!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackIcon();
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[800],
      child: const Icon(
        Icons.person,
        size: 75,
        color: Colors.white,
      ),
    );
  }
}
