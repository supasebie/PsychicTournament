import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/game_controller.dart';
import '../models/zener_symbol.dart';
import '../models/guess_result.dart';
import '../widgets/symbol_selection_widget.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/card_reveal_widget.dart';
import '../widgets/final_score_dialog.dart';
import '../widgets/feedback_overlay_widget.dart';
import '../services/haptic_feedback_service.dart';
import '../services/ad_service.dart';
import 'results_review_screen.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/svg_symbol.dart';

/// Main game screen that manages the complete Zener card game experience
class ZenerGameScreen extends StatefulWidget {
  const ZenerGameScreen({super.key});

  @override
  State<ZenerGameScreen> createState() => _ZenerGameScreenState();
}

class _ZenerGameScreenState extends State<ZenerGameScreen> {
  late GameController _gameController;

  // Interstitial ad reference for after-session placement (no ads during gameplay).
  InterstitialAd? _postSessionInterstitial;

  // Game state variables
  int _currentScore = 0;
  int _currentTurn = 1;
  bool _buttonsEnabled = true;
  ZenerSymbol? _revealedSymbol;
  bool _isCardRevealed = false;
  bool _debugMode = false;

  // Hot streak tracking: number of consecutive correct guesses
  int _currentStreak = 0;

  // Enhanced feedback overlay state variables
  bool _showFeedbackOverlay = false;
  String _overlayFeedbackText = '';
  bool _isCorrectGuess = false;

  // Timers for managing turn transitions and feedback
  Timer? _turnTransitionTimer;
  Timer? _feedbackTimer;
  Timer? _scoreUpdateTimer;
  Timer? _overlayTimer;

