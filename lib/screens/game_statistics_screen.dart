import 'package:flutter/material.dart';
import '../database/models/game_statistics.dart';
import '../database/services/game_statistics_service.dart';
import '../database/database_exceptions.dart';

/// Screen displaying comprehensive game statistics and performance analytics
/// Shows overall performance metrics, hit rates, and empty state handling
class GameStatisticsScreen extends StatefulWidget {
  const GameStatisticsScreen({super.key});

  @override
  State<GameStatisticsScreen> createState() => _GameStatisticsScreenState();
}

class _GameStatisticsScreenState extends State<GameStatisticsScreen> {
  final GameStatisticsService _statisticsService = GameStatisticsService();

  GameStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// Load statistics from the database
  Future<void> _loadStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statistics = await _statisticsService.calculateStatistics();

      if (mounted) {
        setState(() {
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is DatabaseException
              ? e.message
              : 'Failed to load statistics';
          _isLoading = false;
        });
      }
    }
  }

  /// Refresh statistics data
  Future<void> _refreshStatistics() async {
    await _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_statistics == null || !_statistics!.hasGames) {
      return _buildEmptyState();
    }

    return _buildStatisticsContent();
  }

  /// Build loading state with progress indicator
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading statistics...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no games have been played
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Games Played Yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Play some games to see your statistics and performance trends.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Playing'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the main statistics content
  Widget _buildStatisticsContent() {
    return RefreshIndicator(
      onRefresh: _refreshStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatsSection(),
            const SizedBox(height: 24),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            _buildDetailedStatsSection(),
          ],
        ),
      ),
    );
  }

  /// Build overall statistics section
  Widget _buildOverallStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Games',
                    _statistics!.totalGames.toString(),
                    Icons.games,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Best Score',
                    '${_statistics!.bestScore}/25',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average Score',
                    _statistics!.getFormattedAverageScore(),
                    Icons.trending_up,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Hit Rate',
                    _statistics!.getFormattedHitRate(),
                    Icons.track_changes,
                    _getHitRateColor(_statistics!.hitRate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build performance section with visual indicators
  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildHitRateIndicator(),
            const SizedBox(height: 16),
            _buildPerformanceInsights(),
          ],
        ),
      ),
    );
  }

  /// Build detailed statistics section
  Widget _buildDetailedStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailedStatRow(
              'Total Turns Played',
              _statistics!.totalTurns.toString(),
            ),
            _buildDetailedStatRow(
              'Total Hits',
              _statistics!.totalHits.toString(),
            ),
            _buildDetailedStatRow(
              'Total Misses',
              (_statistics!.totalTurns - _statistics!.totalHits).toString(),
            ),
            _buildDetailedStatRow(
              'Expected Hits (20%)',
              (_statistics!.totalTurns * 0.2).round().toString(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build hit rate visual indicator
  Widget _buildHitRateIndicator() {
    final hitRate = _statistics!.hitRate;
    final expectedRate = 20.0; // 20% is expected by chance

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hit Rate vs Expected (20%)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _statistics!.getFormattedHitRate(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getHitRateColor(hitRate),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: hitRate / 100,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(_getHitRateColor(hitRate)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: Theme.of(context).textTheme.bodySmall),
            Text(
              'Expected: ${expectedRate.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text('100%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  /// Build performance insights
  Widget _buildPerformanceInsights() {
    final hitRate = _statistics!.hitRate;
    final expectedRate = 20.0;
    final difference = hitRate - expectedRate;

    String insight;
    IconData insightIcon;
    Color insightColor;

    if (difference > 5) {
      insight = 'Excellent! Your hit rate is significantly above chance.';
      insightIcon = Icons.trending_up;
      insightColor = Colors.green;
    } else if (difference > 0) {
      insight = 'Good! Your hit rate is above the expected 20%.';
      insightIcon = Icons.thumb_up;
      insightColor = Colors.blue;
    } else if (difference > -5) {
      insight = 'Your hit rate is close to the expected 20%.';
      insightIcon = Icons.info;
      insightColor = Colors.orange;
    } else {
      insight = 'Your hit rate is below the expected 20%. Keep practicing!';
      insightIcon = Icons.trending_down;
      insightColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: insightColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(insightIcon, color: insightColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(insight, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  /// Build detailed stat row
  Widget _buildDetailedStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Get color based on hit rate performance
  Color _getHitRateColor(double hitRate) {
    if (hitRate >= 25) return Colors.green;
    if (hitRate >= 20) return Colors.blue;
    if (hitRate >= 15) return Colors.orange;
    return Colors.red;
  }
}
