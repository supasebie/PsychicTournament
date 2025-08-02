import 'zener_symbol.dart';

/// Model representing the result of a single turn in the Zener card game
/// Used for storing and displaying detailed game results
class TurnResult {
  /// The turn number (1-25)
  final int turnNumber;

  /// The symbol the user guessed
  final ZenerSymbol userGuess;

  /// The correct symbol for this turn
  final ZenerSymbol correctAnswer;

  /// Whether the user's guess was correct
  final bool isCorrect;

  const TurnResult({
    required this.turnNumber,
    required this.userGuess,
    required this.correctAnswer,
    required this.isCorrect,
  }) : assert(
         turnNumber >= 1 && turnNumber <= 25,
         'Turn number must be between 1 and 25',
       );

  /// Creates a TurnResult from user guess and correct answer
  /// Automatically calculates if the guess is correct
  factory TurnResult.fromGuess({
    required int turnNumber,
    required ZenerSymbol userGuess,
    required ZenerSymbol correctAnswer,
  }) {
    return TurnResult(
      turnNumber: turnNumber,
      userGuess: userGuess,
      correctAnswer: correctAnswer,
      isCorrect: userGuess == correctAnswer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TurnResult) return false;

    return turnNumber == other.turnNumber &&
        userGuess == other.userGuess &&
        correctAnswer == other.correctAnswer &&
        isCorrect == other.isCorrect;
  }

  @override
  int get hashCode {
    return Object.hash(turnNumber, userGuess, correctAnswer, isCorrect);
  }

  @override
  String toString() {
    return 'TurnResult(turn: $turnNumber, guess: $userGuess, '
        'correct: $correctAnswer, isCorrect: $isCorrect)';
  }
}
