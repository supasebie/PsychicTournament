import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';

/// Dialog widget that displays the final score and provides play again functionality
class FinalScoreDialog extends StatefulWidget {
  /// The final score achieved by the player
  final int score;

  /// Callback function to handle play again action
  final VoidCallback onPlayAgain;

  /// Optional game results data for detailed review
  final List<List<ZenerSymbol>>? gameResults;

  /// Optional callback for viewing detailed results
  final VoidCallback? onViewResults;

  /// Creates a FinalScoreDialog with the given score and play again callback
  const FinalScoreDialog({
    super.key,
    required this.score,
    required this.onPlayAgain,
    this.gameResults,
    this.onViewResults,
  });

  @override
  State<FinalScoreDialog> createState() => _FinalScoreDialogState();
}

class _FinalScoreDialogState extends State<FinalScoreDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _iconController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.bounceOut),
    );

    // Start animations with staggered timing
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _iconController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Game Complete!', textAlign: TextAlign.center),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon with rotation and scale
              AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconAnimation.value,
                    child: Transform.rotate(
                      angle: _iconAnimation.value * 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: widget.score >= 13
                                ? [Colors.amber.shade300, Colors.amber.shade600]
                                : [Colors.blue.shade300, Colors.blue.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (widget.score >= 13
                                          ? Colors.amber
                                          : Colors.blue)
                                      .withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.score >= 13 ? Icons.star : Icons.psychology,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Score display with counter animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'You scored ${widget.score} out of 25',
                  key: ValueKey(widget.score),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // Score description with fade-in
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _iconAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(widget.score).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getScoreColor(
                        widget.score,
                      ).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getScoreDescription(widget.score),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getScoreColor(widget.score),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Score percentage
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _iconAnimation.value,
                child: Text(
                  '${((widget.score / 25) * 100).round()}% accuracy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // View Detailed Results button (only shown when gameResults and callback are provided)
                  if (widget.gameResults != null &&
                      widget.onViewResults != null)
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          onPressed: widget.onViewResults,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'View Detailed Results',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Add spacing between buttons if both are shown
                  if (widget.gameResults != null &&
                      widget.onViewResults != null)
                    const SizedBox(height: 12),

                  // Play Again button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: widget.onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }

  /// Returns a description based on the final score
  String _getScoreDescription(int score) {
    if (score >= 20) return 'Exceptional psychic ability!';
    if (score >= 15) return 'Strong psychic potential!';
    if (score >= 10) return 'Good psychic awareness!';
    if (score >= 5) return 'Some psychic sensitivity detected.';
    return 'Keep practicing your psychic abilities!';
  }

  /// Returns a color based on the score performance
  Color _getScoreColor(int score) {
    if (score >= 20) return Colors.purple.shade600;
    if (score >= 15) return Colors.green.shade600;
    if (score >= 10) return Colors.blue.shade600;
    if (score >= 5) return Colors.orange.shade600;
    return Colors.grey.shade600;
  }
}
