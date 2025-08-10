import 'package:flutter/material.dart';
import '../database/models/game_session.dart';
import '../database/services/game_database_service.dart';
import '../database/database_exceptions.dart';
import '../widgets/animated_gradient_background.dart';

/// Screen displaying a chronological list of all game sessions
/// Supports pagination, pull-to-refresh, loading states, and error handling
class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  final GameDatabaseService _databaseService = GameDatabaseService.instance;

  // Pagination constants
  static const int _pageSize = 8;

  // State variables
  List<GameSession> _sessions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Load initial data including first page and total count
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
        _sessions.clear();
      });

      // Get total count for pagination info
      final totalCount = await _databaseService.getTotalGameSessionsCount();

      // Load first page
      final sessions = await _databaseService.getGameSessionsPaginated(
        limit: _pageSize,
        offset: 0,
      );

      if (mounted) {
        setState(() {
          _totalSessions = totalCount;
          _sessions = sessions;
          _hasMoreData = sessions.length == _pageSize;
          _isLoading = false;
          _currentPage = 1;
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
          _errorMessage = 'Failed to load game history: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Load more sessions when scrolling to bottom
  Future<void> _loadMoreSessions() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final offset = _currentPage * _pageSize;
      final moreSessions = await _databaseService.getGameSessionsPaginated(
        limit: _pageSize,
        offset: offset,
      );

      if (mounted) {
        setState(() {
          _sessions.addAll(moreSessions);
          _hasMoreData = moreSessions.length == _pageSize;
          _isLoadingMore = false;
          _currentPage++;
        });
      }
    } on DatabaseException catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle pull-to-refresh functionality
  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Delete a game session with confirmation
  Future<void> _deleteSession(GameSession session) async {
    if (session.id == null) return;

    try {
      await _databaseService.deleteGameSession(session.id!);

      // Remove from local list and update UI
      setState(() {
        _sessions.removeWhere((s) => s.id == session.id);
        _totalSessions--; // Update total count
        // Check if we need to update hasMoreData flag
        if (_sessions.isEmpty && _hasMoreData) {
          // If we deleted the last item on this page and there's more data, load more
          _loadMoreSessions();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Game session deleted (Score: ${session.finalScore})',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DatabaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show confirmation dialog before deleting a session
  Future<void> _showDeleteConfirmation(GameSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to delete this game session?'),
              const SizedBox(height: 12),
              Text(
                'Score: ${session.finalScore}/${session.totalTurns}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Coordinates: ${session.coordinates}'),
              Text('Date: ${_formatDateTime(session.dateTime)}'),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSession(session);
    }
  }

  /// Build a single game session list item with swipe-to-delete
  Widget _buildSessionItem(GameSession session) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key('session_${session.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          await _showDeleteConfirmation(session);
          return false; // Always return false to prevent automatic dismissal
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '${session.finalScore}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            'Score: ${session.finalScore}/${session.totalTurns}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coordinates: ${session.coordinates}'),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(session.dateTime),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () => _showDeleteConfirmation(session),
                tooltip: 'Delete session',
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
          onTap: () async {
            final wasDeleted =
                await Navigator.of(
                      context,
                    ).pushNamed('/session-detail', arguments: session)
                    as bool?;

            // If session was deleted from detail screen, refresh the list
            if (wasDeleted == true) {
              await _loadInitialData();
            }
          },
          onLongPress: () => _showDeleteConfirmation(session),
        ),
      ),
    );
  }

  /// Build the empty state when no sessions exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No Game History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play some games to see your history here!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build the error state with retry option
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
            'Error Loading History',
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
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
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
          Text('Loading game history...'),
        ],
      ),
    );
  }

  /// Build the pagination controls (Load More button)
  Widget _buildPaginationControls() {
    final remainingGames = _totalSessions - _sessions.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          if (remainingGames > 0)
            Text(
              'Showing ${_sessions.length} of $_totalSessions games',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          const SizedBox(height: 12),
          if (_hasMoreData && !_isLoadingMore)
            ElevatedButton.icon(
              onPressed: _loadMoreSessions,
              icon: const Icon(Icons.expand_more),
              label: Text(
                remainingGames > _pageSize
                    ? 'Load More ($_pageSize games)'
                    : 'Load More ($remainingGames games)',
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            )
          else if (_isLoadingMore)
            const CircularProgressIndicator()
          else if (!_hasMoreData && _sessions.length >= _pageSize)
            Chip(
              label: Text(
                'All games loaded',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
              backgroundColor: Theme.of(
                context,
              ).disabledColor.withValues(alpha: 0.1),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _sessions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Column(
                    children: [
                      // List of sessions
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 64, bottom: 8),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            return _buildSessionItem(_sessions[index]);
                          },
                        ),
                      ),
                      // Pagination controls at the bottom
                      if (_sessions.length < _totalSessions || _isLoadingMore)
                        _buildPaginationControls(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
