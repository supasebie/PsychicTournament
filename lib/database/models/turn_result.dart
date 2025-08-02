import '../../models/zener_symbol.dart';
import '../database_exceptions.dart';

/// Database model representing a single turn result in a game session
/// Maps to the turn_results table in SQLite
class TurnResult {
  /// Primary key (auto-generated)
  final int? id;

  /// Foreign key reference to the game session
  final int? sessionId;

  /// The turn number within the session (1-25)
  final int turnNumber;

  /// The symbol the user guessed
  final ZenerSymbol userGuess;

  /// The correct symbol for this turn
  final ZenerSymbol correctAnswer;

  /// Whether the user's guess was correct (stored as 1/0 in SQLite)
  final bool isHit;

  const TurnResult({
    this.id,
    this.sessionId,
    required this.turnNumber,
    required this.userGuess,
    required this.correctAnswer,
    required this.isHit,
  });

  /// Creates a TurnResult from user guess and correct answer
  /// Automatically calculates if the guess is correct
  factory TurnResult.fromGuess({
    int? id,
    int? sessionId,
    required int turnNumber,
    required ZenerSymbol userGuess,
    required ZenerSymbol correctAnswer,
  }) {
    return TurnResult(
      id: id,
      sessionId: sessionId,
      turnNumber: turnNumber,
      userGuess: userGuess,
      correctAnswer: correctAnswer,
      isHit: userGuess == correctAnswer,
    );
  }

  /// Validates the turn result data
  void validate() {
    if (turnNumber < 1) {
      throw DatabaseException('Turn number must be greater than 0');
    }

    if (turnNumber > 25) {
      throw DatabaseException('Turn number cannot exceed 25');
    }

    // Validate that isHit matches the actual comparison
    final expectedHit = userGuess == correctAnswer;
    if (isHit != expectedHit) {
      throw DatabaseException(
        'isHit value ($isHit) does not match actual comparison ($expectedHit)',
      );
    }
  }

  /// Converts the TurnResult to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    validate();

    return {
      'id': id,
      'session_id': sessionId,
      'turn_number': turnNumber,
      'user_guess': userGuess.name, // Store enum name as string
      'correct_answer': correctAnswer.name, // Store enum name as string
      'is_hit': isHit ? 1 : 0, // Store boolean as integer for SQLite
    };
  }

  /// Creates a TurnResult from a SQLite Map
  factory TurnResult.fromMap(Map<String, dynamic> map) {
    try {
      final id = map['id'] as int?;
      final sessionId = map['session_id'] as int?;
      final turnNumber = map['turn_number'] as int?;
      final userGuessStr = map['user_guess'] as String?;
      final correctAnswerStr = map['correct_answer'] as String?;
      final isHitInt = map['is_hit'] as int?;

      if (turnNumber == null) {
        throw DatabaseException('turn_number is required');
      }
      if (userGuessStr == null) {
        throw DatabaseException('user_guess is required');
      }
      if (correctAnswerStr == null) {
        throw DatabaseException('correct_answer is required');
      }
      if (isHitInt == null) {
        throw DatabaseException('is_hit is required');
      }

      // Parse ZenerSymbol enums from string names
      ZenerSymbol? userGuess;
      ZenerSymbol? correctAnswer;

      try {
        userGuess = ZenerSymbol.values.firstWhere(
          (symbol) => symbol.name == userGuessStr,
        );
      } catch (e) {
        throw DatabaseException('Invalid user_guess value: $userGuessStr');
      }

      try {
        correctAnswer = ZenerSymbol.values.firstWhere(
          (symbol) => symbol.name == correctAnswerStr,
        );
      } catch (e) {
        throw DatabaseException(
          'Invalid correct_answer value: $correctAnswerStr',
        );
      }

      final isHit = isHitInt == 1;

      final turnResult = TurnResult(
        id: id,
        sessionId: sessionId,
        turnNumber: turnNumber,
        userGuess: userGuess,
        correctAnswer: correctAnswer,
        isHit: isHit,
      );

      turnResult.validate();
      return turnResult;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to create TurnResult from map: ${e.toString()}',
        operation: 'fromMap',
        originalError: e,
      );
    }
  }

  /// Creates a copy of this TurnResult with updated values
  TurnResult copyWith({
    int? id,
    int? sessionId,
    int? turnNumber,
    ZenerSymbol? userGuess,
    ZenerSymbol? correctAnswer,
    bool? isHit,
  }) {
    return TurnResult(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      turnNumber: turnNumber ?? this.turnNumber,
      userGuess: userGuess ?? this.userGuess,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isHit: isHit ?? this.isHit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TurnResult) return false;

    return id == other.id &&
        sessionId == other.sessionId &&
        turnNumber == other.turnNumber &&
        userGuess == other.userGuess &&
        correctAnswer == other.correctAnswer &&
        isHit == other.isHit;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      turnNumber,
      userGuess,
      correctAnswer,
      isHit,
    );
  }

  @override
  String toString() {
    return 'TurnResult(id: $id, sessionId: $sessionId, '
        'turnNumber: $turnNumber, userGuess: $userGuess, '
        'correctAnswer: $correctAnswer, isHit: $isHit)';
  }
}
