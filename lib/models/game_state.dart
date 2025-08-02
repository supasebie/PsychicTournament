import 'zener_symbol.dart';

/// Immutable model representing the current state of a Zener card game
class GameState {
  /// The shuffled deck of 25 Zener cards for the current game
  final List<ZenerSymbol> deck;

  /// Remote viewing coordinates in XXXX-XXXX format
  final String remoteViewingCoordinates;

  /// Current turn number (1-25)
  final int currentTurn;

  /// Current score (number of correct guesses)
  final int score;

  /// Whether the game is complete (all 25 turns finished)
  final bool isComplete;

  /// Game results storing each turn as [userGuess, correctAnswer]
  final List<List<ZenerSymbol>> gameResults;

  const GameState({
    required this.deck,
    required this.remoteViewingCoordinates,
    this.currentTurn = 1,
    this.score = 0,
    this.isComplete = false,
    this.gameResults = const [],
  });

  /// Creates a copy of this GameState with optionally updated properties
  GameState copyWith({
    List<ZenerSymbol>? deck,
    String? remoteViewingCoordinates,
    int? currentTurn,
    int? score,
    bool? isComplete,
    List<List<ZenerSymbol>>? gameResults,
  }) {
    return GameState(
      deck: deck ?? this.deck,
      remoteViewingCoordinates:
          remoteViewingCoordinates ?? this.remoteViewingCoordinates,
      currentTurn: currentTurn ?? this.currentTurn,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
      gameResults: gameResults ?? this.gameResults,
    );
  }

  /// Returns the current card (symbol) for the current turn
  ZenerSymbol get currentCard {
    if (currentTurn < 1 || currentTurn > deck.length) {
      throw StateError('Invalid turn number: $currentTurn');
    }
    return deck[currentTurn - 1];
  }

  /// Returns whether there are more turns to play
  bool get hasMoreTurns => currentTurn <= 25 && !isComplete;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;

    return deck.length == other.deck.length &&
        _listEquals(deck, other.deck) &&
        remoteViewingCoordinates == other.remoteViewingCoordinates &&
        currentTurn == other.currentTurn &&
        score == other.score &&
        isComplete == other.isComplete &&
        _listOfListsEquals(gameResults, other.gameResults);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(deck),
      remoteViewingCoordinates,
      currentTurn,
      score,
      isComplete,
      Object.hashAll(gameResults.expand((list) => list)),
    );
  }

  @override
  String toString() {
    return 'GameState(deck: ${deck.length} cards, coordinates: $remoteViewingCoordinates, '
        'turn: $currentTurn, score: $score, complete: $isComplete, results: ${gameResults.length})';
  }

  /// Helper method to compare two lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper method to compare two lists of lists for equality
  bool _listOfListsEquals<T>(List<List<T>> a, List<List<T>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_listEquals(a[i], b[i])) return false;
    }
    return true;
  }
}
