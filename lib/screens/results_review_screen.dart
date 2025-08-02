import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';

/// Screen that displays detailed game results showing all 25 turns
/// with user guesses compared to correct answers
class ResultsReviewScreen extends StatelessWidget {
  /// List of game results where each entry is [userGuess, correctAnswer]
  final List<List<ZenerSymbol>> gameResults;

  /// Final score achieved in the game
  final int finalScore;

  /// Callback for navigating back to main menu (deprecated - using direct navigation)
  final VoidCallback? onBackToMenu;

  /// Callback for starting a new game (deprecated - using direct navigation)
  final VoidCallback? onPlayAgain;

  const ResultsReviewScreen({
    super.key,
    required this.gameResults,
    required this.finalScore,
    this.onBackToMenu,
    this.onPlayAgain,
  });

  /// Builds an individual result cell showing user guess vs correct answer
  Widget _buildResultCell({
    required int turnNumber,
    required ZenerSymbol userGuess,
    required ZenerSymbol correctAnswer,
    required bool isCorrect,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect ? Colors.blue.shade600 : Colors.grey.shade300,
          width: isCorrect ? 2.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(6.0),
        color: isCorrect ? Colors.blue.shade50 : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          // User guess (left side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    userGuess.iconData,
                    size: 22,
                    color: isCorrect
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),

          // Visual separator
          Container(
            width: 1.5,
            height: double.infinity,
            color: isCorrect ? Colors.blue.shade300 : Colors.grey.shade400,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
          ),

          // Correct answer (right side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    correctAnswer.iconData,
                    size: 22,
                    color: isCorrect
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an empty cell for cases where we have fewer than 25 results
  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.grey.shade100,
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Handles back navigation with fallback options
  void _handleBackNavigation(BuildContext context) {
    debugPrint('ResultsReviewScreen: Back navigation button pressed');
    try {
      // Use direct navigation instead of callback to avoid disposed widget issues
      debugPrint('ResultsReviewScreen: Navigating directly to main menu');
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      debugPrint('Error handling back navigation: $e');
      // Fallback: try callback if direct navigation fails
      try {
        if (onBackToMenu != null) {
          debugPrint('ResultsReviewScreen: Trying callback as fallback');
          onBackToMenu!();
        } else {
          Navigator.of(context).pop();
        }
      } catch (popError) {
        debugPrint('Error with fallback navigation: $popError');
      }
    }
  }

  /// Handles play again action with fallback options
  void _handlePlayAgain(BuildContext context) {
    debugPrint('ResultsReviewScreen: Play again button pressed');
    try {
      // Use direct navigation instead of callback to avoid disposed widget issues
      debugPrint('ResultsReviewScreen: Navigating directly to new game');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/zener-game', (route) => false);
    } catch (e) {
      debugPrint('Error handling play again: $e');
      // Fallback: try callback if direct navigation fails
      try {
        if (onPlayAgain != null) {
          debugPrint('ResultsReviewScreen: Trying callback as fallback');
          onPlayAgain!();
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (popError) {
        debugPrint('Error with fallback play again: $popError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackNavigation(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Score summary section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Score:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$finalScore/25',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Results grid
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Turn-by-Turn Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5x5 Results grid
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate cell size based on available space
                              final availableWidth = constraints.maxWidth;
                              final cellSize = (availableWidth / 5).clamp(
                                60.0,
                                120.0,
                              );

                              return Center(
                                child: SizedBox(
                                  width: cellSize * 5,
                                  height: cellSize * 5,
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          childAspectRatio: 1.0,
                                          crossAxisSpacing: 2.0,
                                          mainAxisSpacing: 2.0,
                                        ),
                                    itemCount: 25,
                                    itemBuilder: (context, index) {
                                      // Handle cases where we might have fewer than 25 results
                                      if (index >= gameResults.length) {
                                        return _buildEmptyCell();
                                      }

                                      final result = gameResults[index];
                                      final userGuess = result[0];
                                      final correctAnswer = result[1];
                                      final isCorrect =
                                          userGuess == correctAnswer;

                                      return _buildResultCell(
                                        turnNumber: index + 1,
                                        userGuess: userGuess,
                                        correctAnswer: correctAnswer,
                                        isCorrect: isCorrect,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons section
              const SizedBox(height: 16),
              Column(
                children: [
                  // Play Again button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handlePlayAgain(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

                  const SizedBox(height: 12),

                  // Back to Main Menu button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleBackNavigation(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Back to Main Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
