import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';

/// A flippable game card widget with info button
/// Shows full card image on front and stats on back
class FlippableGameCard extends StatefulWidget {
  final UserCard card;
  final bool isSelected;
  final bool canSelect;
  final bool isUsedInOtherLineup;
  final bool isDuplicateCardId;
  final VoidCallback? onTap;
  final int? selectionIndex;
  final String? otherLineupLabel;
  final Color? otherLineupColor;

  const FlippableGameCard({
    super.key,
    required this.card,
    this.isSelected = false,
    this.canSelect = true,
    this.isUsedInOtherLineup = false,
    this.isDuplicateCardId = false,
    this.onTap,
    this.selectionIndex,
    this.otherLineupLabel,
    this.otherLineupColor,
  });

  @override
  State<FlippableGameCard> createState() => _FlippableGameCardState();
}

class _FlippableGameCardState extends State<FlippableGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  /// Show large card back overlay when info button is tapped
  void _showLargeCardBack() {
    final tierColor = _getTierColor(widget.card.tier);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Card Details',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LargeCardBackOverlay(
          card: widget.card,
          tierColor: tierColor,
          animation: animation,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(widget.card.tier);

    return GestureDetector(
      onTap: widget.canSelect && !_showBack ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * math.pi;
          final showBack = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardBack(tierColor),
                  )
                : _buildCardFront(tierColor),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(Color tierColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isUsedInOtherLineup
              ? (widget.otherLineupColor ?? Colors.grey)
              : (widget.isSelected ? Colors.green : Colors.transparent),
          width: widget.isSelected || widget.isUsedInOtherLineup ? 3 : 0,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Stack(
        children: [
          // Full card image
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.isSelected ? 5 : 8),
            child: widget.card.imageUrl != null &&
                    widget.card.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.card.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildCardPlaceholder(tierColor),
                  )
                : _buildCardPlaceholder(tierColor),
          ),
          // Info button (top right) - shows large card back overlay
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _showLargeCardBack,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          // Selection overlay for cards that can't be selected (max reached)
          if (!widget.canSelect &&
              !widget.isSelected &&
              !widget.isUsedInOtherLineup &&
              !widget.isDuplicateCardId)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          // Overlay for cards with duplicate cardId
          if (widget.isDuplicateCardId)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.amber,
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'SAME TYPE',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Overlay for cards used in other lineup
          if (widget.isUsedInOtherLineup)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.otherLineupLabel == 'DEF'
                              ? Icons.shield
                              : Icons.sports_mma,
                          color: widget.otherLineupColor ?? Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.otherLineupLabel ?? '',
                          style: TextStyle(
                            color: widget.otherLineupColor ?? Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Selection badge (top left)
          if (widget.isSelected && widget.selectionIndex != null)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    widget.selectionIndex.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Color tierColor) {
    final displayName = widget.card.cardName.isNotEmpty
        ? widget.card.cardName
        : (widget.card.position ?? widget.card.cardType.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tierColor.withOpacity(0.3),
                const Color(0xFF1A1A2E),
                const Color(0xFF0F0F1A),
              ],
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card name
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Position & Tier badges
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (widget.card.position != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.card.position!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (widget.card.tier != null ||
                              widget.card.type != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tierColor.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (widget.card.tier ?? widget.card.type ?? '')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: tierColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Team
                      if (widget.card.team != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.shield,
                                  color: Colors.white.withOpacity(0.6), size: 12),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.card.team!.name,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Base & Max stats
                      if (widget.card.base != null || widget.card.max != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              if (widget.card.base != null)
                                _buildStatChip(
                                    'Base', '${widget.card.base}', Colors.blue),
                              if (widget.card.base != null &&
                                  widget.card.max != null)
                                const SizedBox(width: 6),
                              if (widget.card.max != null)
                                _buildStatChip(
                                    'Max', '${widget.card.max}', Colors.green),
                            ],
                          ),
                        ),
                      // Stats section
                      if (widget.card.stats != null &&
                          widget.card.stats!.isNotEmpty) ...[
                        Text(
                          'STATS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...widget.card.stats!.take(4).map(
                              (stat) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stat.statName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${stat.statValue}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                      // Boost section (for synergy cards)
                      if (widget.card.boost != null &&
                          widget.card.boost!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'BOOST',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...widget.card.boost!.take(3).map(
                              (boost) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        boost.stat,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '+${boost.value}',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
              // Close button (top right)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _toggleFlip,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder(Color tierColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tierColor.withOpacity(0.4),
            tierColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.card.isPlayerCard ? Icons.person : Icons.auto_awesome,
          color: Colors.white.withOpacity(0.5),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Static helper to show the large card overlay from any screen
void showLargeCardOverlay(BuildContext context, UserCard card) {
  Color getTierColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.purple;
    }
  }

  final tierColor = getTierColor(card.tier);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Card Details',
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return LargeCardBackOverlay(
        card: card,
        tierColor: tierColor,
        animation: animation,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return ScaleTransition(
        scale: curvedAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// Large card back overlay that appears when info button is tapped
class LargeCardBackOverlay extends StatefulWidget {
  final UserCard card;
  final Color tierColor;
  final Animation<double> animation;

  const LargeCardBackOverlay({
    required this.card,
    required this.tierColor,
    required this.animation,
  });

  @override
  State<LargeCardBackOverlay> createState() => LargeCardBackOverlayState();
}

class LargeCardBackOverlayState extends State<LargeCardBackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Start with a flip animation to show the card back
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _flipController.forward();
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _flipController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Card dimensions - large size for the overlay
    final cardWidth = screenSize.width * 0.75;
    final cardHeight = cardWidth * 1.4; // Card aspect ratio

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Card centered
          Center(
            child: GestureDetector(
              onTap: _closeOverlay,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, child) {
                    final angle = _flipController.value * math.pi;
                    final showBack = angle > math.pi / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: showBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildLargeCardBack(),
                            )
                          : _buildLargeCardFront(),
                    );
                  },
                ),
              ),
            ),
          ),
          // Close button at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: GestureDetector(
              onTap: _closeOverlay,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Tap anywhere to close hint
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Tap anywhere to close',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeCardFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.tierColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.card.imageUrl != null && widget.card.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.card.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildLargeCardPlaceholder(),
              )
            : _buildLargeCardPlaceholder(),
      ),
    );
  }

  Widget _buildLargeCardBack() {
    final displayName = widget.card.cardName.isNotEmpty
        ? widget.card.cardName
        : (widget.card.position ?? widget.card.cardType.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.tierColor.withOpacity(0.5),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.tierColor.withOpacity(0.4),
                const Color(0xFF1A1A2E),
                const Color(0xFF0F0F1A),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card name
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Position & Tier badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.card.position != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.card.position!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.card.tier != null || widget.card.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.tierColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.tierColor.withOpacity(0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (widget.card.tier ?? widget.card.type ?? '')
                                .toUpperCase(),
                            style: TextStyle(
                              color: widget.tierColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Team
                  if (widget.card.team != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Icon(Icons.shield,
                              color: Colors.white.withOpacity(0.7), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.card.team!.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Base & Max stats
                  if (widget.card.base != null || widget.card.max != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          if (widget.card.base != null)
                            _buildLargeStatChip(
                                'BASE', '${widget.card.base}', Colors.blue),
                          if (widget.card.base != null &&
                              widget.card.max != null)
                            const SizedBox(width: 12),
                          if (widget.card.max != null)
                            _buildLargeStatChip(
                                'MAX', '${widget.card.max}', Colors.green),
                        ],
                      ),
                    ),
                  // Stats section
                  if (widget.card.stats != null &&
                      widget.card.stats!.isNotEmpty) ...[
                    Text(
                      'STATS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.card.stats!.map(
                          (stat) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    stat.statName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${stat.statValue}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  // Boost section (for synergy cards)
                  if (widget.card.boost != null &&
                      widget.card.boost!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'BOOST',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.card.boost!.map(
                          (boost) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    boost.stat,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+${boost.value}',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeCardPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.tierColor.withOpacity(0.4),
            widget.tierColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.card.isPlayerCard ? Icons.person : Icons.auto_awesome,
          color: Colors.white.withOpacity(0.5),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildLargeStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
