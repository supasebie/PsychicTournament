import '../database_exceptions.dart';
import 'turn_result.dart';

/// Database model representing a complete game session
/// Maps to the game_sessions table in SQLite
class GameSession {
  /// Primary key (auto-generated)
  final int? id;

  /// Date and time when the game was played
  final DateTime dateTime;

  /// Remote viewing coordinates for the session (XXXX-XXXX format)
  final String coordinates;

  /// Final score achieved in the game (0-25)
  final int finalScore;

  /// Total number of turns played (should be 25)
  final int totalTurns;

  /// List of individual turn results for this session
  final List<TurnResult> turnResults;

  const GameSession({
    this.id,
    required this.dateTime,
    required this.coordinates,
    required this.finalScore,
    required this.totalTurns,
    this.turnResults = const [],
  });

  /// Validates the game session data
  void validate() {
    if (coordinates.isEmpty) {
      throw DatabaseException('Coordinates cannot be empty');
    }

    if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(coordinates)) {
      throw DatabaseException(
        'Coordinates must be in XXXX-XXXX format with alphanumeric characters',
      );
    }

    if (finalScore < 0 || finalScore > totalTurns) {
      throw DatabaseException('Final score must be between 0 and $totalTurns');
    }

    if (totalTurns <= 0) {
      throw DatabaseException('Total turns must be greater than 0');
    }

    if (turnResults.isNotEmpty && turnResults.length != totalTurns) {
      throw DatabaseException(
        'Turn results count (${turnResults.length}) must match total turns ($totalTurns)',
      );
    }
  }

  /// Converts the GameSession to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    validate();

    return {
      'id': id,
      'date_time': dateTime.toIso8601String(),
      'coordinates': coordinates,
      'final_score': finalScore,
      'total_turns': totalTurns,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a GameSession from a SQLite Map
  factory GameSession.fromMap(Map<String, dynamic> map) {
    try {
      final id = map['id'] as int?;
      final dateTimeStr = map['date_time'] as String?;
      final coordinates = map['coordinates'] as String?;
      final finalScore = map['final_score'] as int?;
      final totalTurns = map['total_turns'] as int?;

      if (dateTimeStr == null) {
        throw DatabaseException('date_time is required');
      }
      if (coordinates == null) {
        throw DatabaseException('coordinates is required');
      }
      if (finalScore == null) {
        throw DatabaseException('final_score is required');
      }
      if (totalTurns == null) {
        throw DatabaseException('total_turns is required');
      }

      final dateTime = DateTime.parse(dateTimeStr);

      final session = GameSession(
        id: id,
        dateTime: dateTime,
        coordinates: coordinates,
        finalScore: finalScore,
        totalTurns: totalTurns,
      );

      session.validate();
      return session;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to create GameSession from map: ${e.toString()}',
        operation: 'fromMap',
        originalError: e,
      );
    }
  }

  /// Creates a copy of this GameSession with updated values
  GameSession copyWith({
    int? id,
    DateTime? dateTime,
    String? coordinates,
    int? finalScore,
    int? totalTurns,
    List<TurnResult>? turnResults,
  }) {
    return GameSession(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      coordinates: coordinates ?? this.coordinates,
      finalScore: finalScore ?? this.finalScore,
      totalTurns: totalTurns ?? this.totalTurns,
      turnResults: turnResults ?? this.turnResults,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameSession) return false;

    return id == other.id &&
        dateTime == other.dateTime &&
        coordinates == other.coordinates &&
        finalScore == other.finalScore &&
        totalTurns == other.totalTurns;
  }

  @override
  int get hashCode {
    return Object.hash(id, dateTime, coordinates, finalScore, totalTurns);
  }

  @override
  String toString() {
    return 'GameSession(id: $id, dateTime: $dateTime, '
        'coordinates: $coordinates, finalScore: $finalScore, '
        'totalTurns: $totalTurns, turnResults: ${turnResults.length})';
  }
}
