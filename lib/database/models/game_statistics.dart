import '../database_exceptions.dart';

/// Model representing performance trends over time
class PerformanceTrend {
  /// Date for this trend data point
  final DateTime date;

  /// Average score for this time period
  final double averageScore;

  /// Number of games played in this time period
  final int gamesPlayed;

  /// Hit rate percentage for this time period
  final double hitRate;

  const PerformanceTrend({
    required this.date,
    required this.averageScore,
    required this.gamesPlayed,
    required this.hitRate,
  });

  /// Validates the performance trend data
  void validate() {
    if (averageScore < 0 || averageScore > 25) {
      throw DatabaseException('Average score must be between 0 and 25');
    }

    if (gamesPlayed < 0) {
      throw DatabaseException('Games played cannot be negative');
    }

    if (hitRate < 0 || hitRate > 100) {
      throw DatabaseException('Hit rate must be between 0 and 100 percent');
    }
  }

  /// Creates a copy of this PerformanceTrend with updated values
  PerformanceTrend copyWith({
    DateTime? date,
    double? averageScore,
    int? gamesPlayed,
    double? hitRate,
  }) {
    return PerformanceTrend(
      date: date ?? this.date,
      averageScore: averageScore ?? this.averageScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      hitRate: hitRate ?? this.hitRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PerformanceTrend) return false;

    return date == other.date &&
        averageScore == other.averageScore &&
        gamesPlayed == other.gamesPlayed &&
        hitRate == other.hitRate;
  }

  @override
  int get hashCode {
    return Object.hash(date, averageScore, gamesPlayed, hitRate);
  }

  @override
  String toString() {
    return 'PerformanceTrend(date: $date, averageScore: $averageScore, '
        'gamesPlayed: $gamesPlayed, hitRate: $hitRate%)';
  }
}

/// Model representing comprehensive game statistics and analytics
class GameStatistics {
  /// Total number of games played
  final int totalGames;

  /// Average score across all games
  final double averageScore;

  /// Best (highest) score achieved
  final int bestScore;

  /// Overall hit rate as a percentage (0-100)
  final double hitRate;

  /// Performance trends over time
  final List<PerformanceTrend> trends;

  /// Total number of turns played across all games
  final int totalTurns;

  /// Total number of correct guesses across all games
  final int totalHits;

  const GameStatistics({
    required this.totalGames,
    required this.averageScore,
    required this.bestScore,
    required this.hitRate,
    required this.trends,
    required this.totalTurns,
    required this.totalHits,
  });

  /// Creates an empty GameStatistics instance for when no games have been played
  factory GameStatistics.empty() {
    return const GameStatistics(
      totalGames: 0,
      averageScore: 0.0,
      bestScore: 0,
      hitRate: 0.0,
      trends: [],
      totalTurns: 0,
      totalHits: 0,
    );
  }

  /// Validates the game statistics data
  void validate() {
    if (totalGames < 0) {
      throw DatabaseException('Total games cannot be negative');
    }

    if (averageScore < 0 || averageScore > 25) {
      throw DatabaseException('Average score must be between 0 and 25');
    }

    if (bestScore < 0 || bestScore > 25) {
      throw DatabaseException('Best score must be between 0 and 25');
    }

    if (hitRate < 0 || hitRate > 100) {
      throw DatabaseException('Hit rate must be between 0 and 100 percent');
    }

    if (totalTurns < 0) {
      throw DatabaseException('Total turns cannot be negative');
    }

    if (totalHits < 0) {
      throw DatabaseException('Total hits cannot be negative');
    }

    if (totalHits > totalTurns) {
      throw DatabaseException('Total hits cannot exceed total turns');
    }

    // Validate that calculated hit rate matches the provided value
    if (totalTurns > 0) {
      final calculatedHitRate = (totalHits / totalTurns) * 100;
      final tolerance = 0.01; // Allow small floating point differences
      if ((calculatedHitRate - hitRate).abs() > tolerance) {
        throw DatabaseException(
          'Hit rate ($hitRate%) does not match calculated value (${calculatedHitRate.toStringAsFixed(2)}%)',
        );
      }
    }

    // Validate trends
    for (final trend in trends) {
      trend.validate();
    }
  }

  /// Formats the average score to a specified number of decimal places
  String getFormattedAverageScore({int decimalPlaces = 1}) {
    return averageScore.toStringAsFixed(decimalPlaces);
  }

  /// Formats the hit rate as a percentage string
  String getFormattedHitRate({int decimalPlaces = 1}) {
    return '${hitRate.toStringAsFixed(decimalPlaces)}%';
  }

  /// Returns whether the player has any games recorded
  bool get hasGames => totalGames > 0;

  /// Returns the worst (lowest) score if we have games, otherwise 0
  int get worstScore {
    if (!hasGames) return 0;
    // This would need to be calculated from actual data in the service layer
    // For now, we'll assume it's calculated elsewhere
    return 0;
  }

  /// Creates a copy of this GameStatistics with updated values
  GameStatistics copyWith({
    int? totalGames,
    double? averageScore,
    int? bestScore,
    double? hitRate,
    List<PerformanceTrend>? trends,
    int? totalTurns,
    int? totalHits,
  }) {
    return GameStatistics(
      totalGames: totalGames ?? this.totalGames,
      averageScore: averageScore ?? this.averageScore,
      bestScore: bestScore ?? this.bestScore,
      hitRate: hitRate ?? this.hitRate,
      trends: trends ?? this.trends,
      totalTurns: totalTurns ?? this.totalTurns,
      totalHits: totalHits ?? this.totalHits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameStatistics) return false;

    return totalGames == other.totalGames &&
        averageScore == other.averageScore &&
        bestScore == other.bestScore &&
        hitRate == other.hitRate &&
        totalTurns == other.totalTurns &&
        totalHits == other.totalHits &&
        _listEquals(trends, other.trends);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalGames,
      averageScore,
      bestScore,
      hitRate,
      totalTurns,
      totalHits,
      Object.hashAll(trends),
    );
  }

  @override
  String toString() {
    return 'GameStatistics(totalGames: $totalGames, '
        'averageScore: $averageScore, bestScore: $bestScore, '
        'hitRate: $hitRate%, totalTurns: $totalTurns, '
        'totalHits: $totalHits, trends: ${trends.length})';
  }

  /// Helper method to compare lists for equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
