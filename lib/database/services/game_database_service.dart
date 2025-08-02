import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../database_constants.dart';
import '../database_exceptions.dart' as db_exceptions;
import '../models/game_session.dart';
import '../models/turn_result.dart';

/// Primary service for all database operations related to game sessions and turn results
/// Provides CRUD operations with proper error handling and transaction support
class GameDatabaseService {
  static GameDatabaseService? _instance;
  Database? _database;

  /// Private constructor for singleton pattern
  GameDatabaseService._();

  /// Get the singleton instance of GameDatabaseService
  static GameDatabaseService get instance {
    _instance ??= GameDatabaseService._();
    return _instance!;
  }

  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    _database ??= await DatabaseConfig.database;
    return _database!;
  }

  /// Initialize the database connection
  /// This method is called automatically when accessing the database
  Future<void> initialize() async {
    try {
      await database;
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to initialize database',
        operation: 'initialize',
        originalError: e,
      );
    }
  }

  /// Close the database connection
  /// Should be called when the app is shutting down
  Future<void> close() async {
    try {
      await DatabaseConfig.closeDatabase();
      _database = null;
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to close database',
        operation: 'close',
        originalError: e,
      );
    }
  }

  /// Reset the database (primarily for testing purposes)
  /// WARNING: This will delete all data permanently
  Future<void> resetDatabase() async {
    try {
      await DatabaseConfig.resetDatabase();
      _database = null;
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to reset database',
        operation: 'resetDatabase',
        originalError: e,
      );
    }
  }

  /// Check if the database is properly initialized and accessible
  Future<bool> isDatabaseHealthy() async {
    try {
      final db = await database;
      // Try to execute a simple query to verify database health
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get database version information
  Future<int> getDatabaseVersion() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA user_version');
      if (result.isNotEmpty) {
        return result.first['user_version'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to get database version',
        operation: 'getDatabaseVersion',
        originalError: e,
      );
    }
  }

  /// Get the total number of records in a table
  Future<int> getTableRecordCount(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to get record count for table $tableName',
        operation: 'getTableRecordCount',
        originalError: e,
      );
    }
  }

  /// Execute a raw SQL query (for advanced operations)
  /// Use with caution - prefer the specific CRUD methods when possible
  Future<List<Map<String, dynamic>>> executeRawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to execute raw query: $sql',
        operation: 'executeRawQuery',
        originalError: e,
      );
    }
  }

  /// Execute a raw SQL command (for advanced operations)
  /// Use with caution - prefer the specific CRUD methods when possible
  Future<void> executeRawCommand(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
    } catch (e) {
      throw db_exceptions.DatabaseException(
        'Failed to execute raw command: $sql',
        operation: 'executeRawCommand',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // GAME SESSION PERSISTENCE METHODS
  // ============================================================================

  /// Save a complete game session with all turn results in a single transaction
  /// Returns the saved GameSession with the generated ID
  Future<GameSession> saveGameSession(GameSession session) async {
    try {
      final db = await database;

      // Validate the session before saving
      session.validate();

      // Use a transaction to ensure data consistency
      return await db.transaction<GameSession>((txn) async {
        // Insert the game session first
        final sessionMap = session.toMap();
        sessionMap.remove('id'); // Remove ID to let SQLite auto-generate it

        final sessionId = await txn.insert(
          DatabaseConstants.gameSessionsTable,
          sessionMap,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        // Insert all turn results with the session ID
        final savedTurnResults = <TurnResult>[];
        for (final turnResult in session.turnResults) {
          final turnResultMap = turnResult.toMap();
          turnResultMap.remove(
            'id',
          ); // Remove ID to let SQLite auto-generate it
          turnResultMap[DatabaseConstants.turnResultSessionId] = sessionId;

          final turnResultId = await txn.insert(
            DatabaseConstants.turnResultsTable,
            turnResultMap,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          savedTurnResults.add(
            turnResult.copyWith(id: turnResultId, sessionId: sessionId),
          );
        }

        // Return the complete saved session
        return session.copyWith(id: sessionId, turnResults: savedTurnResults);
      });
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to save game session',
        operation: 'saveGameSession',
        originalError: e,
      );
    }
  }

  /// Retrieve all game sessions ordered by date (most recent first)
  /// Optionally includes turn results for each session
  Future<List<GameSession>> getAllGameSessions({
    bool includeTurnResults = false,
  }) async {
    try {
      final db = await database;

      // Query all game sessions ordered by date (most recent first)
      final sessionMaps = await db.query(
        DatabaseConstants.gameSessionsTable,
        orderBy: '${DatabaseConstants.gameSessionDateTime} DESC',
      );

      final sessions = <GameSession>[];

      for (final sessionMap in sessionMaps) {
        final session = GameSession.fromMap(sessionMap);

        if (includeTurnResults && session.id != null) {
          // Load turn results for this session
          final turnResults = await _getTurnResultsForSession(session.id!);
          sessions.add(session.copyWith(turnResults: turnResults));
        } else {
          sessions.add(session);
        }
      }

      return sessions;
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve all game sessions',
        operation: 'getAllGameSessions',
        originalError: e,
      );
    }
  }

  /// Retrieve a specific game session by ID
  /// Optionally includes turn results for the session
  Future<GameSession?> getGameSession(
    int id, {
    bool includeTurnResults = true,
  }) async {
    try {
      final db = await database;

      // Query the specific game session
      final sessionMaps = await db.query(
        DatabaseConstants.gameSessionsTable,
        where: '${DatabaseConstants.gameSessionId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (sessionMaps.isEmpty) {
        return null;
      }

      final session = GameSession.fromMap(sessionMaps.first);

      if (includeTurnResults) {
        // Load turn results for this session
        final turnResults = await _getTurnResultsForSession(id);
        return session.copyWith(turnResults: turnResults);
      }

      return session;
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve game session with ID $id',
        operation: 'getGameSession',
        originalError: e,
      );
    }
  }

  /// Delete a game session and all associated turn results
  /// Uses CASCADE DELETE to automatically remove turn results
  Future<void> deleteGameSession(int id) async {
    try {
      final db = await database;

      // Use a transaction to ensure data consistency
      await db.transaction((txn) async {
        // First verify the session exists
        final sessionMaps = await txn.query(
          DatabaseConstants.gameSessionsTable,
          where: '${DatabaseConstants.gameSessionId} = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (sessionMaps.isEmpty) {
          throw db_exceptions.DatabaseException(
            'Game session with ID $id not found',
            operation: 'deleteGameSession',
          );
        }

        // Delete the session (turn results will be deleted automatically due to CASCADE)
        final deletedRows = await txn.delete(
          DatabaseConstants.gameSessionsTable,
          where: '${DatabaseConstants.gameSessionId} = ?',
          whereArgs: [id],
        );

        if (deletedRows == 0) {
          throw db_exceptions.DatabaseException(
            'Failed to delete game session with ID $id',
            operation: 'deleteGameSession',
          );
        }
      });
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to delete game session with ID $id',
        operation: 'deleteGameSession',
        originalError: e,
      );
    }
  }

  /// Get the most recent game sessions (limited count)
  Future<List<GameSession>> getRecentGameSessions(
    int limit, {
    bool includeTurnResults = false,
  }) async {
    try {
      final db = await database;

      // Query recent game sessions ordered by date (most recent first)
      final sessionMaps = await db.query(
        DatabaseConstants.gameSessionsTable,
        orderBy: '${DatabaseConstants.gameSessionDateTime} DESC',
        limit: limit,
      );

      final sessions = <GameSession>[];

      for (final sessionMap in sessionMaps) {
        final session = GameSession.fromMap(sessionMap);

        if (includeTurnResults && session.id != null) {
          // Load turn results for this session
          final turnResults = await _getTurnResultsForSession(session.id!);
          sessions.add(session.copyWith(turnResults: turnResults));
        } else {
          sessions.add(session);
        }
      }

      return sessions;
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve recent game sessions',
        operation: 'getRecentGameSessions',
        originalError: e,
      );
    }
  }

  /// Get game sessions within a specific date range
  Future<List<GameSession>> getGameSessionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeTurnResults = false,
  }) async {
    try {
      final db = await database;

      // Query game sessions within the date range
      final sessionMaps = await db.query(
        DatabaseConstants.gameSessionsTable,
        where: '${DatabaseConstants.gameSessionDateTime} BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: '${DatabaseConstants.gameSessionDateTime} DESC',
      );

      final sessions = <GameSession>[];

      for (final sessionMap in sessionMaps) {
        final session = GameSession.fromMap(sessionMap);

        if (includeTurnResults && session.id != null) {
          // Load turn results for this session
          final turnResults = await _getTurnResultsForSession(session.id!);
          sessions.add(session.copyWith(turnResults: turnResults));
        } else {
          sessions.add(session);
        }
      }

      return sessions;
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve game sessions by date range',
        operation: 'getGameSessionsByDateRange',
        originalError: e,
      );
    }
  }

  /// Helper method to get turn results for a specific session
  Future<List<TurnResult>> _getTurnResultsForSession(int sessionId) async {
    final db = await database;

    final turnResultMaps = await db.query(
      DatabaseConstants.turnResultsTable,
      where: '${DatabaseConstants.turnResultSessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${DatabaseConstants.turnResultTurnNumber} ASC',
    );

    return turnResultMaps.map((map) => TurnResult.fromMap(map)).toList();
  }

  // ============================================================================
  // TURN RESULTS DATABASE OPERATIONS
  // ============================================================================

  /// Save multiple turn results in a single transaction
  /// All turn results must belong to the same session
  Future<List<TurnResult>> saveTurnResults(List<TurnResult> turnResults) async {
    if (turnResults.isEmpty) {
      return [];
    }

    try {
      final db = await database;

      // Validate that all turn results belong to the same session
      final sessionId = turnResults.first.sessionId;
      if (sessionId == null) {
        throw db_exceptions.DatabaseException(
          'All turn results must have a valid session ID',
          operation: 'saveTurnResults',
        );
      }

      for (final turnResult in turnResults) {
        if (turnResult.sessionId != sessionId) {
          throw db_exceptions.DatabaseException(
            'All turn results must belong to the same session',
            operation: 'saveTurnResults',
          );
        }
        turnResult.validate();
      }

      // Verify the session exists
      final sessionExists = await _sessionExists(sessionId);
      if (!sessionExists) {
        throw db_exceptions.DatabaseException(
          'Session with ID $sessionId does not exist',
          operation: 'saveTurnResults',
        );
      }

      // Use a transaction to ensure data consistency
      return await db.transaction<List<TurnResult>>((txn) async {
        final savedTurnResults = <TurnResult>[];

        for (final turnResult in turnResults) {
          final turnResultMap = turnResult.toMap();
          turnResultMap.remove(
            'id',
          ); // Remove ID to let SQLite auto-generate it

          final turnResultId = await txn.insert(
            DatabaseConstants.turnResultsTable,
            turnResultMap,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          savedTurnResults.add(turnResult.copyWith(id: turnResultId));
        }

        return savedTurnResults;
      });
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to save turn results',
        operation: 'saveTurnResults',
        originalError: e,
      );
    }
  }

  /// Save a single turn result
  Future<TurnResult> saveTurnResult(TurnResult turnResult) async {
    try {
      turnResult.validate();

      if (turnResult.sessionId == null) {
        throw db_exceptions.DatabaseException(
          'Turn result must have a valid session ID',
          operation: 'saveTurnResult',
        );
      }

      // Verify the session exists
      final sessionExists = await _sessionExists(turnResult.sessionId!);
      if (!sessionExists) {
        throw db_exceptions.DatabaseException(
          'Session with ID ${turnResult.sessionId} does not exist',
          operation: 'saveTurnResult',
        );
      }

      final db = await database;
      final turnResultMap = turnResult.toMap();
      turnResultMap.remove('id'); // Remove ID to let SQLite auto-generate it

      final turnResultId = await db.insert(
        DatabaseConstants.turnResultsTable,
        turnResultMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return turnResult.copyWith(id: turnResultId);
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to save turn result',
        operation: 'saveTurnResult',
        originalError: e,
      );
    }
  }

  /// Retrieve all turn results for a specific session ID
  /// Results are ordered by turn number (ascending)
  Future<List<TurnResult>> getTurnResultsBySessionId(int sessionId) async {
    try {
      final db = await database;

      final turnResultMaps = await db.query(
        DatabaseConstants.turnResultsTable,
        where: '${DatabaseConstants.turnResultSessionId} = ?',
        whereArgs: [sessionId],
        orderBy: '${DatabaseConstants.turnResultTurnNumber} ASC',
      );

      return turnResultMaps.map((map) => TurnResult.fromMap(map)).toList();
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve turn results for session $sessionId',
        operation: 'getTurnResultsBySessionId',
        originalError: e,
      );
    }
  }

  /// Retrieve a specific turn result by ID
  Future<TurnResult?> getTurnResult(int id) async {
    try {
      final db = await database;

      final turnResultMaps = await db.query(
        DatabaseConstants.turnResultsTable,
        where: '${DatabaseConstants.turnResultId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (turnResultMaps.isEmpty) {
        return null;
      }

      return TurnResult.fromMap(turnResultMaps.first);
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve turn result with ID $id',
        operation: 'getTurnResult',
        originalError: e,
      );
    }
  }

  /// Delete all turn results for a specific session
  /// This is automatically handled by CASCADE DELETE when deleting a session
  Future<void> deleteTurnResultsBySessionId(int sessionId) async {
    try {
      final db = await database;

      await db.delete(
        DatabaseConstants.turnResultsTable,
        where: '${DatabaseConstants.turnResultSessionId} = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to delete turn results for session $sessionId',
        operation: 'deleteTurnResultsBySessionId',
        originalError: e,
      );
    }
  }

  /// Delete a specific turn result by ID
  Future<void> deleteTurnResult(int id) async {
    try {
      final db = await database;

      final deletedRows = await db.delete(
        DatabaseConstants.turnResultsTable,
        where: '${DatabaseConstants.turnResultId} = ?',
        whereArgs: [id],
      );

      if (deletedRows == 0) {
        throw db_exceptions.DatabaseException(
          'Turn result with ID $id not found',
          operation: 'deleteTurnResult',
        );
      }
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to delete turn result with ID $id',
        operation: 'deleteTurnResult',
        originalError: e,
      );
    }
  }

  /// Update turn results for a session (replace all existing turn results)
  /// This is useful when modifying a complete game session
  Future<List<TurnResult>> updateTurnResultsForSession(
    int sessionId,
    List<TurnResult> newTurnResults,
  ) async {
    try {
      // Verify the session exists
      final sessionExists = await _sessionExists(sessionId);
      if (!sessionExists) {
        throw db_exceptions.DatabaseException(
          'Session with ID $sessionId does not exist',
          operation: 'updateTurnResultsForSession',
        );
      }

      // Validate all turn results
      for (final turnResult in newTurnResults) {
        turnResult.validate();
        if (turnResult.sessionId != null && turnResult.sessionId != sessionId) {
          throw db_exceptions.DatabaseException(
            'Turn result session ID does not match target session ID',
            operation: 'updateTurnResultsForSession',
          );
        }
      }

      final db = await database;

      // Use a transaction to ensure data consistency
      return await db.transaction<List<TurnResult>>((txn) async {
        // Delete existing turn results for this session
        await txn.delete(
          DatabaseConstants.turnResultsTable,
          where: '${DatabaseConstants.turnResultSessionId} = ?',
          whereArgs: [sessionId],
        );

        // Insert new turn results
        final savedTurnResults = <TurnResult>[];
        for (final turnResult in newTurnResults) {
          final turnResultMap = turnResult
              .copyWith(sessionId: sessionId)
              .toMap();
          turnResultMap.remove(
            'id',
          ); // Remove ID to let SQLite auto-generate it

          final turnResultId = await txn.insert(
            DatabaseConstants.turnResultsTable,
            turnResultMap,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          savedTurnResults.add(
            turnResult.copyWith(id: turnResultId, sessionId: sessionId),
          );
        }

        return savedTurnResults;
      });
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to update turn results for session $sessionId',
        operation: 'updateTurnResultsForSession',
        originalError: e,
      );
    }
  }

  /// Get turn results with specific criteria (hits only, misses only, etc.)
  Future<List<TurnResult>> getTurnResultsWithFilter({
    int? sessionId,
    bool? isHit,
    int? turnNumber,
  }) async {
    try {
      final db = await database;

      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];

      if (sessionId != null) {
        whereConditions.add('${DatabaseConstants.turnResultSessionId} = ?');
        whereArgs.add(sessionId);
      }

      if (isHit != null) {
        whereConditions.add('${DatabaseConstants.turnResultIsHit} = ?');
        whereArgs.add(isHit ? 1 : 0);
      }

      if (turnNumber != null) {
        whereConditions.add('${DatabaseConstants.turnResultTurnNumber} = ?');
        whereArgs.add(turnNumber);
      }

      final whereClause = whereConditions.isNotEmpty
          ? whereConditions.join(' AND ')
          : null;

      final turnResultMaps = await db.query(
        DatabaseConstants.turnResultsTable,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy:
            '${DatabaseConstants.turnResultSessionId} ASC, ${DatabaseConstants.turnResultTurnNumber} ASC',
      );

      return turnResultMaps.map((map) => TurnResult.fromMap(map)).toList();
    } catch (e) {
      if (e is db_exceptions.DatabaseException) rethrow;
      throw db_exceptions.DatabaseException(
        'Failed to retrieve turn results with filter',
        operation: 'getTurnResultsWithFilter',
        originalError: e,
      );
    }
  }

  /// Helper method to check if a session exists
  Future<bool> _sessionExists(int sessionId) async {
    final db = await database;
    final result = await db.query(
      DatabaseConstants.gameSessionsTable,
      where: '${DatabaseConstants.gameSessionId} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
