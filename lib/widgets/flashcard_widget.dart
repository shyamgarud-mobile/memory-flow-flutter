import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/flashcard.dart';

/// Widget to display a flashcard with flip animation
class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final bool showAnswer;
  final VoidCallback? onTap;

  const FlashcardWidget({
    super.key,
    required this.card,
    this.showAnswer = false,
    this.onTap,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _showBack = widget.showAnswer;
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= 1.5708
                ? Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _buildCardSide(
                      context,
                      widget.card.back,
                      isBack: true,
                    ),
                  )
                : _buildCardSide(context, widget.card.front),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, String content,
      {bool isBack = false}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 300),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isBack)
              Icon(
                Icons.visibility_outlined,
                color: AppColors.gray400,
                size: 32,
              ),
            if (!isBack) const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (!isBack) const SizedBox(height: AppSpacing.md),
            if (!isBack)
              Text(
                'Tap to reveal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
