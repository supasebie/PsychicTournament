import 'package:flutter/material.dart';

/// Widget that displays the current game score in "Score: X / 25" format
class ScoreDisplayWidget extends StatelessWidget {
  /// Current score (number of correct guesses)
  final int score;

  /// Total number of cards in the game (always 25 for Zener cards)
  final int totalCards;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    this.totalCards = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        'Score: $score / $totalCards',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        semanticsLabel: 'Current score: $score out of $totalCards',
      ),
    );
  }
}
