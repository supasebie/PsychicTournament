import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service for managing Supabase authentication and database operations
class SupabaseService {
  static bool _isInitialized = false;

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase with your project credentials
  static Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase initialization error: $e');
      }
      // Don't rethrow - allow app to continue without Supabase in case of platform issues
    }
  }

  /// Get the current user
  static User? get currentUser {
    try {
      if (!_isInitialized) return null;
      return client.auth.currentUser;
    } catch (e) {
      // Return null if Supabase is not initialized (e.g., in tests)
      return null;
    }
  }

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Supabase is not initialized. Please check your configuration.',
      );
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Supabase is not initialized. Please check your configuration.',
      );
    }

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    if (!_isInitialized) {
      throw Exception(
        'Supabase is not initialized. Please check your configuration.',
      );
    }

    try {
      await client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Reset password for email
  static Future<void> resetPassword(String email) async {
    if (!_isInitialized) {
      throw Exception(
        'Supabase is not initialized. Please check your configuration.',
      );
    }

    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Reset password error: $e');
      }
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    try {
      if (!_isInitialized) return const Stream.empty();
      return client.auth.onAuthStateChange;
    } catch (e) {
      return const Stream.empty();
    }
  }

  /// Get user display name
  static String? get userDisplayName {
    try {
      if (!_isInitialized) return null;
      final user = currentUser;
      if (user == null) return null;

      // Try to get display name from user metadata
      final displayName = user.userMetadata?['display_name'] as String?;
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }

      // Fallback to email
      return user.email;
    } catch (e) {
      // Return null if Supabase is not initialized (e.g., in tests)
      return null;
    }
  }

  /// Get user email
  static String? get userEmail {
    try {
      if (!_isInitialized) return null;
      return currentUser?.email;
    } catch (e) {
      // Return null if Supabase is not initialized (e.g., in tests)
      return null;
    }
  }

  /// Check if Supabase is properly initialized
  static bool get isInitialized => _isInitialized;
}
