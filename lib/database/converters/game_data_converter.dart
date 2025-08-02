import '../../models/zener_symbol.dart';
import '../models/game_session.dart';
import '../models/turn_result.dart';
import '../database_exceptions.dart';

/// Converter class for transforming game data between different formats
/// Handles conversion from ResultsReviewScreen data format to database models
class GameDataConverter {
  /// Converts game results from ResultsReviewScreen format to GameSession
  ///
  /// Takes the current game results format used by ResultsReviewScreen:
  /// - gameResults: List&lt;List&lt;ZenerSymbol&gt;&gt; where each entry is [userGuess, correctAnswer]
  /// - finalScore: int representing the final score achieved
  /// - coordinates: String in XXXX-XXXX format for remote viewing
  ///
  /// Returns a complete GameSession with associated TurnResult objects
  static GameSession fromResultsReviewData({
    required List<List<ZenerSymbol>> gameResults,
    required int finalScore,
    required String coordinates,
    DateTime? dateTime,
  }) {
    try {
      // Validate input data
      if (gameResults.isEmpty) {
        throw DatabaseException('Game results cannot be empty');
      }

      if (gameResults.length > 25) {
        throw DatabaseException(
          'Game results cannot exceed 25 turns, got ${gameResults.length}',
        );
      }

      if (coordinates.isEmpty) {
        throw DatabaseException('Coordinates cannot be empty');
      }

      if (finalScore < 0 || finalScore > gameResults.length) {
        throw DatabaseException(
          'Final score ($finalScore) must be between 0 and ${gameResults.length}',
        );
      }

      // Validate coordinates format
      if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(coordinates)) {
        throw DatabaseException(
          'Coordinates must be in XXXX-XXXX format with alphanumeric characters',
        );
      }

      // Convert game results to TurnResult objects
      final List<TurnResult> turnResults = convertGameResults(gameResults);

      // Verify the final score matches the calculated hits
      final int calculatedScore = turnResults
          .where((turn) => turn.isHit)
          .length;
      if (calculatedScore != finalScore) {
        throw DatabaseException(
          'Final score ($finalScore) does not match calculated hits ($calculatedScore)',
        );
      }

      // Create and return the GameSession
      return GameSession(
        dateTime: dateTime ?? DateTime.now(),
        coordinates: coordinates,
        finalScore: finalScore,
        totalTurns: gameResults.length,
        turnResults: turnResults,
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to convert results review data to GameSession: ${e.toString()}',
        operation: 'fromResultsReviewData',
        originalError: e,
      );
    }
  }

  /// Converts List&lt;List&lt;ZenerSymbol&gt;&gt; game results to List&lt;TurnResult&gt;
  ///
  /// Each entry in gameResults should be [userGuess, correctAnswer]
  /// Returns a list of TurnResult objects with proper turn numbering
  static List<TurnResult> convertGameResults(
    List<List<ZenerSymbol>> gameResults,
  ) {
    try {
      if (gameResults.isEmpty) {
        throw DatabaseException('Game results cannot be empty');
      }

      final List<TurnResult> turnResults = [];

      for (int i = 0; i < gameResults.length; i++) {
        final List<ZenerSymbol> result = gameResults[i];

        // Validate each result entry
        if (result.length != 2) {
          throw DatabaseException(
            'Game result at index $i must contain exactly 2 symbols (userGuess, correctAnswer), got ${result.length}',
          );
        }

        final ZenerSymbol userGuess = result[0];
        final ZenerSymbol correctAnswer = result[1];
        final int turnNumber = i + 1; // Turn numbers are 1-based

        // Create TurnResult using the factory method that automatically calculates isHit
        final TurnResult turnResult = TurnResult.fromGuess(
          turnNumber: turnNumber,
          userGuess: userGuess,
          correctAnswer: correctAnswer,
        );

        turnResults.add(turnResult);
      }

      return turnResults;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to convert game results to TurnResult objects: ${e.toString()}',
        operation: 'convertGameResults',
        originalError: e,
      );
    }
  }

  /// Validates that game results data is in the expected format
  ///
  /// Checks that:
  /// - gameResults is not empty
  /// - Each result entry has exactly 2 ZenerSymbol values
  /// - Turn count doesn't exceed 25
  /// - Final score is consistent with the results
  static void validateGameResultsData({
    required List<List<ZenerSymbol>> gameResults,
    required int finalScore,
    required String coordinates,
  }) {
    if (gameResults.isEmpty) {
      throw DatabaseException('Game results cannot be empty');
    }

    if (gameResults.length > 25) {
      throw DatabaseException(
        'Game results cannot exceed 25 turns, got ${gameResults.length}',
      );
    }

    if (coordinates.isEmpty) {
      throw DatabaseException('Coordinates cannot be empty');
    }

    if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(coordinates)) {
      throw DatabaseException(
        'Coordinates must be in XXXX-XXXX format with alphanumeric characters',
      );
    }

    if (finalScore < 0 || finalScore > gameResults.length) {
      throw DatabaseException(
        'Final score ($finalScore) must be between 0 and ${gameResults.length}',
      );
    }

    // Validate each result entry format
    for (int i = 0; i < gameResults.length; i++) {
      final List<ZenerSymbol> result = gameResults[i];
      if (result.length != 2) {
        throw DatabaseException(
          'Game result at index $i must contain exactly 2 symbols (userGuess, correctAnswer), got ${result.length}',
        );
      }
    }

    // Validate that final score matches actual hits
    int calculatedHits = 0;
    for (final result in gameResults) {
      if (result[0] == result[1]) {
        calculatedHits++;
      }
    }

    if (calculatedHits != finalScore) {
      throw DatabaseException(
        'Final score ($finalScore) does not match calculated hits ($calculatedHits)',
      );
    }
  }

  /// Extracts date/time information from various sources
  ///
  /// Priority order:
  /// 1. Explicitly provided dateTime parameter
  /// 2. Current timestamp as fallback
  static DateTime extractDateTime({DateTime? dateTime}) {
    return dateTime ?? DateTime.now();
  }

  /// Validates and normalizes coordinate string format
  ///
  /// Ensures coordinates are in proper XXXX-XXXX format
  /// Converts to uppercase if needed
  static String normalizeCoordinates(String coordinates) {
    if (coordinates.isEmpty) {
      throw DatabaseException('Coordinates cannot be empty');
    }

    final String normalized = coordinates.toUpperCase().trim();

    if (!RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(normalized)) {
      throw DatabaseException(
        'Coordinates must be in XXXX-XXXX format with alphanumeric characters',
      );
    }

    return normalized;
  }
}
