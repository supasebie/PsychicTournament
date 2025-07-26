import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Service for managing vibration feedback during the Zener card game.
/// Provides strong vibration feedback only for correct guesses
/// with graceful fallback handling for unsupported devices.
class HapticFeedbackService {
  /// Triggers haptic feedback for a correct guess.
  /// Uses vibration with specified duration to provide strong positive reinforcement.
  ///
  /// Requirements: 3.1 - Correct guess haptic feedback
  /// Requirements: 3.3 - Appropriate vibration patterns
  /// Requirements: 3.4 - Graceful fallback for unsupported devices
  static Future<void> triggerCorrectGuessFeedback() async {
    try {
      // Check if platform supports vibration before attempting
      if (!await isVibrationSupported) {
        return;
      }

      // Use 500ms vibration for correct guess feedback
      await Vibration.vibrate(duration: 500);
    } catch (e) {
      // Graceful fallback - no vibration on unsupported devices
      // Handle various types of platform exceptions
      if (kDebugMode) {
        debugPrint('Vibration failed for correct guess: $e');
      }
      // Ensure no exceptions propagate to calling code
    }
  }

  /// No vibration feedback for incorrect guesses.
  /// This method is kept for API consistency but does not trigger any vibration.
  ///
  /// Requirements: 3.2 - No vibration feedback for incorrect guesses (updated requirement)
  /// Requirements: 3.4 - Graceful fallback for unsupported devices
  static Future<void> triggerIncorrectGuessFeedback() async {
    try {
      // No vibration feedback for incorrect guesses - silent method
      // Wrapped in try-catch for consistency and future extensibility
    } catch (e) {
      // Handle any unexpected errors gracefully
      if (kDebugMode) {
        debugPrint('Unexpected error in triggerIncorrectGuessFeedback: $e');
      }
    }
  }

  /// Checks if vibration is available on the current platform.
  /// This is primarily for testing purposes and future feature detection.
  static Future<bool> get isVibrationSupported async {
    // On web platforms, vibration is generally not supported
    if (kIsWeb) {
      return false;
    }

    try {
      // Check if device has vibrator capability
      return await Vibration.hasVibrator();
    } catch (e) {
      // If checking fails, assume no support
      if (kDebugMode) {
        debugPrint('Failed to check vibration support: $e');
      }
      return false;
    }
  }
}
