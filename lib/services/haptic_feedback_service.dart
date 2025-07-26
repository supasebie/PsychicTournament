import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service for managing haptic feedback during the Zener card game.
/// Provides strong vibration feedback only for correct guesses
/// with graceful fallback handling for unsupported devices.
class HapticFeedbackService {
  /// Triggers haptic feedback for a correct guess.
  /// Uses long vibration pattern to provide strong positive reinforcement.
  ///
  /// Requirements: 3.1 - Correct guess haptic feedback
  /// Requirements: 3.3 - Appropriate vibration patterns
  /// Requirements: 3.4 - Graceful fallback for unsupported devices
  static Future<void> triggerCorrectGuessFeedback() async {
    try {
      // Check if platform supports haptic feedback before attempting
      if (!isHapticFeedbackSupported) {
        return;
      }

      await HapticFeedback.vibrate();
    } catch (e) {
      // Graceful fallback - no vibration on unsupported devices
      // Handle various types of platform exceptions
      if (kDebugMode) {
        debugPrint('Haptic feedback failed for correct guess: $e');
      }
      // Ensure no exceptions propagate to calling code
    }
  }

  /// No haptic feedback for incorrect guesses.
  /// This method is kept for API consistency but does not trigger any vibration.
  ///
  /// Requirements: 3.2 - No haptic feedback for incorrect guesses (updated requirement)
  /// Requirements: 3.4 - Graceful fallback for unsupported devices
  static Future<void> triggerIncorrectGuessFeedback() async {
    try {
      // No haptic feedback for incorrect guesses - silent method
      // Wrapped in try-catch for consistency and future extensibility
    } catch (e) {
      // Handle any unexpected errors gracefully
      if (kDebugMode) {
        debugPrint('Unexpected error in triggerIncorrectGuessFeedback: $e');
      }
    }
  }

  /// Checks if haptic feedback is available on the current platform.
  /// This is primarily for testing purposes and future feature detection.
  static bool get isHapticFeedbackSupported {
    // On web platforms, haptic feedback is generally not supported
    if (kIsWeb) {
      return false;
    }

    // For mobile platforms, we assume support and handle failures gracefully
    // in the individual feedback methods
    return true;
  }
}
