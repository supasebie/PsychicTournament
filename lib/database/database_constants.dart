/// Database constants and configuration for the local score database
class DatabaseConstants {
  // Database configuration
  static const String databaseName = 'psychic_tournament.db';
  static const int databaseVersion = 1;

  // Table names
  static const String gameSessionsTable = 'game_sessions';
  static const String turnResultsTable = 'turn_results';

  // Game sessions table columns
  static const String gameSessionId = 'id';
  static const String gameSessionDateTime = 'date_time';
  static const String gameSessionCoordinates = 'coordinates';
  static const String gameSessionFinalScore = 'final_score';
  static const String gameSessionTotalTurns = 'total_turns';
  static const String gameSessionCreatedAt = 'created_at';

  // Turn results table columns
  static const String turnResultId = 'id';
  static const String turnResultSessionId = 'session_id';
  static const String turnResultTurnNumber = 'turn_number';
  static const String turnResultUserGuess = 'user_guess';
  static const String turnResultCorrectAnswer = 'correct_answer';
  static const String turnResultIsHit = 'is_hit';

  // SQL statements for table creation
  static const String createGameSessionsTable =
      '''
    CREATE TABLE $gameSessionsTable (
      $gameSessionId INTEGER PRIMARY KEY AUTOINCREMENT,
      $gameSessionDateTime TEXT NOT NULL,
      $gameSessionCoordinates TEXT NOT NULL,
      $gameSessionFinalScore INTEGER NOT NULL,
      $gameSessionTotalTurns INTEGER NOT NULL DEFAULT 25,
      $gameSessionCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  static const String createTurnResultsTable =
      '''
    CREATE TABLE $turnResultsTable (
      $turnResultId INTEGER PRIMARY KEY AUTOINCREMENT,
      $turnResultSessionId INTEGER NOT NULL,
      $turnResultTurnNumber INTEGER NOT NULL,
      $turnResultUserGuess TEXT NOT NULL,
      $turnResultCorrectAnswer TEXT NOT NULL,
      $turnResultIsHit INTEGER NOT NULL,
      FOREIGN KEY ($turnResultSessionId) REFERENCES $gameSessionsTable ($gameSessionId) ON DELETE CASCADE
    )
  ''';

  // Default values
  static const int defaultTotalTurns = 25;
}
