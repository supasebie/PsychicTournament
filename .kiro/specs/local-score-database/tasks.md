# Implementation Plan

- [x] 1. Set up project dependencies and database foundation

  - Add sqflite and path dependencies to pubspec.yaml
  - Create database constants and configuration files
  - Set up basic project structure for database components
  - _Requirements: 5.1, 5.3_

- [ ] 2. Create core data models for database operations

  - [ ] 2.1 Implement GameSession model with database mapping

    - Create GameSession class with all required fields (id, dateTime, coordinates, finalScore, totalTurns)
    - Implement toMap() and fromMap() methods for SQLite serialization
    - Add validation and error handling for model data
    - _Requirements: 5.2, 6.1_

  - [ ] 2.2 Implement TurnResult model with database mapping

    - Create TurnResult class with session relationship (id, sessionId, turnNumber, userGuess, correctAnswer, isHit)
    - Implement toMap() and fromMap() methods with ZenerSymbol enum handling
    - Add proper foreign key relationship handling
    - _Requirements: 5.2, 6.1_

  - [ ] 2.3 Create GameStatistics model for analytics data
    - Implement GameStatistics class with calculated fields (totalGames, averageScore, bestScore, hitRate)
    - Create PerformanceTrend model for trend analysis
    - Add data validation and formatting methods
    - _Requirements: 3.1, 3.3_

- [ ] 3. Implement database service layer

  - [ ] 3.1 Create GameDatabaseService with core CRUD operations

    - Implement database initialization with proper schema creation
    - Create methods for opening/closing database connections
    - Add database migration handling for future schema updates
    - Implement proper error handling with custom DatabaseException class
    - _Requirements: 5.1, 5.3, 5.4_

  - [ ] 3.2 Implement game session persistence methods

    - Create saveGameSession() method with transaction support
    - Implement getAllGameSessions() with proper sorting (most recent first)
    - Add getGameSession(id) method for individual session retrieval
    - Create deleteGameSession(id) method with cascade deletion of turn results
    - _Requirements: 1.1, 1.3, 2.2, 4.2_

  - [ ] 3.3 Implement turn results database operations
    - Create methods to save multiple TurnResult objects in a single transaction
    - Implement retrieval methods for turn results by session ID
    - Add proper foreign key constraint handling
    - Ensure data integrity between sessions and turn results
    - _Requirements: 1.3, 2.3, 5.2_

- [ ] 4. Create data conversion and integration layer

  - [ ] 4.1 Implement GameDataConverter for existing data integration

    - Create fromResultsReviewData() method to convert current game results format
    - Implement convertGameResults() to transform List<List<ZenerSymbol>> to TurnResult objects
    - Add proper date/time handling and coordinate extraction
    - Ensure data validation during conversion process
    - _Requirements: 1.1, 1.3, 6.1_

  - [ ] 4.2 Integrate database saving into ResultsReviewScreen
    - Modify ResultsReviewScreen to trigger database save after game completion
    - Add error handling for database save operations with user feedback
    - Ensure database operations don't block UI responsiveness
    - Implement fallback behavior if database save fails
    - _Requirements: 1.1, 1.4, 6.3_

- [ ] 5. Implement statistics calculation service

  - [ ] 5.1 Create GameStatisticsService with core analytics

    - Implement calculateStatistics() method with database aggregation queries
    - Create getAverageScore() method with proper decimal handling
    - Add getBestScore() method to find maximum score across all sessions
    - Implement getHitRate() calculation as percentage of correct guesses
    - _Requirements: 3.1, 3.2_

  - [ ] 5.2 Add performance trend analysis
    - Create getPerformanceTrends() method to analyze score patterns over time
    - Implement date-based grouping for trend calculations
    - Add methods for filtering statistics by date ranges
    - Ensure efficient database queries for large datasets
    - _Requirements: 3.3_

- [ ] 6. Create game history UI screen

  - [ ] 6.1 Implement GameHistoryScreen with session list display

    - Create StatefulWidget with proper state management for database data
    - Implement ListView with GameSession items showing date, coordinates, and score
    - Add pull-to-refresh functionality to reload data from database
    - Implement proper loading states and error handling for database operations
    - _Requirements: 2.1, 2.2_

  - [ ] 6.2 Add session deletion functionality

    - Implement swipe-to-delete or long-press delete options for sessions
    - Add confirmation dialog before deleting sessions
    - Update UI immediately after successful deletion
    - Handle deletion errors gracefully with user feedback
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ] 6.3 Add navigation to detailed session view
    - Implement onTap navigation to SessionDetailScreen
    - Pass GameSession data properly between screens
    - Add proper back navigation handling
    - Ensure smooth transitions between screens
    - _Requirements: 2.3_

- [ ] 7. Create detailed session view screen

  - [ ] 7.1 Implement SessionDetailScreen with turn-by-turn display

    - Create screen layout similar to ResultsReviewScreen with 5x5 grid
    - Display session metadata (date, time, coordinates, final score)
    - Show individual turn results with user guess vs correct answer
    - Implement proper visual indicators for hits and misses
    - _Requirements: 2.3_

  - [ ] 7.2 Add session-specific statistics and actions
    - Display session-specific hit rate and performance metrics
    - Add delete session functionality with confirmation
    - Implement share session results feature
    - Add navigation back to history screen
    - _Requirements: 2.3, 4.1, 4.2_

- [ ] 8. Create statistics dashboard screen

  - [ ] 8.1 Implement GameStatisticsScreen with overall performance metrics

    - Create screen layout displaying total games, average score, and best score
    - Show overall hit rate percentage with visual indicators
    - Add empty state handling when no games have been played
    - Implement proper loading states for statistics calculations
    - _Requirements: 3.1, 3.2, 3.4_

  - [ ] 8.2 Add performance trends and visualizations
    - Implement basic charts or graphs showing performance over time
    - Add date range filtering options for statistics
    - Create visual representations of hit rate trends
    - Ensure responsive design for different screen sizes
    - _Requirements: 3.3_

- [ ] 9. Add navigation integration to main app

  - [ ] 9.1 Update main menu with database-related navigation

    - Add "Game History" button to MainMenuScreen
    - Add "Statistics" button to MainMenuScreen
    - Implement proper navigation routing for new screens
    - Ensure consistent UI design with existing app theme
    - _Requirements: 2.1, 3.1_

  - [ ] 9.2 Update app routing and navigation structure
    - Add named routes for new screens in main.dart
    - Implement proper navigation flow between all screens
    - Add back navigation handling for all new screens
    - Ensure navigation state is properly managed
    - _Requirements: 2.1, 2.2, 3.1_

- [ ] 10. Implement comprehensive error handling and data validation

  - [ ] 10.1 Add database error handling throughout the app

    - Implement proper try-catch blocks for all database operations
    - Create user-friendly error messages for database failures
    - Add retry mechanisms for transient database errors
    - Ensure app continues to function even if database operations fail
    - _Requirements: 1.4, 5.4, 6.3_

  - [ ] 10.2 Add data validation and integrity checks
    - Validate all data before database insertion
    - Implement checks for data consistency between sessions and turn results
    - Add validation for date formats and coordinate strings
    - Ensure ZenerSymbol enum values are properly handled in database operations
    - _Requirements: 5.2, 5.4, 6.1_
