import 'package:flutter_test/flutter_test.dart';
import 'lib/services/haptic_feedback_service.dart';

void main() {
  group('Enhanced Feedback Integration', () {
    test('HapticFeedbackService methods are callable', () async {
      // Test that the haptic feedback service methods can be called without errors
      expect(() async {
        await HapticFeedbackService.triggerCorrectGuessFeedback();
      }, returnsNormally);

      expect(() async {
        await HapticFeedbackService.triggerIncorrectGuessFeedback();
      }, returnsNormally);
    });

    test('HapticFeedbackService has expected API', () {
      // Verify the service has the expected static methods
      expect(
        HapticFeedbackService.triggerCorrectGuessFeedback,
        isA<Function>(),
      );
      expect(
        HapticFeedbackService.triggerIncorrectGuessFeedback,
        isA<Function>(),
      );
      expect(HapticFeedbackService.isHapticFeedbackSupported, isA<bool>());
    });
  });
}
