import 'zener_symbol.dart';

/// Model representing the result of a user's guess in the Zener card game
class GuessResult {
  /// Whether the user's guess was correct
  final bool isCorrect;

  /// The correct symbol for this turn
  final ZenerSymbol correctSymbol;

  /// The symbol the user guessed
  final ZenerSymbol userGuess;

  /// The new score after this guess
  final int newScore;

  const GuessResult({
    required this.isCorrect,
    required this.correctSymbol,
    required this.userGuess,
    required this.newScore,
  });

  /// Returns the feedback message to display to the user
  String get feedbackMessage {
    if (isCorrect) {
      return 'Correct!';
    } else {
      return 'Incorrect. The card was a ${correctSymbol.displayName}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuessResult) return false;

    return isCorrect == other.isCorrect &&
        correctSymbol == other.correctSymbol &&
        userGuess == other.userGuess &&
        newScore == other.newScore;
  }

  @override
  int get hashCode {
    return Object.hash(isCorrect, correctSymbol, userGuess, newScore);
  }

  @override
  String toString() {
    return 'GuessResult(correct: $isCorrect, correctSymbol: $correctSymbol, '
        'userGuess: $userGuess, newScore: $newScore)';
  }
}
