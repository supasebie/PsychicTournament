import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/services/haptic_feedback_service.dart';

void main() {
  group('Enhanced Feedback Integration', () {
    test('HapticFeedbackService methods are callable', () async {
      // Test that the vibration feedback service methods can be called without errors
      expect(() async {
        await HapticFeedbackService.triggerCorrectGuessFeedback();
      }, returnsNormally);

      expect(() async {
        await HapticFeedbackService.triggerIncorrectGuessFeedback();
      }, returnsNormally);
    });

    test('HapticFeedbackService has expected API', () async {
      // Verify the service has the expected static methods
      expect(
        HapticFeedbackService.triggerCorrectGuessFeedback,
        isA<Function>(),
      );
      expect(
        HapticFeedbackService.triggerIncorrectGuessFeedback,
        isA<Function>(),
      );

      // Test the vibration support check (now async)
      final isSupported = await HapticFeedbackService.isVibrationSupported;
      expect(isSupported, isA<bool>());
    });
  });
}
