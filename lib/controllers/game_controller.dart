import 'dart:math';
import '../models/zener_symbol.dart';
import '../models/game_state.dart';
import '../models/guess_result.dart';

/// Controller class that manages the core game logic for the Zener card game
class GameController {
  static final Random _random = Random();
  GameState _gameState;

  /// Creates a new GameController with an initial game state
  GameController() : _gameState = _createInitialGameState();

  /// Gets the current game state
  GameState get gameState => _gameState;

  /// Creates a shuffled deck of 25 Zener cards (5 of each symbol)
  static List<ZenerSymbol> createShuffledDeck() {
    final List<ZenerSymbol> deck = [];

    // Add 5 of each symbol to create a 25-card deck
    for (final symbol in ZenerSymbol.values) {
      for (int i = 0; i < 5; i++) {
        deck.add(symbol);
      }
    }

    // Shuffle using Fisher-Yates algorithm
    _fisherYatesShuffle(deck);

    return deck;
  }

  /// Implements the Fisher-Yates shuffle algorithm for deck randomization
  static void _fisherYatesShuffle<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final int j = _random.nextInt(i + 1);
      final T temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Generates remote viewing coordinates in XXXX-XXXX format
  static String generateRemoteViewingCoordinates() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final StringBuffer buffer = StringBuffer();

    // Generate first 4 characters
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }

    buffer.write('-');

    // Generate last 4 characters
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  /// Processes a user's guess and returns the result
  GuessResult makeGuess(ZenerSymbol userGuess) {
    if (_gameState.isComplete) {
      throw StateError('Cannot make guess: game is already complete');
    }

    if (_gameState.currentTurn > 25) {
      throw StateError('Cannot make guess: invalid turn number');
    }

    final ZenerSymbol correctSymbol = _gameState.currentCard;
    final bool isCorrect = userGuess == correctSymbol;
    final int newScore = isCorrect ? _gameState.score + 1 : _gameState.score;

    // Store the guess result in the format [userGuess, correctAnswer]
    final List<List<ZenerSymbol>> updatedResults = List.from(
      _gameState.gameResults,
    );
    updatedResults.add([userGuess, correctSymbol]);

    // Create the guess result
    final GuessResult result = GuessResult(
      isCorrect: isCorrect,
      correctSymbol: correctSymbol,
      userGuess: userGuess,
      newScore: newScore,
    );

    // Update game state
    final int nextTurn = _gameState.currentTurn + 1;
    final bool isGameComplete = nextTurn > 25;

    _gameState = _gameState.copyWith(
      currentTurn: nextTurn,
      score: newScore,
      isComplete: isGameComplete,
      gameResults: updatedResults,
    );

    return result;
  }

  /// Returns the correct symbol for the current turn
  ZenerSymbol getCurrentCorrectSymbol() {
    return _gameState.currentCard;
  }

  /// Returns whether the game is complete (all 25 turns finished)
  bool isGameComplete() {
    return _gameState.isComplete;
  }

  /// Resets the game to initial state with a new shuffled deck
  void resetGame() {
    _gameState = _createInitialGameState();
  }

  /// Creates the initial game state with shuffled deck and coordinates
  static GameState _createInitialGameState() {
    return GameState(
      deck: createShuffledDeck(),
      remoteViewingCoordinates: generateRemoteViewingCoordinates(),
      currentTurn: 1,
      score: 0,
      isComplete: false,
      gameResults: const [],
    );
  }

  /// Returns the current score
  int getCurrentScore() {
    return _gameState.score;
  }

  /// Returns the current turn number
  int getCurrentTurn() {
    return _gameState.currentTurn;
  }

  /// Returns the remote viewing coordinates for the current game
  String getRemoteViewingCoordinates() {
    return _gameState.remoteViewingCoordinates;
  }

  /// Returns whether there are more turns to play
  bool hasMoreTurns() {
    return _gameState.hasMoreTurns;
  }

  /// Returns the complete list of game results in format [[userGuess, correctAnswer], ...]
  List<List<ZenerSymbol>> getGameResults() {
    return List.from(_gameState.gameResults);
  }
}
