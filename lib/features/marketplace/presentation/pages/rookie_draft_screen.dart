import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';

/// Rookie Draft Screen
///
/// Displays the drafted cards with reveal animation
class RookieDraftScreen extends StatefulWidget {
  final List<UserCard> cards;

  const RookieDraftScreen({
    super.key,
    required this.cards,
  });

  @override
  State<RookieDraftScreen> createState() => _RookieDraftScreenState();
}

class _RookieDraftScreenState extends State<RookieDraftScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  late List<bool> _isRevealed;
  bool _allRevealed = false;

  @override
  void initState() {
    super.initState();
    _isRevealed = List.generate(widget.cards.length, (_) => false);
    _flipControllers = List.generate(
      widget.cards.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _flipAnimations = _flipControllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _flipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _revealCard(int index) {
    if (_isRevealed[index]) return;

    setState(() {
      _isRevealed[index] = true;
    });
    _flipControllers[index].forward();

    // Check if all cards are revealed
    if (_isRevealed.every((revealed) => revealed)) {
      setState(() {
        _allRevealed = true;
      });
    }
  }

  void _revealAllCards() {
    for (int i = 0; i < widget.cards.length; i++) {
      if (!_isRevealed[i]) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) _revealCard(i);
        });
      }
    }
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
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              AppAssets.manCave,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for better text readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GlassyBackButton(),
                  ),
                  title: const Text(
                    'My Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    if (!_allRevealed)
                      TextButton(
                        onPressed: _revealAllCards,
                        child: const Text(
                          'Reveal All',
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: GlassyHelpButton(),
                    ),
                  ],
                ),
                // Header text
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _allRevealed
                        ? 'Congratulations! Here are your new cards!'
                        : 'Tap each card to reveal!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Cards grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: widget.cards.length,
                      itemBuilder: (context, index) {
                        final card = widget.cards[index];
                        return GestureDetector(
                          onTap: () => _revealCard(index),
                          child: AnimatedBuilder(
                            animation: _flipAnimations[index],
                            builder: (context, child) {
                              final angle = _flipAnimations[index].value * 3.14159;
                              final isBack = angle > 3.14159 / 2;

                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                child: isBack
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(3.14159),
                                        child: _buildCardFront(card, index),
                                      )
                                    : _buildCardBack(index),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Stats summary after all revealed
                if (_allRevealed) _buildStatsSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D44),
            Color(0xFF1A1A2E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.amber,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to Reveal',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Card ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(UserCard card, int index) {
    final tierColor = _getTierColor(card.tier);
    final isSynergy = card.isSynergyCard;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.3),
            const Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: card.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: Icon(
                            isSynergy ? Icons.auto_awesome : Icons.person,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),
                // New badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Card name
                  Text(
                    card.cardName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Type badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSynergy
                              ? Colors.purple.withValues(alpha: 0.3)
                              : Colors.blue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          card.cardType.toUpperCase(),
                          style: TextStyle(
                            color: isSynergy ? Colors.purple[200] : Colors.blue[200],
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (card.tier != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            card.tier!.toUpperCase(),
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Position or synergy type
                  if (card.position != null || card.type != null)
                    Text(
                      card.position ?? card.type ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  // Stats preview for player cards
                  if (card.isPlayerCard && card.base != null && card.max != null)
                    Row(
                      children: [
                        Text(
                          'Base: ${card.base}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Max: ${card.max}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final playerCards = widget.cards.where((c) => c.isPlayerCard).toList();
    final synergyCards = widget.cards.where((c) => c.isSynergyCard).toList();

    // Count tiers
    final tierCounts = <String, int>{};
    for (final card in playerCards) {
      if (card.tier != null) {
        tierCounts[card.tier!] = (tierCounts[card.tier!] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Draft Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Player Cards',
                playerCards.length.toString(),
                Colors.blue,
              ),
              _buildSummaryItem(
                'Synergy Cards',
                synergyCards.length.toString(),
                Colors.purple,
              ),
            ],
          ),
          if (tierCounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: tierCounts.entries.map((entry) {
                return _buildTierBadge(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTierBadge(String tier, int count) {
    final color = _getTierColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$count $tier',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Cooldown screen shown when rookie draft is not available
class RookieDraftCooldownScreen extends StatelessWidget {
  final Duration remainingTime;
  final DateTime? nextAvailableTime;

  const RookieDraftCooldownScreen({
    super.key,
    required this.remainingTime,
    this.nextAvailableTime,
  });

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''}, $hours hr${hours > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''}, $minutes min${minutes > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              AppAssets.manCave,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for better text readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GlassyBackButton(),
                  ),
                  title: const Text(
                    'My Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: GlassyHelpButton(),
                    ),
                  ],
                ),
                // Body content
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Timer icon
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.5),
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.timer,
                              color: Colors.orange,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          const Text(
                            'Draft on Cooldown',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          const Text(
                            'You can only perform a rookie draft once every 20 minutes.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Time remaining
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Time Remaining',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDuration(remainingTime),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (nextAvailableTime != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Next draft available on:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(nextAvailableTime!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$month $day at $hour12:$minute $period';
  }
}
