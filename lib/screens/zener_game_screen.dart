import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/zener_symbol.dart';
import '../models/guess_result.dart';
import '../widgets/symbol_selection_widget.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/card_reveal_widget.dart';
import '../widgets/final_score_dialog.dart';

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
  bool _debugMode = false;

  // Timers for managing turn transitions and feedback
  Timer? _turnTransitionTimer;
  Timer? _feedbackTimer;
  Timer? _scoreUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _turnTransitionTimer?.cancel();
    _feedbackTimer?.cancel();
    _scoreUpdateTimer?.cancel();
    super.dispose();
  }

  /// Initializes a new game with fresh state
  void _initializeGame() {
    try {
      _gameController = GameController();
      setState(() {
        _currentScore = _gameController.getCurrentScore();
        _currentTurn = _gameController.getCurrentTurn();
        _buttonsEnabled = true;
        _revealedSymbol = null;
        _feedbackMessage = null;
        _isCardRevealed = false;
        // Note: _debugMode is intentionally not reset to preserve user preference
      });
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Error initializing game: $e');
      // Fallback to safe default state
      setState(() {
        _currentScore = 0;
        _currentTurn = 1;
        _buttonsEnabled = false;
        _revealedSymbol = null;
        _feedbackMessage = 'Error initializing game. Please restart.';
        _isCardRevealed = false;
      });
    }
  }

  /// Handles symbol selection from the user
  void _onSymbolSelected(ZenerSymbol selectedSymbol) {
    if (!_buttonsEnabled || _gameController.isGameComplete()) {
      return;
    }

    // Disable buttons immediately during guess processing
    setState(() {
      _buttonsEnabled = false;
    });

    try {
      // Process the guess
      final GuessResult result = _gameController.makeGuess(selectedSymbol);

      // Update UI with card reveal first (immediate)
      setState(() {
        _revealedSymbol = result.correctSymbol;
        _isCardRevealed = true;
        _feedbackMessage = _generateFeedbackMessage(result);
      });

      // Update score immediately if correct (as per requirement 4.2)
      if (result.isCorrect) {
        setState(() {
          _currentScore = result.newScore;
        });
      } else {
        // For incorrect guesses, delay score update slightly for better UX
        _scoreUpdateTimer?.cancel();
        _scoreUpdateTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _currentScore = result.newScore;
            });
          }
        });
      }

      // Update turn counter after a brief delay for smooth transition
      _scoreUpdateTimer?.cancel();
      _scoreUpdateTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _currentTurn = _gameController.getCurrentTurn();
          });
        }
      });

      // Check if game is complete
      if (_gameController.isGameComplete()) {
        _handleGameCompletion();
      } else {
        // Set timer for turn transition with improved timing
        _startTurnTransition();
      }
    } catch (e) {
      // Handle guess processing errors gracefully
      debugPrint('Error processing guess: $e');
      setState(() {
        _buttonsEnabled = true;
        _feedbackMessage = 'Error processing guess. Please try again.';
        _isCardRevealed = false;
        _revealedSymbol = null;
      });

      // Clear error message after a delay
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _feedbackMessage = null;
          });
        }
      });
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

  /// Starts the turn transition timer with improved timing sequence
  void _startTurnTransition() {
    _turnTransitionTimer?.cancel();

    // Phase 1: Show feedback for 1.5 seconds (requirement 3.3)
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _beginTurnReset();
      }
    });
  }

  /// Begins the turn reset sequence with smooth transitions
  void _beginTurnReset() {
    // Phase 2: Start hiding feedback and card (smooth transition)
    setState(() {
      _feedbackMessage = null;
    });

    // Phase 3: Hide card after brief delay for smooth animation
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isCardRevealed = false;
          _revealedSymbol = null;
        });
      }
    });

    // Phase 4: Re-enable buttons after card is hidden (requirement 6.4)
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _buttonsEnabled = true;
        });
      }
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
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return FinalScoreDialog(
            score: _currentScore,
            onPlayAgain: _playAgain,
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing final score dialog: $e');
      // Fallback: just reset the game
      _playAgain();
    }
  }

  /// Starts a new game
  void _playAgain() {
    Navigator.of(context).pop(); // Close dialog

    // Cancel all timers to ensure clean state
    _turnTransitionTimer?.cancel();
    _feedbackTimer?.cancel();
    _scoreUpdateTimer?.cancel();

    _initializeGame();
  }

  /// Toggles debug mode on/off
  void _toggleDebugMode() {
    setState(() {
      _debugMode = !_debugMode;
    });
  }

  /// Gets the next three cards in the deck for debug display
  List<ZenerSymbol> _getNextThreeCards() {
    final List<ZenerSymbol> nextCards = [];
    final deck = _gameController.gameState.deck;

    for (int i = 0; i < 3; i++) {
      final cardIndex = (_currentTurn - 1) + i;
      if (cardIndex < deck.length) {
        nextCards.add(deck[cardIndex]);
      }
    }

    return nextCards;
  }

  /// Builds the debug panel showing next three cards
  Widget _buildDebugPanel() {
    if (!_debugMode) return const SizedBox.shrink();

    final nextCards = _getNextThreeCards();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red.shade700, size: 16),
              const SizedBox(width: 4),
              Text(
                'DEBUG MODE',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Next cards:',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: nextCards.asMap().entries.map((entry) {
              final index = entry.key;
              final symbol = entry.value;
              final turnNumber = _currentTurn + index;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.red.shade100 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: index == 0
                        ? Colors.red.shade400
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$turnNumber:',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: index == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(symbol.iconData, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 2),
                    Text(
                      symbol.displayName,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: index == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: const Text('Psychic Tournament'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Debug mode toggle with animation
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.bug_report,
                    size: 16,
                    color: _debugMode
                        ? Colors.red.shade700
                        : Theme.of(context).colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Switch(
                    key: ValueKey(_debugMode),
                    value: _debugMode,
                    onChanged: (_) => _toggleDebugMode(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeThumbColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Game info section with animations
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use column layout on very narrow screens
                      if (constraints.maxWidth < 300) {
                        return Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.5, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: ScoreDisplayWidget(
                                key: ValueKey(_currentScore),
                                score: _currentScore,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).shadowColor.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  'Turn $_currentTurn / 25',
                                  key: ValueKey(_currentTurn),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Use row layout for wider screens with flexible widgets
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.5, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: ScoreDisplayWidget(
                                key: ValueKey(_currentScore),
                                score: _currentScore,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).shadowColor.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  'Turn $_currentTurn / 25',
                                  key: ValueKey(_currentTurn),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Debug panel with slide animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildDebugPanel(),
                ),

                // Remote viewing coordinates with subtle animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).shadowColor.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Coordinates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ) ??
                            const TextStyle(),
                        child: Text(
                          _gameController.getRemoteViewingCoordinates(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Card reveal area with enhanced animations
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: CardRevealWidget(
                    revealedSymbol: _revealedSymbol,
                    isRevealed: _isCardRevealed,
                    feedbackMessage: _feedbackMessage,
                  ),
                ),

                const SizedBox(height: 64),

                // Symbol selection area with staggered animations
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  child: SymbolSelectionWidget(
                    onSymbolSelected: _onSymbolSelected,
                    buttonsEnabled: _buttonsEnabled,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