  // Flash effect state and timer for correct guesses
  bool _flashScreen = false;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Preload interstitial for end-of-session.
    _loadPostSessionInterstitial();
  }

  @override
  void dispose() {
    // Cancel all timers to prevent memory leaks and callbacks on disposed widgets
    _turnTransitionTimer?.cancel();
    _feedbackTimer?.cancel();
    _scoreUpdateTimer?.cancel();
    _overlayTimer?.cancel();
    _flashTimer?.cancel();

    // Clear timer references
    _turnTransitionTimer = null;
    _feedbackTimer = null;
    _scoreUpdateTimer = null;
    _overlayTimer = null;
    _flashTimer = null;

    try {
      _postSessionInterstitial?.dispose();
    } catch (_) {}

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
        _isCardRevealed = false;
        // Reset enhanced feedback overlay state
        _showFeedbackOverlay = false;
        _overlayFeedbackText = '';
        _isCorrectGuess = false;
        // Reset hot streak state
        _currentStreak = 0;
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
        _isCardRevealed = false;
      });
    }
  }

  /// Handles symbol selection from the user
  void _onSymbolSelected(ZenerSymbol selectedSymbol) {
    if (!_buttonsEnabled || _gameController.isGameComplete()) {
      return;
    }

    // Cancel any existing overlay timer to handle rapid interactions
    _overlayTimer?.cancel();

    // Disable buttons immediately during guess processing
    setState(() {
      _buttonsEnabled = false;
      // Hide any existing overlay to prevent conflicts
      _showFeedbackOverlay = false;
    });

    try {
      // Process the guess
      final GuessResult result = _gameController.makeGuess(selectedSymbol);

      // Update UI with card reveal first (immediate)
      setState(() {
        _revealedSymbol = result.correctSymbol;
        _isCardRevealed = true;
      });

      // Update hot streak before showing feedback
      if (result.isCorrect) {
        _currentStreak += 1;
      } else {
        _currentStreak = 0;
      }

      // Show enhanced feedback overlay
      _showEnhancedFeedback(result);

      // Update score immediately if correct (as per requirement 4.2)
      if (result.isCorrect) {
        setState(() {
          _currentScore = result.newScore;
        });
      } else {
        // For incorrect guesses, delay score update slightly for better UX
        try {
          _scoreUpdateTimer?.cancel();
          _scoreUpdateTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              try {
                setState(() {
                  _currentScore = result.newScore;
                });
              } catch (e) {
                debugPrint('Error updating score: $e');
              }
            }
          });
        } catch (e) {
          debugPrint('Error setting score update timer: $e');
          // Fallback: update score immediately
          if (mounted) {
            setState(() {
              _currentScore = result.newScore;
            });
          }
        }
      }

      // Update turn counter after a brief delay for smooth transition
      try {
        _scoreUpdateTimer?.cancel();
        _scoreUpdateTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            try {
              setState(() {
                _currentTurn = _gameController.getCurrentTurn();
              });
            } catch (e) {
              debugPrint('Error updating turn: $e');
            }
          }
        });
      } catch (e) {
        debugPrint('Error setting turn update timer: $e');
        // Fallback: update turn immediately
        if (mounted) {
          setState(() {
            _currentTurn = _gameController.getCurrentTurn();
          });
        }
      }

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
        _isCardRevealed = false;
        _revealedSymbol = null;
      });
    }
  }

  /// Shows enhanced feedback overlay with haptic feedback and automatic dismissal
  void _showEnhancedFeedback(GuessResult result) {
    try {
      // Update overlay state variables
      setState(() {
        _showFeedbackOverlay = true;
        _overlayFeedbackText = result.isCorrect
            ? _getStreakMessage(_currentStreak)
            : 'Miss';
        _isCorrectGuess = result.isCorrect;
      });

      // Trigger haptic feedback based on guess result with error handling
      _triggerHapticFeedbackSafely(result.isCorrect);

      // Trigger a brief screen flash on correct guesses
      if (result.isCorrect) {
        try {
          _flashTimer?.cancel();
          setState(() {
            _flashScreen = true;
          });
          _flashTimer = Timer(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _flashScreen = false;
              });
            }
          });
        } catch (e) {
          debugPrint('Error triggering flash effect: $e');
        }
      }

      // Cancel any existing overlay timer
      _overlayTimer?.cancel();

      // Set timer for automatic overlay dismissal (1.5 seconds as per requirements 1.4, 2.4)
      _overlayTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          try {
            setState(() {
              _showFeedbackOverlay = false;
            });
          } catch (e) {
            debugPrint('Error hiding feedback overlay: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error showing enhanced feedback: $e');
      // Fallback: ensure overlay is hidden if there was an error
      if (mounted) {
        setState(() {
          _showFeedbackOverlay = false;
        });
      }
    }
  }

  /// Safely triggers haptic feedback with comprehensive error handling
  void _triggerHapticFeedbackSafely(bool isCorrect) {
    try {
      if (isCorrect) {
        HapticFeedbackService.triggerCorrectGuessFeedback();
      } else {
        HapticFeedbackService.triggerIncorrectGuessFeedback();
      }
    } catch (e) {
      // Haptic feedback is non-critical, so we just log and continue
      debugPrint('Haptic feedback error: $e');
    }
  }

  /// Returns the overlay message based on the current hot streak
  String _getStreakMessage(int streak) {
    if (streak <= 1) return 'Hit!';
    if (streak == 3) return 'Amazing!';
    if (streak == 7) return 'Visionary!';
    // if (streak <= 5) return 'Hot streak! ($streak)';
    return 'Hit!';
  }

  /// Starts the turn transition timer with improved timing sequence
  void _startTurnTransition() {
    try {
      _turnTransitionTimer?.cancel();

      // Phase 1: Show feedback for 1.5 seconds (requirement 3.3)
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          try {
            _beginTurnReset();
          } catch (e) {
            debugPrint('Error in turn reset: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting turn transition: $e');
      // Fallback: immediately begin turn reset
      if (mounted) {
        _beginTurnReset();
      }
    }
  }

  /// Begins the turn reset sequence with smooth transitions
  void _beginTurnReset() {
    try {
      // Phase 2: Start hiding card (smooth transition)

      // Phase 3: Hide card after brief delay for smooth animation
      Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          try {
            setState(() {
              _isCardRevealed = false;
              _revealedSymbol = null;
            });
          } catch (e) {
            debugPrint('Error hiding card: $e');
          }
        }
      });

      // Phase 4: Re-enable buttons after card is hidden (requirement 6.4)
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          try {
            setState(() {
              _buttonsEnabled = true;
            });
          } catch (e) {
            debugPrint('Error re-enabling buttons: $e');
            // Fallback: ensure buttons are enabled
            if (mounted) {
              setState(() {
                _buttonsEnabled = true;
              });
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error in turn reset sequence: $e');
      // Fallback: immediately reset to playable state
      if (mounted) {
        setState(() {
          _isCardRevealed = false;
          _revealedSymbol = null;
          _buttonsEnabled = true;
        });
      }
    }
  }

  /// Handles game completion and navigates to results screen.
  /// Shows an interstitial ad (if loaded) just before navigating to results.
  void _handleGameCompletion() {
    try {
      // Short delay for UX polish
      Timer(const Duration(milliseconds: 1500), () async {
        if (!mounted) return;
        try {
          await _maybeShowPostSessionInterstitial();
        } catch (e) {
          debugPrint('Interstitial show error: $e');
        }
        // Proceed to results
        try {
          _navigateToResultsScreen();
        } catch (e) {
          debugPrint('Error navigating to results screen: $e');
          _showFinalScoreDialog();
        }
      });
    } catch (e) {
      debugPrint('Error handling game completion: $e');
      if (mounted) {
        _showFinalScoreDialog();
      }
    }
  }

  /// Shows the final score dialog with play again option
  void _showFinalScoreDialog() {
    if (!mounted) return;

    try {
      // Retrieve game results from controller
      final gameResults = _gameController.getGameResults();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return FinalScoreDialog(
            score: _currentScore,
            onPlayAgain: _playAgain,
            gameResults: gameResults,
            onViewResults: () => _navigateToResultsReview(gameResults),
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
    try {
      Navigator.of(context).pop(); // Close dialog
    } catch (e) {
      debugPrint('Error closing dialog: $e');
    }

    try {
      // Cancel all timers to ensure clean state
      _turnTransitionTimer?.cancel();
      _feedbackTimer?.cancel();
      _scoreUpdateTimer?.cancel();
      _overlayTimer?.cancel();

      // Clear timer references for safety
      _turnTransitionTimer = null;
      _feedbackTimer = null;
      _scoreUpdateTimer = null;
      _overlayTimer = null;
      _flashTimer = null;
    } catch (e) {
      debugPrint('Error cancelling timers: $e');
    }

    _initializeGame();
  }

  /// Navigates directly to the results screen (replaces popup dialog)
  void _navigateToResultsScreen() {
    if (!mounted) return;

    try {
      // Retrieve game results from controller
      final gameResults = _gameController.getGameResults();

      // Validate game results before navigation
      if (gameResults.isEmpty) {
        debugPrint('Warning: Game results are empty, showing dialog instead');
        _showFinalScoreDialog();
        return;
      }

      // Navigate to results review screen with replacement navigation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultsReviewScreen(
            gameResults: gameResults,
            finalScore: _currentScore,
            coordinates: _gameController.getRemoteViewingCoordinates(),
            // No callbacks needed since ResultsReviewScreen handles navigation directly
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to results screen: $e');
      // Fallback: show final score dialog
      _showFinalScoreDialog();
    }
  }

  /// Navigates to the results review screen with game results data (legacy method for dialog)
  void _navigateToResultsReview(List<List<ZenerSymbol>> gameResults) {
    try {
      // Close the final score dialog first
      Navigator.of(context).pop();

      // Navigate to results review screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsReviewScreen(
            gameResults: gameResults,
            finalScore: _currentScore,
            coordinates: _gameController.getRemoteViewingCoordinates(),
            // No callbacks needed since ResultsReviewScreen handles navigation directly
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to results review: $e');
      // Fallback: just close the dialog
      try {
        Navigator.of(context).pop();
      } catch (popError) {
        debugPrint('Error closing dialog in fallback: $popError');
      }
    }
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
                    SvgSymbol(assetPath: symbol.assetPath, size: 16),
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
                    // activeThumbColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main game content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 20)),
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
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      'Turn ${_currentTurn > 25 ? 25 : _currentTurn} / 25',
                                      key: ValueKey(_currentTurn),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
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
                              // Remote viewing coordinates with subtle animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ) ??
                                          const TextStyle(),
                                      child: Text(
                                        _gameController
                                            .getRemoteViewingCoordinates(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
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
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      'Turn ${_currentTurn > 25 ? 25 : _currentTurn} / 25',
                                      key: ValueKey(_currentTurn),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
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

                    const SizedBox(height: 8),

                    // Debug panel with slide animation
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _buildDebugPanel(),
                    ),

                    const SizedBox(height: 22),

                    // Card reveal area with enhanced animations (expanded and centered)
                    Expanded(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: CardRevealWidget(
                            revealedSymbol: _revealedSymbol,
                            isRevealed: _isCardRevealed,
                          ),
                        ),
                      ),
                    ),

                    // Symbol selection area with staggered animations
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      child: SymbolSelectionWidget(
                        onSymbolSelected: _onSymbolSelected,
                        buttonsEnabled: _buttonsEnabled,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Screen flash overlay for correct guesses (brief, animated)
              IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 620),
                  curve: Curves.easeOut,
                  opacity: _flashScreen ? 0.9 : 0.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      // Warm gold radial flash that brightens the center and fades outwards
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Color.fromARGB(
                            255,
                            102,
                            2,
                            251,
                          ), // soft pale gold center
                          Color.fromARGB(255, 105, 5, 255), // rich gold mid
                          Color.fromARGB(255, 32, 2, 114), // transparent edge
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Enhanced feedback overlay with high z-index positioning
              FeedbackOverlay(
                isVisible: _showFeedbackOverlay,
                message: _overlayFeedbackText,
                isCorrect: _isCorrectGuess,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Ad helpers: Interstitial after session end ----------------

  void _loadPostSessionInterstitial() {
    // Use official callback API from google_mobile_ads samples.
    AdService.loadInterstitial(
      onLoaded: (ad) {
        _postSessionInterstitial = ad;
        // Set lifecycle callbacks
        _postSessionInterstitial?.fullScreenContentCallback =
            FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {},
              onAdImpression: (ad) {},
              onAdFailedToShowFullScreenContent: (ad, err) {
                debugPrint('Interstitial failed to show: $err');
                ad.dispose();
                _postSessionInterstitial = null;
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _postSessionInterstitial = null;
              },
              onAdClicked: (ad) {},
            );
      },
      onFailedToLoad: (error) {
        debugPrint('Interstitial failed to load: $error');
        _postSessionInterstitial = null;
      },
    );
  }

  Future<void> _maybeShowPostSessionInterstitial() async {
    final ad = _postSessionInterstitial;
    if (ad == null) {
      // Optionally kick off another load for next time; don't block UX now.
      _loadPostSessionInterstitial();
      return;
    }
    try {
      await ad.show();
    } catch (e) {
      debugPrint('Error showing interstitial: $e');
    } finally {
      _postSessionInterstitial = null;
    }
  }
}
