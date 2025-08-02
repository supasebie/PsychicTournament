import '../database_exceptions.dart';
import '../models/game_statistics.dart';
import '../models/game_session.dart';
import 'game_database_service.dart';

/// Service for calculating and retrieving game statistics and analytics
/// Provides comprehensive performance metrics and trend analysis
class GameStatisticsService {
  final GameDatabaseService _databaseService;

  /// Creates a new GameStatisticsService instance
  /// Uses the singleton GameDatabaseService by default
  GameStatisticsService({GameDatabaseService? databaseService})
    : _databaseService = databaseService ?? GameDatabaseService.instance;

  /// Calculate comprehensive statistics from all game sessions
  /// Returns GameStatistics with all performance metrics
  Future<GameStatistics> calculateStatistics() async {
    try {
      // Get all game sessions with turn results for complete analysis
      final sessions = await _databaseService.getAllGameSessions(
        includeTurnResults: true,
      );

      if (sessions.isEmpty) {
        return GameStatistics.empty();
      }

      // Calculate basic statistics
      final totalGames = sessions.length;
      final totalScore = sessions.fold<int>(
        0,
        (sum, session) => sum + session.finalScore,
      );
      final averageScore = totalScore / totalGames;
      final bestScore = sessions
          .map((s) => s.finalScore)
          .reduce((a, b) => a > b ? a : b);

      // Calculate hit rate statistics
      int totalTurns = 0;
      int totalHits = 0;

      for (final session in sessions) {
        totalTurns += session.totalTurns;
        totalHits += session.turnResults.where((turn) => turn.isHit).length;
      }

      final hitRate = totalTurns > 0 ? (totalHits / totalTurns) * 100 : 0.0;

      // Calculate performance trends (basic implementation for now)
      final trends = await _calculateBasicTrends(sessions);

      final statistics = GameStatistics(
        totalGames: totalGames,
        averageScore: averageScore,
        bestScore: bestScore,
        hitRate: hitRate,
        trends: trends,
        totalTurns: totalTurns,
        totalHits: totalHits,
      );

      // Validate the calculated statistics
      statistics.validate();

      return statistics;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to calculate game statistics',
        operation: 'calculateStatistics',
        originalError: e,
      );
    }
  }

  /// Get the average score across all games with proper decimal handling
  /// Returns 0.0 if no games have been played
  Future<double> getAverageScore() async {
    try {
      final sessions = await _databaseService.getAllGameSessions();

      if (sessions.isEmpty) {
        return 0.0;
      }

      final totalScore = sessions.fold<int>(
        0,
        (sum, session) => sum + session.finalScore,
      );
      final averageScore = totalScore / sessions.length;

      // Round to 2 decimal places for proper decimal handling
      return double.parse(averageScore.toStringAsFixed(2));
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to calculate average score',
        operation: 'getAverageScore',
        originalError: e,
      );
    }
  }

  /// Find the maximum score across all sessions
  /// Returns 0 if no games have been played
  Future<int> getBestScore() async {
    try {
      final sessions = await _databaseService.getAllGameSessions();

      if (sessions.isEmpty) {
        return 0;
      }

      return sessions
          .map((session) => session.finalScore)
          .reduce((a, b) => a > b ? a : b);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get best score',
        operation: 'getBestScore',
        originalError: e,
      );
    }
  }

  /// Calculate hit rate as percentage of correct guesses across all games
  /// Returns 0.0 if no games have been played
  Future<double> getHitRate() async {
    try {
      final sessions = await _databaseService.getAllGameSessions(
        includeTurnResults: true,
      );

      if (sessions.isEmpty) {
        return 0.0;
      }

      int totalTurns = 0;
      int totalHits = 0;

      for (final session in sessions) {
        totalTurns += session.totalTurns;
        totalHits += session.turnResults.where((turn) => turn.isHit).length;
      }

      if (totalTurns == 0) {
        return 0.0;
      }

      final hitRate = (totalHits / totalTurns) * 100;

      // Round to 2 decimal places for proper decimal handling
      return double.parse(hitRate.toStringAsFixed(2));
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to calculate hit rate',
        operation: 'getHitRate',
        originalError: e,
      );
    }
  }

  /// Get the worst (lowest) score across all sessions
  /// Returns 0 if no games have been played
  Future<int> getWorstScore() async {
    try {
      final sessions = await _databaseService.getAllGameSessions();

      if (sessions.isEmpty) {
        return 0;
      }

      return sessions
          .map((session) => session.finalScore)
          .reduce((a, b) => a < b ? a : b);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get worst score',
        operation: 'getWorstScore',
        originalError: e,
      );
    }
  }

  /// Get total number of games played
  Future<int> getTotalGames() async {
    try {
      final sessions = await _databaseService.getAllGameSessions();
      return sessions.length;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get total games count',
        operation: 'getTotalGames',
        originalError: e,
      );
    }
  }

  /// Get total number of turns played across all games
  Future<int> getTotalTurns() async {
    try {
      final sessions = await _databaseService.getAllGameSessions();
      return sessions.fold<int>(0, (sum, session) => sum + session.totalTurns);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get total turns count',
        operation: 'getTotalTurns',
        originalError: e,
      );
    }
  }

  /// Get total number of hits across all games
  Future<int> getTotalHits() async {
    try {
      final sessions = await _databaseService.getAllGameSessions(
        includeTurnResults: true,
      );

      int totalHits = 0;
      for (final session in sessions) {
        totalHits += session.turnResults.where((turn) => turn.isHit).length;
      }

      return totalHits;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get total hits count',
        operation: 'getTotalHits',
        originalError: e,
      );
    }
  }

  /// Get performance trends analyzing score patterns over time
  /// Groups games by date and calculates trends for each time period
  Future<List<PerformanceTrend>> getPerformanceTrends({
    TrendGrouping grouping = TrendGrouping.daily,
  }) async {
    try {
      final sessions = await _databaseService.getAllGameSessions(
        includeTurnResults: true,
      );

      if (sessions.isEmpty) {
        return [];
      }

      // Group sessions by the specified time period
      final groupedSessions = _groupSessionsByDate(sessions, grouping);

      // Calculate trends for each group
      final trends = <PerformanceTrend>[];

      for (final entry in groupedSessions.entries) {
        final date = entry.key;
        final sessionsInGroup = entry.value;

        final trend = _calculateTrendForGroup(date, sessionsInGroup);
        trends.add(trend);
      }

      // Sort trends by date (most recent first)
      trends.sort((a, b) => b.date.compareTo(a.date));

      return trends;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get performance trends',
        operation: 'getPerformanceTrends',
        originalError: e,
      );
    }
  }

  /// Get performance trends filtered by date range
  /// Allows analysis of specific time periods
  Future<List<PerformanceTrend>> getPerformanceTrendsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    TrendGrouping grouping = TrendGrouping.daily,
  }) async {
    try {
      final sessions = await _databaseService.getGameSessionsByDateRange(
        startDate,
        endDate,
        includeTurnResults: true,
      );

      if (sessions.isEmpty) {
        return [];
      }

      // Group sessions by the specified time period
      final groupedSessions = _groupSessionsByDate(sessions, grouping);

      // Calculate trends for each group
      final trends = <PerformanceTrend>[];

      for (final entry in groupedSessions.entries) {
        final date = entry.key;
        final sessionsInGroup = entry.value;

        final trend = _calculateTrendForGroup(date, sessionsInGroup);
        trends.add(trend);
      }

      // Sort trends by date (most recent first)
      trends.sort((a, b) => b.date.compareTo(a.date));

      return trends;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get performance trends by date range',
        operation: 'getPerformanceTrendsByDateRange',
        originalError: e,
      );
    }
  }

  /// Get recent performance trends (last N time periods)
  /// Useful for showing recent performance patterns
  Future<List<PerformanceTrend>> getRecentPerformanceTrends(
    int periodCount, {
    TrendGrouping grouping = TrendGrouping.daily,
  }) async {
    try {
      final allTrends = await getPerformanceTrends(grouping: grouping);

      // Return the most recent trends up to the specified count
      return allTrends.take(periodCount).toList();
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get recent performance trends',
        operation: 'getRecentPerformanceTrends',
        originalError: e,
      );
    }
  }

  /// Get statistics filtered by date range
  /// Allows analysis of performance within specific time periods
  Future<GameStatistics> getStatisticsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessions = await _databaseService.getGameSessionsByDateRange(
        startDate,
        endDate,
        includeTurnResults: true,
      );

      if (sessions.isEmpty) {
        return GameStatistics.empty();
      }

      // Calculate statistics for the filtered sessions
      final totalGames = sessions.length;
      final totalScore = sessions.fold<int>(
        0,
        (sum, session) => sum + session.finalScore,
      );
      final averageScore = totalScore / totalGames;
      final bestScore = sessions
          .map((s) => s.finalScore)
          .reduce((a, b) => a > b ? a : b);

      // Calculate hit rate statistics
      int totalTurns = 0;
      int totalHits = 0;

      for (final session in sessions) {
        totalTurns += session.totalTurns;
        totalHits += session.turnResults.where((turn) => turn.isHit).length;
      }

      final hitRate = totalTurns > 0 ? (totalHits / totalTurns) * 100 : 0.0;

      // Calculate trends for the filtered data
      final trends = await getPerformanceTrendsByDateRange(startDate, endDate);

      final statistics = GameStatistics(
        totalGames: totalGames,
        averageScore: double.parse(averageScore.toStringAsFixed(2)),
        bestScore: bestScore,
        hitRate: double.parse(hitRate.toStringAsFixed(2)),
        trends: trends,
        totalTurns: totalTurns,
        totalHits: totalHits,
      );

      statistics.validate();

      return statistics;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Failed to get statistics by date range',
        operation: 'getStatisticsByDateRange',
        originalError: e,
      );
    }
  }

  /// Group game sessions by date according to the specified grouping
  Map<DateTime, List<GameSession>> _groupSessionsByDate(
    List<GameSession> sessions,
    TrendGrouping grouping,
  ) {
    final grouped = <DateTime, List<GameSession>>{};

    for (final session in sessions) {
      final groupDate = _getGroupDateForSession(session.dateTime, grouping);

      if (!grouped.containsKey(groupDate)) {
        grouped[groupDate] = [];
      }

      grouped[groupDate]!.add(session);
    }

    return grouped;
  }

  /// Get the appropriate group date for a session based on grouping type
  DateTime _getGroupDateForSession(
    DateTime sessionDate,
    TrendGrouping grouping,
  ) {
    switch (grouping) {
      case TrendGrouping.daily:
        // Group by day (midnight of the session date)
        return DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      case TrendGrouping.weekly:
        // Group by week (Monday of the week containing the session)
        final daysFromMonday = (sessionDate.weekday - 1) % 7;
        final mondayDate = sessionDate.subtract(Duration(days: daysFromMonday));
        return DateTime(mondayDate.year, mondayDate.month, mondayDate.day);

      case TrendGrouping.monthly:
        // Group by month (first day of the month)
        return DateTime(sessionDate.year, sessionDate.month, 1);
    }
  }

  /// Calculate a performance trend for a group of sessions
  PerformanceTrend _calculateTrendForGroup(
    DateTime groupDate,
    List<GameSession> sessions,
  ) {
    final gamesPlayed = sessions.length;
    final totalScore = sessions.fold<int>(
      0,
      (sum, session) => sum + session.finalScore,
    );
    final averageScore = totalScore / gamesPlayed;

    int totalTurns = 0;
    int totalHits = 0;

    for (final session in sessions) {
      totalTurns += session.totalTurns;
      totalHits += session.turnResults.where((turn) => turn.isHit).length;
    }

    final hitRate = totalTurns > 0 ? (totalHits / totalTurns) * 100 : 0.0;

    final trend = PerformanceTrend(
      date: groupDate,
      averageScore: double.parse(averageScore.toStringAsFixed(2)),
      gamesPlayed: gamesPlayed,
      hitRate: double.parse(hitRate.toStringAsFixed(2)),
    );

    trend.validate();

    return trend;
  }

  /// Calculate basic performance trends from game sessions
  /// Used internally by calculateStatistics method
  Future<List<PerformanceTrend>> _calculateBasicTrends(
    List<GameSession> sessions,
  ) async {
    // Use the public getPerformanceTrends method for consistency
    return getPerformanceTrends();
  }
}

/// Enumeration for different trend grouping options
enum TrendGrouping {
  /// Group trends by individual days
  daily,

  /// Group trends by weeks (Monday to Sunday)
  weekly,

  /// Group trends by months
  monthly,
}
