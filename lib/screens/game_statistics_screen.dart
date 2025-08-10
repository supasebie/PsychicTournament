import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/models/game_statistics.dart';
import '../database/services/game_statistics_service.dart';
import '../database/database_exceptions.dart';
import '../widgets/animated_gradient_background.dart';

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

  // Date range filtering
  DateTime? _startDate;
  DateTime? _endDate;
  TrendGrouping _selectedGrouping = TrendGrouping.daily;

  // Chart display options
  bool _showScoreChart = true;
  bool _showHitRateChart = true;

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
      GameStatistics statistics;

      if (_startDate != null && _endDate != null) {
        // Load statistics for the selected date range
        statistics = await _statisticsService.getStatisticsByDateRange(
          _startDate!,
          _endDate!,
        );
      } else {
        // Load all statistics
        statistics = await _statisticsService.calculateStatistics();
      }

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

  /// Show date range picker dialog
  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadStatistics();
    }
  }

  /// Clear date range filter
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadStatistics();
  }

  /// Change trend grouping
  void _changeTrendGrouping(TrendGrouping grouping) {
    setState(() {
      _selectedGrouping = grouping;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
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
    // Show only the spinner to avoid layout/jank from early text flashes.
    return const Center(child: CircularProgressIndicator());
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
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
            _buildDateFilterSection(),
            const SizedBox(height: 16),
            _buildOverallStatsSection(),
            const SizedBox(height: 24),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            if (_statistics!.trends.isNotEmpty) ...[
              _buildTrendsSection(),
              const SizedBox(height: 24),
            ],
            _buildDetailedStatsSection(),
          ],
        ),
      ),
    );
  }

  /// Build date filter section
  Widget _buildDateFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date Range Filter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_startDate != null && _endDate != null)
                  TextButton.icon(
                    onPressed: _clearDateFilter,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDateRangePicker,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
              ],
            ),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Showing data from ${_formatDate(_startDate!)} to ${_formatDate(_endDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build trends visualization section
  Widget _buildTrendsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                PopupMenuButton<TrendGrouping>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: _changeTrendGrouping,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: TrendGrouping.daily,
                      child: Text('Daily'),
                    ),
                    const PopupMenuItem(
                      value: TrendGrouping.weekly,
                      child: Text('Weekly'),
                    ),
                    const PopupMenuItem(
                      value: TrendGrouping.monthly,
                      child: Text('Monthly'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildChartToggleButtons(),
            const SizedBox(height: 16),
            if (_showScoreChart) ...[
              _buildScoreChart(),
              const SizedBox(height: 24),
            ],
            if (_showHitRateChart) ...[
              _buildHitRateChart(),
              const SizedBox(height: 16),
            ],
            _buildTrendInsights(),
          ],
        ),
      ),
    );
  }

  /// Build chart toggle buttons
  Widget _buildChartToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('Score Trend'),
            selected: _showScoreChart,
            onSelected: (selected) {
              setState(() {
                _showScoreChart = selected;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            label: const Text('Hit Rate Trend'),
            selected: _showHitRateChart,
            onSelected: (selected) {
              setState(() {
                _showHitRateChart = selected;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Build score trend chart
  Widget _buildScoreChart() {
    if (_statistics!.trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final trends = _statistics!.trends.reversed
        .toList(); // Show chronologically
    final maxScore = trends
        .map((t) => t.averageScore)
        .reduce((a, b) => a > b ? a : b);
    final minScore = trends
        .map((t) => t.averageScore)
        .reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Score Over Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < trends.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _formatTrendDate(trends[index].date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              minX: 0,
              maxX: (trends.length - 1).toDouble(),
              minY: (minScore - 2).clamp(0, 25),
              maxY: (maxScore + 2).clamp(0, 25),
              lineBarsData: [
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.averageScore,
                    );
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build hit rate trend chart
  Widget _buildHitRateChart() {
    if (_statistics!.trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final trends = _statistics!.trends.reversed
        .toList(); // Show chronologically
    final maxHitRate = trends
        .map((t) => t.hitRate)
        .reduce((a, b) => a > b ? a : b);
    final minHitRate = trends
        .map((t) => t.hitRate)
        .reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hit Rate Over Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 10,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: value == 20
                        ? Colors.orange.withValues(
                            alpha: 0.8,
                          ) // Expected 20% line
                        : Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: value == 20 ? 2 : 1,
                    dashArray: value == 20 ? [5, 5] : null,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < trends.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _formatTrendDate(trends[index].date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              minX: 0,
              maxX: (trends.length - 1).toDouble(),
              minY: (minHitRate - 5).clamp(0, 100),
              maxY: (maxHitRate + 5).clamp(0, 100),
              lineBarsData: [
                LineChartBarData(
                  spots: trends.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.hitRate);
                  }).toList(),
                  isCurved: true,
                  color: _getHitRateColor(_statistics!.hitRate),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _getHitRateColor(
                      _statistics!.hitRate,
                    ).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Orange dashed line shows expected 20% hit rate',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.orange),
        ),
      ],
    );
  }

  /// Build trend insights
  Widget _buildTrendInsights() {
    if (_statistics!.trends.length < 2) {
      return const SizedBox.shrink();
    }

    final trends = _statistics!.trends;
    final recentTrend = trends.first;
    final previousTrend = trends[1];

    final scoreDifference =
        recentTrend.averageScore - previousTrend.averageScore;
    final hitRateDifference = recentTrend.hitRate - previousTrend.hitRate;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Trend Analysis',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                scoreDifference >= 0 ? Icons.trending_up : Icons.trending_down,
                color: scoreDifference >= 0 ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Score: ${scoreDifference >= 0 ? '+' : ''}${scoreDifference.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                hitRateDifference >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: hitRateDifference >= 0 ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Hit Rate: ${hitRateDifference >= 0 ? '+' : ''}${hitRateDifference.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format trend date based on grouping
  String _formatTrendDate(DateTime date) {
    switch (_selectedGrouping) {
      case TrendGrouping.daily:
        return '${date.day}/${date.month}';
      case TrendGrouping.weekly:
        return 'W${_getWeekOfYear(date)}';
      case TrendGrouping.monthly:
        return '${date.month}/${date.year}';
    }
  }

  /// Get week of year for date
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
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
        color: insightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: insightColor.withValues(alpha: 0.3)),
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
