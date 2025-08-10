import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/models/game_session.dart';
import '../database/models/turn_result.dart';
import '../database/services/game_database_service.dart';
import '../database/database_exceptions.dart';
import '../models/zener_symbol.dart';
import '../widgets/svg_symbol.dart';

/// Screen showing detailed turn-by-turn results for a specific game session
/// Displays session metadata, 5x5 grid of results, and session-specific statistics
class SessionDetailScreen extends StatefulWidget {
  final GameSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final GameDatabaseService _databaseService = GameDatabaseService.instance;

  GameSession? _sessionWithTurnResults;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessionDetails();
  }

  /// Load the complete session with turn results
  Future<void> _loadSessionDetails() async {
    if (widget.session.id == null) {
      setState(() {
        _errorMessage = 'Invalid session ID';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final sessionWithResults = await _databaseService.getGameSession(
        widget.session.id!,
        includeTurnResults: true,
      );

      if (mounted) {
        setState(() {
          _sessionWithTurnResults = sessionWithResults;
          _isLoading = false;
        });
      }
    } on DatabaseException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Database error: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load session details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Calculate hit rate for this session
  double _calculateHitRate() {
    if (_sessionWithTurnResults?.turnResults.isEmpty ?? true) return 0.0;

    final hits = _sessionWithTurnResults!.turnResults
        .where((result) => result.isHit)
        .length;

    return (hits / _sessionWithTurnResults!.turnResults.length) * 100;
  }

  /// Delete the current session with confirmation
  Future<void> _deleteSession() async {
    final session = _sessionWithTurnResults ?? widget.session;
    if (session.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this game session? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _databaseService.deleteGameSession(session.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Share session results
  Future<void> _shareSession() async {
    final session = _sessionWithTurnResults ?? widget.session;
    final hitRate = _calculateHitRate();

    final shareText =
        '''
🔮 Psychic Tournament Results 🔮

📅 Date: ${_formatDateTime(session.dateTime)}
🎯 Coordinates: ${session.coordinates}
📊 Score: ${session.finalScore}/${session.totalTurns}
🎯 Hit Rate: ${hitRate.toStringAsFixed(1)}%

${session.finalScore >= 13 ? '🌟 Above average performance!' : '💪 Keep practicing your psychic abilities!'}

#PsychicTournament #ESP #ZenerCards
''';

    try {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session results copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy results: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Build the session metadata header
  Widget _buildSessionHeader() {
    final session = _sessionWithTurnResults ?? widget.session;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game Session',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${session.finalScore}/${session.totalTurns}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Coordinates', session.coordinates),
            _buildInfoRow('Date & Time', _formatDateTime(session.dateTime)),
            if (_sessionWithTurnResults?.turnResults.isNotEmpty ?? false) ...[
              _buildInfoRow(
                'Hit Rate',
                '${_calculateHitRate().toStringAsFixed(1)}%',
              ),
              _buildInfoRow(
                'Hits',
                '${_sessionWithTurnResults!.turnResults.where((r) => r.isHit).length}',
              ),
              _buildInfoRow(
                'Misses',
                '${_sessionWithTurnResults!.turnResults.where((r) => !r.isHit).length}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build performance metrics section
  Widget _buildPerformanceMetrics() {
    if (_sessionWithTurnResults?.turnResults.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final turnResults = _sessionWithTurnResults!.turnResults;
    final hitRate = _calculateHitRate();
    final expectedHitRate = 20.0; // 1 in 5 chance for random guessing
    final performance = hitRate - expectedHitRate;

    // Calculate performance by symbol
    final symbolStats = <ZenerSymbol, Map<String, int>>{};
    for (final symbol in ZenerSymbol.values) {
      final symbolTurns = turnResults.where((r) => r.correctAnswer == symbol);
      final symbolHits = symbolTurns.where((r) => r.isHit).length;
      symbolStats[symbol] = {'total': symbolTurns.length, 'hits': symbolHits};
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Analysis',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Overall performance indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: performance > 0
                    ? Colors.green.shade50
                    : performance < 0
                    ? Colors.red.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: performance > 0
                      ? Colors.green
                      : performance < 0
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    performance > 0
                        ? Icons.trending_up
                        : performance < 0
                        ? Icons.trending_down
                        : Icons.trending_flat,
                    color: performance > 0
                        ? Colors.green
                        : performance < 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      performance > 0
                          ? 'Above random chance by ${performance.toStringAsFixed(1)}%'
                          : performance < 0
                          ? 'Below random chance by ${performance.abs().toStringAsFixed(1)}%'
                          : 'At random chance level',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: performance > 0
                            ? Colors.green.shade700
                            : performance < 0
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Symbol-specific performance
            Text(
              'Performance by Symbol',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...ZenerSymbol.values.map((symbol) {
              final stats = symbolStats[symbol]!;
              final total = stats['total']!;
              final hits = stats['hits']!;
              final symbolHitRate = total > 0 ? (hits / total) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SvgSymbol(assetPath: symbol.assetPath, size: 20),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        symbol.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? hits / total : 0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          symbolHitRate > 20 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '$hits/$total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build an info row for the session header
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the 5x5 grid showing turn results
  Widget _buildResultsGrid() {
    if (_sessionWithTurnResults?.turnResults.isEmpty ?? true) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No turn results available')),
        ),
      );
    }

    final turnResults = _sessionWithTurnResults!.turnResults;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Turn Results',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: turnResults.length,
              itemBuilder: (context, index) {
                final turnResult = turnResults[index];
                return _buildTurnResultCell(turnResult);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single cell in the results grid
  Widget _buildTurnResultCell(TurnResult turnResult) {
    final isHit = turnResult.isHit;
    final backgroundColor = isHit ? Colors.green.shade100 : Colors.red.shade100;
    final borderColor = isHit ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Turn number
          Text(
            '${turnResult.turnNumber}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 2),
          // User guess icon
          SvgSymbol(assetPath: turnResult.userGuess.assetPath, size: 16),
          // Correct answer icon (if different from guess)
          if (!isHit) ...[
            const SizedBox(height: 2),
            SvgSymbol(assetPath: turnResult.correctAnswer.assetPath, size: 14),
          ],
        ],
      ),
    );
  }

  /// Build the legend explaining the grid symbols
  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Hit (correct guess)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Miss (incorrect guess)'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Blue icon: Your guess\nGray icon: Correct answer (shown on misses)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading session details...'),
        ],
      ),
    );
  }

  /// Build the error state
  Widget _buildErrorState() {
    return Center(
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
            'Error Loading Session',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadSessionDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSessionHeader(),
                  _buildPerformanceMetrics(),
                  const SizedBox(height: 8),
                  _buildResultsGrid(),
                  _buildLegend(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
