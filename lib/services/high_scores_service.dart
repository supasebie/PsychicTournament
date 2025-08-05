import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Service for inserting and querying high scores in Supabase.
/// Table: public.high_scores (username text, score int, recorded_at timestamptz default now())
class HighScoresService {
  HighScoresService._();
  static final HighScoresService instance = HighScoresService._();

  SupabaseClient get _client => SupabaseService.client;

  /// Insert a high score if Supabase is initialized.
  /// Username resolution:
  /// - If authenticated: use user.userMetadata['display_name'] if present, else 'Anon'
  /// - If not authenticated: 'Anon'
  ///
  /// The database enforces score >= 11 via CHECK and RLS. We guard in app as well.
  Future<bool> insertHighScore({
    required int score,
    DateTime? recordedAtUtc,
  }) async {
    try {
      // Ensure Supabase initialized
      if (!SupabaseService.isInitialized) {
        if (kDebugMode) {
          debugPrint(
            'HighScoresService: Supabase is not initialized, skipping insert',
          );
        }
        return false;
      }

      // Guard low scores (also enforced by DB)
      if (score < 11) {
        if (kDebugMode) {
          debugPrint('HighScoresService: Score < 11, not inserting');
        }
        return false;
      }

      // Resolve username
      String username = 'Anon';
      final user = SupabaseService.currentUser;
      if (user != null) {
        final meta = user.userMetadata ?? {};
        final displayName = meta['display_name'];
        if (displayName is String && displayName.isNotEmpty) {
          username = displayName;
        }
      }

      final payload = <String, dynamic>{
        'username': username,
        'score': score,
        if (recordedAtUtc != null)
          'recorded_at': recordedAtUtc.toUtc().toIso8601String(),
      };

      await _client.from('high_scores').insert(payload);
      if (kDebugMode) {
        debugPrint(
          'HighScoresService: Inserted high score for $username with score $score',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HighScoresService: Error inserting high score: $e');
      }
      // Silent failure by returning false
      return false;
    }
  }

  /// Optional: fetch top N scores ordered by score desc, then recorded_at desc.
  Future<List<Map<String, dynamic>>> fetchTopScores({int limit = 20}) async {
    try {
      if (!SupabaseService.isInitialized) {
        if (kDebugMode) {
          debugPrint(
            'HighScoresService: Supabase is not initialized, fetchTopScores returns empty',
          );
        }
        return const [];
      }

      final data = await _client
          .from('high_scores')
          .select()
          .order('score', ascending: false)
          .order('recorded_at', ascending: false)
          .limit(limit);

      // data is List<dynamic> from supabase_flutter; cast to Map<String, dynamic>
      return (data as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HighScoresService: Error fetching top scores: $e');
      }
      return const [];
    }
  }

  /// Fetch the individual highest score recorded for the current UTC day.
  /// Returns a single record in a list (0 or 1).
  Future<List<Map<String, dynamic>>> fetchTopScoreToday() async {
    try {
      if (!SupabaseService.isInitialized) {
        return const [];
      }

      // UTC day boundaries
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day);
      final startIso = startOfDay.toIso8601String();

      final data = await _client
          .from('high_scores')
          .select()
          .gte('recorded_at', startIso)
          .order('score', ascending: false)
          .order('recorded_at', ascending: false)
          .limit(1);

      return (data as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HighScoresService: Error fetching top score today: $e');
      }
      return const [];
    }
  }

  /// Fetch the top 3 scores for the current UTC month.
  Future<List<Map<String, dynamic>>> fetchTopScoreThisMonth() async {
    try {
      if (!SupabaseService.isInitialized) {
        return const [];
      }

      // UTC month start
      final now = DateTime.now().toUtc();
      final startOfMonth = DateTime.utc(now.year, now.month, 1);
      final startIso = startOfMonth.toIso8601String();

      final data = await _client
          .from('high_scores')
          .select()
          .gte('recorded_at', startIso)
          .order('score', ascending: false)
          .order('recorded_at', ascending: false)
          .limit(3);

      return (data as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'HighScoresService: Error fetching top scores this month: $e',
        );
      }
      return const [];
    }
  }
}
