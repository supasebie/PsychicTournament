# Design Document

## Overview

This design implements a local database system using sqflite to store comprehensive game session data for the Psychic Tournament app. The system will capture and persist game results, enabling users to track their psychic performance over time through detailed analytics and historical data review.

The architecture follows Flutter best practices for local data persistence, implementing a repository pattern with proper separation of concerns between data models, database operations, and UI presentation layers.

## Architecture

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Service Layer  │    │  Data Layer     │
│                 │    │                 │    │                 │
│ - History Screen│◄──►│ - GameDatabase  │◄──►│ - SQLite DB     │
│ - Stats Screen  │    │   Service       │    │ - Game Sessions │
│ - Results Screen│    │ - Statistics    │    │ - Turn Results  │
│                 │    │   Service       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Database Schema

The database will consist of two main tables with a one-to-many relationship:

#### game_sessions Table

```sql
CREATE TABLE game_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date_time TEXT NOT NULL,
  coordinates TEXT NOT NULL,
  final_score INTEGER NOT NULL,
  total_turns INTEGER NOT NULL DEFAULT 25,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### turn_results Table

```sql
CREATE TABLE turn_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  turn_number INTEGER NOT NULL,
  user_guess TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  is_hit INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
);
```

### Data Flow

1. **Game Completion**: When a game ends, the ResultsReviewScreen triggers data persistence
2. **Data Transformation**: Game results are converted to database models
3. **Transaction Processing**: Both session and turn data are saved in a single transaction
4. **UI Updates**: History and statistics screens reflect the new data

## Components and Interfaces

### Core Components

#### 1. GameDatabaseService

Primary service for all database operations:

```dart
class GameDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async;
  Future<int> saveGameSession(GameSession session) async;
  Future<List<GameSession>> getAllGameSessions() async;
  Future<GameSession?> getGameSession(int id) async;
  Future<void> deleteGameSession(int id) async;
  Future<GameStatistics> getStatistics() async;
}
```

#### 2. GameStatisticsService

Handles statistical calculations and aggregations:

```dart
class GameStatisticsService {
  final GameDatabaseService _databaseService;

  Future<GameStatistics> calculateStatistics() async;
  Future<List<PerformanceTrend>> getPerformanceTrends() async;
  Future<double> getAverageScore() async;
  Future<int> getBestScore() async;
  Future<double> getHitRate() async;
}
```

### Data Models

#### GameSession Model

```dart
class GameSession {
  final int? id;
  final DateTime dateTime;
  final String coordinates;
  final int finalScore;
  final int totalTurns;
  final List<TurnResult> turnResults;

  const GameSession({
    this.id,
    required this.dateTime,
    required this.coordinates,
    required this.finalScore,
    required this.totalTurns,
    required this.turnResults,
  });

  Map<String, dynamic> toMap();
  factory GameSession.fromMap(Map<String, dynamic> map);
}
```

#### TurnResult Model

```dart
class TurnResult {
  final int? id;
  final int? sessionId;
  final int turnNumber;
  final ZenerSymbol userGuess;
  final ZenerSymbol correctAnswer;
  final bool isHit;

  const TurnResult({
    this.id,
    this.sessionId,
    required this.turnNumber,
    required this.userGuess,
    required this.correctAnswer,
    required this.isHit,
  });

  Map<String, dynamic> toMap();
  factory TurnResult.fromMap(Map<String, dynamic> map);
}
```

#### GameStatistics Model

```dart
class GameStatistics {
  final int totalGames;
  final double averageScore;
  final int bestScore;
  final double hitRate;
  final List<PerformanceTrend> trends;

  const GameStatistics({
    required this.totalGames,
    required this.averageScore,
    required this.bestScore,
    required this.hitRate,
    required this.trends,
  });
}
```

### UI Components

#### 1. GameHistoryScreen

Displays a chronological list of all game sessions:

```dart
class GameHistoryScreen extends StatefulWidget {
  // Displays list of GameSession objects
  // Supports pull-to-refresh
  // Allows navigation to detailed session view
  // Provides delete functionality with confirmation
}
```

#### 2. GameStatisticsScreen

Shows comprehensive performance analytics:

```dart
class GameStatisticsScreen extends StatefulWidget {
  // Displays overall statistics
  // Shows performance trends over time
  // Includes charts and visualizations
  // Provides filtering options (date ranges, etc.)
}
```

#### 3. SessionDetailScreen

Shows detailed turn-by-turn results for a specific session:

```dart
class SessionDetailScreen extends StatefulWidget {
  final GameSession session;

  // Displays session metadata
  // Shows turn-by-turn grid similar to ResultsReviewScreen
  // Provides session-specific statistics
  // Allows session deletion
}
```

## Data Models

### Database Integration Models

The system uses dedicated database models that map directly to SQLite tables, separate from UI models to maintain clean separation of concerns:

#### Database Schema Mapping

- **ZenerSymbol Enum**: Stored as TEXT using symbol names ('circle', 'cross', 'waves', 'square', 'star')
- **DateTime**: Stored as TEXT in ISO 8601 format for cross-platform compatibility
- **Boolean Values**: Stored as INTEGER (0/1) following SQLite conventions

### Data Conversion Layer

A conversion layer handles transformation between different data representations:

```dart
class GameDataConverter {
  static GameSession fromResultsReviewData({
    required List<List<ZenerSymbol>> gameResults,
    required int finalScore,
    required String coordinates,
  }) {
    // Convert ResultsReviewScreen data to GameSession
  }

  static List<TurnResult> convertGameResults(
    List<List<ZenerSymbol>> gameResults,
  ) {
    // Convert game results array to TurnResult objects
  }
}
```

## Error Handling

### Database Error Management

The system implements comprehensive error handling for database operations:

#### Error Categories

1. **Connection Errors**: Database initialization failures
2. **Schema Errors**: Table creation or migration issues
3. **Transaction Errors**: Data insertion/update failures
4. **Constraint Violations**: Foreign key or data validation errors

#### Error Handling Strategy

```dart
class DatabaseException implements Exception {
  final String message;
  final String? operation;
  final dynamic originalError;

  const DatabaseException(
    this.message, {
    this.operation,
    this.originalError,
  });
}

// Usage in service methods
Future<Result<GameSession>> saveGameSession(GameSession session) async {
  try {
    // Database operations
    return Result.success(savedSession);
  } on DatabaseException catch (e) {
    return Result.error(e);
  } catch (e) {
    return Result.error(DatabaseException(
      'Unexpected error saving game session',
      operation: 'saveGameSession',
      originalError: e,
    ));
  }
}
```

### UI Error Handling

UI components will handle database errors gracefully:

- **Loading States**: Show progress indicators during database operations
- **Error States**: Display user-friendly error messages with retry options
- **Offline Resilience**: All operations work offline since data is local
- **Data Validation**: Validate data before database operations
