import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';
import '../database/services/game_database_service.dart';
import '../database/converters/game_data_converter.dart';
import '../database/database_exceptions.dart';
import '../widgets/svg_symbol.dart';
import '../services/high_scores_service.dart';

/// Screen that displays detailed game results showing all 25 turns
/// with user guesses compared to correct answers
class ResultsReviewScreen extends StatefulWidget {
  /// List of game results where each entry is [userGuess, correctAnswer]
  final List<List<ZenerSymbol>> gameResults;

  /// Final score achieved in the game
  final int finalScore;

  /// Remote viewing coordinates for the game session
  final String coordinates;

  /// Callback for navigating back to main menu (deprecated - using direct navigation)
  final VoidCallback? onBackToMenu;

  /// Callback for starting a new game (deprecated - using direct navigation)
  final VoidCallback? onPlayAgain;

  const ResultsReviewScreen({
    super.key,
    required this.gameResults,
    required this.finalScore,
    required this.coordinates,
    this.onBackToMenu,
    this.onPlayAgain,
  });

  @override
  State<ResultsReviewScreen> createState() => _ResultsReviewScreenState();
}

class _ResultsReviewScreenState extends State<ResultsReviewScreen> {
  final GameDatabaseService _databaseService = GameDatabaseService.instance;
  bool _isSaving = false;
  bool _saveCompleted = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    // Automatically save the game data when the screen is initialized
    _saveGameData();

    // Also attempt to save high score remotely (non-blocking) when applicable
    _trySaveHighScoreRemote();
  }

  /// Saves the game data to the local database
  /// Handles errors gracefully and provides user feedback
  Future<void> _saveGameData() async {
    if (_isSaving || _saveCompleted) {
      return; // Prevent duplicate saves
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      // Convert the game results to a GameSession using the converter
      final gameSession = GameDataConverter.fromResultsReviewData(
        gameResults: widget.gameResults,
        finalScore: widget.finalScore,
        coordinates: widget.coordinates,
      );

      // Save to database
      await _databaseService.saveGameSession(gameSession);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveCompleted = true;
        });
      }

      debugPrint('Game data saved successfully to database');
    } catch (e) {
      debugPrint('Error saving game data to database: $e');

      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = _getErrorMessage(e);
        });
      }
    }
  }

  /// Converts database exceptions to user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'Failed to save game data: ${error.message}';
    }
    return 'Failed to save game data. Please try again.';
  }

  /// Retries saving the game data if it failed initially
  Future<void> _retrySave() async {
    await _saveGameData();
  }

  /// Attempts to save a qualifying high score (>= 11) to Supabase.
  /// Silent and non-blocking; logs in debug mode only.
  Future<void> _trySaveHighScoreRemote() async {
    try {
      final score = widget.finalScore;
      if (score < 11) return;

      // Use current time in UTC for explicitness; server has default now() if omitted.
      await HighScoresService.instance.insertHighScore(
        score: score,
        recordedAtUtc: DateTime.now().toUtc(),
      );
    } catch (e) {
      // Silent failure per requirements; do not surface to user
      debugPrint('ResultsReviewScreen: Failed to save remote high score: $e');
    }
  }

  /// Builds an individual result cell showing user guess vs correct answer
  Widget _buildResultCell({
    required int turnNumber,
    required ZenerSymbol userGuess,
    required ZenerSymbol correctAnswer,
    required bool isCorrect,
  }) {
    final Color bg = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
    final Color border = isCorrect
        ? Colors.green.shade600
        : Colors.red.shade600;
    final Color divider = isCorrect
        ? Colors.green.shade400
        : Colors.red.shade400;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
        color: bg,
      ),
      child: Row(
        children: [
          // User guess (left side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [SvgSymbol(assetPath: userGuess.assetPath, size: 22)],
              ),
            ),
          ),

          // Visual separator
          Container(
            width: 1.5,
            height: double.infinity,
            color: divider,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
          ),

          // Correct answer (right side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgSymbol(assetPath: correctAnswer.assetPath, size: 22),
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
        if (widget.onBackToMenu != null) {
          debugPrint('ResultsReviewScreen: Trying callback as fallback');
          widget.onBackToMenu!();
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
        if (widget.onPlayAgain != null) {
          debugPrint('ResultsReviewScreen: Trying callback as fallback');
          widget.onPlayAgain!();
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
                        '${widget.finalScore}/25',
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

              // Save status indicator
              if (_isSaving || _saveError != null || _saveCompleted)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        if (_isSaving) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          const Text('Saving game data...'),
                        ] else if (_saveError != null) ...[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _saveError!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: _retrySave,
                            child: const Text('Retry'),
                          ),
                        ] else if (_saveCompleted) ...[
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text('Game data saved successfully'),
                        ],
                      ],
                    ),
                  ),
                ),
              if (_isSaving || _saveError != null || _saveCompleted)
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
                                      if (index >= widget.gameResults.length) {
                                        return _buildEmptyCell();
                                      }

                                      final result = widget.gameResults[index];
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
