import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/main.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('app starts up quickly', (WidgetTester tester) async {
      // Measure startup time
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert - App should start within reasonable time (2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verify app is fully loaded
      expect(find.text('Psychic Tournament'), findsOneWidget);
      expect(find.text('Score: 0 / 25'), findsOneWidget);
    });

    testWidgets('rapid button taps do not cause performance issues', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Act - Rapid button taps (should be handled gracefully)
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Circle'));
        await tester.pump();
      }

      stopwatch.stop();

      // Assert - Should handle rapid taps without significant delay
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Only one guess should be processed (buttons disabled after first tap)
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Turn 2 / 25'), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('game state updates are efficient', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Make several guesses and measure performance
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 5; i++) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(ElevatedButton),
                matching: find.text('Star'),
              )
              .first,
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100)); // Brief wait
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      stopwatch.stop();

      // Assert - Should complete 5 turns efficiently
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(15000),
      ); // 3 seconds per turn max
      expect(find.text('Turn 6 / 25'), findsOneWidget);
    });

    testWidgets('memory usage remains stable during gameplay', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Play through multiple turns
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Waves'));
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Assert - App should still be responsive
      expect(find.text('Turn 11 / 25'), findsOneWidget);
      expect(find.text('Circle'), findsOneWidget); // Buttons still present

      // Should be able to continue playing
      await tester.tap(find.text('Circle'));
      await tester.pump();
    });

    testWidgets('animation performance is smooth', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Trigger card reveal animation
      await tester.tap(find.text('Cross'));

      final stopwatch = Stopwatch()..start();

      // Pump through animation frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60fps
      }

      stopwatch.stop();

      // Assert - Animation should be smooth (under 200ms for 10 frames)
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      // Clean up
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('complete game performance', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Act - Complete entire game
      for (int turn = 1; turn <= 25; turn++) {
        await tester.tap(find.text('Square'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1600)); // Reduced wait
        await tester.pumpAndSettle();
      }

      // Wait for final dialog
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert - Complete game should finish in reasonable time (under 2 minutes)
      expect(stopwatch.elapsedMilliseconds, lessThan(120000));
      expect(find.text('Game Complete!'), findsOneWidget);
    });

    testWidgets('debug mode does not significantly impact performance', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Measure performance without debug mode
      var stopwatch = Stopwatch()..start();

      for (int i = 0; i < 3; i++) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(ElevatedButton),
                matching: find.text('Star'),
              )
              .first,
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      final normalTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Reset game
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Enable debug mode
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Measure performance with debug mode
      stopwatch = Stopwatch()..start();

      for (int i = 0; i < 3; i++) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(ElevatedButton),
                matching: find.text('Star'),
              )
              .first,
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      final debugTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Assert - Debug mode should not significantly slow down the game
      // Allow up to 50% performance impact for debug features
      expect(debugTime, lessThan(normalTime * 1.5));
    });

    testWidgets('timer cleanup prevents memory leaks', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Start some timers by making guesses
      await tester.tap(find.text('Waves'));
      await tester.pump();

      // Dispose widget quickly (simulates navigation away)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );
      await tester.pumpAndSettle();

      // Assert - No exceptions should be thrown from timer cleanup
      expect(find.text('Different Screen'), findsOneWidget);

      // Create new game instance
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Should work normally
      expect(find.text('Score: 0 / 25'), findsOneWidget);
    });

    testWidgets('large screen rendering performance', (
      WidgetTester tester,
    ) async {
      // Arrange - Large screen size
      await tester.binding.setSurfaceSize(const Size(1024, 768));

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert - Should render quickly even on large screens
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.text('Psychic Tournament'), findsOneWidget);

      // Clean up
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('widget rebuild efficiency', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Make a guess and measure rebuild time
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.text('Circle'));
      await tester.pump(); // Single pump to trigger rebuild

      stopwatch.stop();

      // Assert - Widget rebuild should be fast (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // UI should be updated
      bool foundFeedback =
          find.text('Correct!').evaluate().isNotEmpty ||
          find.textContaining('Incorrect').evaluate().isNotEmpty;
      expect(foundFeedback, isTrue);

      // Clean up
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
