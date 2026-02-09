import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/features/user/data/models/card_model.dart';
import 'package:newsapp/shared/widgets/flippable_game_card.dart';
import 'package:newsapp/shared/widgets/glassy_back_button.dart';
import 'package:newsapp/shared/widgets/glassy_help_button.dart';
import 'package:newsapp/shared/widgets/top_stats_strip.dart';

/// User Cards Screen
///
/// Displays the user's cards fetched from the API
/// Design will be implemented later
class UserCardsScreen extends StatelessWidget {
  final List<UserCard> cards;

  const UserCardsScreen({
    super.key,
    required this.cards,
  });

  static void _showStatsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Card Stats Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Each card has 10 stats:\n\n'
                    'Speed • Agility • Acceleration • Strength • Awareness\n'
                    'Catching • Throwing • Carrying • Tackling • Blocking\n\n'
                    'Cards come in tiers: Bronze → Silver → Gold → Legend\n'
                    'Three identical cards merge into the next tier.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Got it!'),
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
          // Light overlay for better text readability
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
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
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                ),
                // Body content
                Expanded(
                  child: cards.isEmpty
                    ? const Center(
                        child: Text(
                          'No cards found',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return _CardItem(card: card);
                        },
                      ),
                ),
              ],
            ),
          ),
          // Top stats strip
          const TopStatsStrip(),
        ],
      ),
    );
  }
}

/// Individual card item widget
class _CardItem extends StatelessWidget {
  final UserCard card;

  const _CardItem({required this.card});

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
    final tierColor = _getTierColor(card.tier);

    return GestureDetector(
      onTap: () {
        // Show card details
        _showCardDetails(context, card);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tierColor.withOpacity(0.3),
              const Color(0xFF2D2D44),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: tierColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: tierColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card image with info button
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                              card.isPlayerCard ? Icons.person : Icons.auto_awesome,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                  ),
                  // Info button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => showLargeCardOverlay(context, card),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
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
                    // Type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: card.isPlayerCard
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            card.cardType.toUpperCase(),
                            style: TextStyle(
                              color: card.isPlayerCard
                                  ? Colors.blue[200]
                                  : Colors.purple[200],
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
                              color: tierColor.withOpacity(0.3),
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
                    // Position or Type
                    if (card.position != null || card.type != null)
                      Text(
                        card.position ?? card.type ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context, UserCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _CardDetailsSheet(
          card: card,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// Card details bottom sheet
class _CardDetailsSheet extends StatelessWidget {
  final UserCard card;
  final ScrollController scrollController;

  const _CardDetailsSheet({
    required this.card,
    required this.scrollController,
  });

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
    final tierColor = _getTierColor(card.tier);

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Card image
          if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
            Center(
              child: Container(
                height: 200,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tierColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: card.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Card name and type
          Center(
            child: Text(
              card.cardName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Badges
          Center(
            child: Wrap(
              spacing: 8,
              children: [
                _buildBadge(
                  card.cardType.toUpperCase(),
                  card.isPlayerCard ? Colors.blue : Colors.purple,
                ),
                if (card.tier != null)
                  _buildBadge(card.tier!.toUpperCase(), tierColor),
                if (card.position != null)
                  _buildBadge(card.position!, Colors.green),
                if (card.type != null)
                  _buildBadge(card.type!, Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Team info
          if (card.team != null) ...[
            _buildInfoRow('Team', card.team!.name),
            const SizedBox(height: 8),
          ],

          // Base and Max stats
          if (card.base != null || card.max != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (card.base != null)
                  _buildStatCircle('BASE', card.base!, Colors.blue),
                if (card.max != null)
                  _buildStatCircle('MAX', card.max!, Colors.green),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Stats section for player cards
          if (card.stats != null && card.stats!.isNotEmpty) ...[
            const Text(
              'Stats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...card.stats!.map((stat) => _buildStatBar(stat)),
          ],

          // Boost section for synergy cards
          if (card.boost != null && card.boost!.isNotEmpty) ...[
            const Text(
              'Boosts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...card.boost!.map((boost) => _buildBoostItem(boost)),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCircle(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBar(CardStat stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.statName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                stat.statValue.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stat.statValue / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatColor(stat.statValue),
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(int value) {
    if (value >= 90) return Colors.green;
    if (value >= 75) return Colors.lightGreen;
    if (value >= 60) return Colors.yellow;
    if (value >= 45) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBoostItem(SynergyBoost boost) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              boost.stat,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${boost.value}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

