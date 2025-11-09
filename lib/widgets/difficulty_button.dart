import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Button for selecting card difficulty during review
class DifficultyButton extends StatelessWidget {
  final CardDifficulty difficulty;
  final VoidCallback onPressed;
  final String? subtitle;

  const DifficultyButton({
    super.key,
    required this.difficulty,
    required this.onPressed,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: difficulty.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            difficulty.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
