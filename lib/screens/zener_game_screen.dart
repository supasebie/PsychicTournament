import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/zener_symbol.dart';
import '../models/guess_result.dart';
import '../widgets/symbol_selection_widget.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/card_reveal_widget.dart';

/// Main game screen that manages the complete Zener card game experience
class ZenerGameScreen extends StatefulWidget {
  const ZenerGameScreen({super.key});

  @override
  State<ZenerGameScreen> createState() => _ZenerGameScreenState();
}

class _ZenerGameScreenState extends State<ZenerGameScreen> {
  late GameController _gameController;

  // Game state variables
  int _currentScore = 0;
  int _currentTurn = 1;
  bool _buttonsEnabled = true;
  ZenerSymbol? _revealedSymbol;
  String? _feedbackMessage;
  bool _isCardRevealed = false;

  // Timer for managing turn transitions
  Timer? _turnTransitionTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _turnTransitionTimer?.cancel();
    super.dispose();
  }

  /// Initializes a new game with fresh state
  void _initializeGame() {
    _gameController = GameController();
    setState(() {
      _currentScore = _gameController.getCurrentScore();
      _currentTurn = _gameController.getCurrentTurn();
      _buttonsEnabled = true;
      _revealedSymbol = null;
      _feedbackMessage = null;
      _isCardRevealed = false;
    });
  }

  /// Handles symbol selection from the user
  void _onSymbolSelected(ZenerSymbol selectedSymbol) {
    if (!_buttonsEnabled || _gameController.isGameComplete()) {
      return;
    }

    // Disable buttons during guess processing
    setState(() {
      _buttonsEnabled = false;
    });

    // Process the guess
    final GuessResult result = _gameController.makeGuess(selectedSymbol);

    // Update UI with guess result
    setState(() {
      _currentScore = result.newScore;
      _currentTurn = _gameController.getCurrentTurn();
      _revealedSymbol = result.correctSymbol;
      _isCardRevealed = true;
      _feedbackMessage = _generateFeedbackMessage(result);
    });

    // Check if game is complete
    if (_gameController.isGameComplete()) {
      _handleGameCompletion();
    } else {
      // Set timer for turn transition
      _startTurnTransition();
    }
  }

  /// Generates appropriate feedback message based on guess result
  String _generateFeedbackMessage(GuessResult result) {
    if (result.isCorrect) {
      return 'Correct!';
    } else {
      return 'Incorrect. The card was a ${result.correctSymbol.displayName}';
    }
  }

  /// Starts the turn transition timer
  void _startTurnTransition() {
    _turnTransitionTimer?.cancel();
    _turnTransitionTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _resetForNextTurn();
      }
    });
  }

  /// Resets UI state for the next turn
  void _resetForNextTurn() {
    setState(() {
      _revealedSymbol = null;
      _feedbackMessage = null;
      _isCardRevealed = false;
      _buttonsEnabled = true;
    });
  }

  /// Handles game completion and shows final score
  void _handleGameCompletion() {
    // Show final score dialog after a brief delay
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _showFinalScoreDialog();
      }
    });
  }

  /// Shows the final score dialog with play again option
  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Game Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _currentScore >= 13 ? Icons.star : Icons.psychology,
                size: 48,
                color: _currentScore >= 13 ? Colors.amber : Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'You scored $_currentScore out of 25',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreDescription(_currentScore),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _playAgain,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
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

  /// Starts a new game
  void _playAgain() {
    Navigator.of(context).pop(); // Close dialog
    _turnTransitionTimer?.cancel();
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Psychic Tournament',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Game info section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScoreDisplayWidget(score: _currentScore),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Turn $_currentTurn / 25',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Remote viewing coordinates
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Remote Viewing Coordinates',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gameController.getRemoteViewingCoordinates(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Card reveal area
              CardRevealWidget(
                revealedSymbol: _revealedSymbol,
                isRevealed: _isCardRevealed,
                feedbackMessage: _feedbackMessage,
              ),

              const Spacer(),

              // Symbol selection area
              SymbolSelectionWidget(
                onSymbolSelected: _onSymbolSelected,
                buttonsEnabled: _buttonsEnabled,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
