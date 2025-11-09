import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/deck.dart';

/// Widget to display a deck as a card
class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? dueCardsCount;

  const DeckCard({
    super.key,
    required this.deck,
    this.onTap,
    this.onLongPress,
    this.dueCardsCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = deck.color != null
        ? Color(int.parse(deck.color!.replaceFirst('#', '0xFF')))
        : AppColors.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (deck.icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            deck.icon!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    if (deck.icon != null) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deck.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (deck.description != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              deck.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoChip(
                      icon: Icons.collections_bookmark_rounded,
                      label: '${deck.cardCount} cards',
                      color: AppColors.gray600,
                    ),
                    if (dueCardsCount != null && dueCardsCount! > 0)
                      _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: '$dueCardsCount due',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
