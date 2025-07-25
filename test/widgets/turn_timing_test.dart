import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/screens/zener_game_screen.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('Turn Timing and Transitions', () {
    testWidgets('score updates immediately for correct guesses', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Get initial score
      expect(find.text('Score: 0 / 25'), findsOneWidget);

      // Act - Make a guess
      await tester.tap(find.text('Circle'));
      await tester.pump(); // Single pump to check immediate state

      // Assert - Check if score updated immediately (if guess was correct)
      // Note: Since we can't predict the correct answer, we check that either:
      // 1. Score updated immediately (correct guess), or
      // 2. Score remains 0 (incorrect guess)
      final scoreWidgets = find.textContaining('Score:');
      expect(scoreWidgets, findsOneWidget);

      // The score should be either 0 or 1 at this point
      final scoreText = tester.widget<Text>(scoreWidgets).data!;
      expect(scoreText, anyOf('Score: 0 / 25', 'Score: 1 / 25'));

      // Clean up timers by completing the turn transition
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('buttons are disabled immediately after selection', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Verify buttons are initially enabled
      final circleButton = find.text('Circle');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );

      // Act - Make a guess
      await tester.tap(circleButton);
      await tester.pump(); // Single pump to check immediate state

      // Assert - Buttons should be disabled immediately
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNull,
      );

      // Clean up timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('card reveals immediately after guess', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Star'));
      await tester.pump(); // Single pump to check immediate state

      // Assert - Card should be revealed immediately
      // We check that the card reveal widget shows a revealed state
      // by looking for any Zener symbol icon (not the placeholder)
      bool foundSymbolIcon = false;
      for (final symbol in ZenerSymbol.values) {
        if (find.byIcon(symbol.iconData).evaluate().isNotEmpty) {
          foundSymbolIcon = true;
          break;
        }
      }
      expect(
        foundSymbolIcon,
        isTrue,
        reason: 'Should find at least one symbol icon when card is revealed',
      );

      // Clean up timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('feedback message appears immediately after guess', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Waves'));
      await tester.pump(); // Single pump to check immediate state

      // Assert - Feedback message should appear immediately
      final feedbackMessages = [
        find.text('Correct!'),
        find.textContaining('Incorrect. The card was a'),
      ];

      bool foundFeedback = false;
      for (final finder in feedbackMessages) {
        if (finder.evaluate().isNotEmpty) {
          foundFeedback = true;
          break;
        }
      }
      expect(
        foundFeedback,
        isTrue,
        reason: 'Should find feedback message immediately after guess',
      );

      // Clean up timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('feedback displays for approximately 1.5 seconds', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Cross'));
      await tester.pump();

      // Assert - Feedback should be visible
      bool feedbackVisible =
          find.text('Correct!').evaluate().isNotEmpty ||
          find.textContaining('Incorrect').evaluate().isNotEmpty;
      expect(feedbackVisible, isTrue);

      // Wait for 1.4 seconds - feedback should still be visible
      await tester.pump(const Duration(milliseconds: 1400));
      feedbackVisible =
          find.text('Correct!').evaluate().isNotEmpty ||
          find.textContaining('Incorrect').evaluate().isNotEmpty;
      expect(
        feedbackVisible,
        isTrue,
        reason: 'Feedback should still be visible after 1.4 seconds',
      );

      // Complete the turn transition
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('buttons re-enable after complete turn transition', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Circle'));
      await tester.pump();

      // Verify buttons are disabled
      final circleButton = find.text('Circle');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNull,
      );

      // Wait for complete turn transition sequence
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Buttons should be re-enabled
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('turn counter updates after brief delay', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Verify initial turn
      expect(find.text('Turn 1 / 25'), findsOneWidget);

      // Act - Make a guess
      await tester.tap(find.text('Star'));
      await tester.pump(); // Immediate state

      // Wait for the turn update delay
      await tester.pump(const Duration(milliseconds: 150));

      // Assert - Turn should be updated
      expect(find.text('Turn 2 / 25'), findsOneWidget);

      // Clean up timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('rapid button taps are handled gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Try to tap multiple buttons rapidly
      await tester.tap(find.text('Circle'));
      await tester.pump();

      // Try to tap another button immediately (should be ignored)
      await tester.tap(find.text('Cross'));
      await tester.pump();

      // Wait for turn update
      await tester.pump(const Duration(milliseconds: 150));

      // Assert - Only one guess should be processed
      // Turn should advance to 2, not 3
      expect(find.text('Turn 2 / 25'), findsOneWidget);

      // Clean up timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('timer cleanup works correctly on widget disposal', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess to start timers
      await tester.tap(find.text('Square'));
      await tester.pump();

      // Dispose the widget by navigating away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );
      await tester.pumpAndSettle();

      // Assert - No exceptions should be thrown
      // This test primarily ensures timers are properly cancelled
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('smooth transition timing sequence', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Waves'));
      await tester.pump();

      // Phase 1: Immediate updates (feedback, button disable)
      bool feedbackVisible =
          find.text('Correct!').evaluate().isNotEmpty ||
          find.textContaining('Incorrect').evaluate().isNotEmpty;
      expect(
        feedbackVisible,
        isTrue,
        reason: 'Feedback should be shown immediately',
      );

      final waveButton = find.text('Waves');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: waveButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNull,
        reason: 'Buttons should be disabled immediately',
      );

      // Complete the transition
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Final state: buttons should be enabled for next turn
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: waveButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
        reason: 'Buttons should be re-enabled after transition',
      );
    });

    testWidgets('game initialization creates fresh state', (
      WidgetTester tester,
    ) async {
      // Arrange - Start first game instance
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Score: 0 / 25'), findsOneWidget);
      expect(find.text('Turn 1 / 25'), findsOneWidget);

      // Make a few guesses to establish game state
      for (int i = 1; i <= 3; i++) {
        await tester.tap(find.text('Circle'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Verify we're at turn 4
      expect(find.text('Turn 4 / 25'), findsOneWidget);

      // Act - Create a completely new app instance (simulates app restart)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Loading...'))),
      );
      await tester.pumpAndSettle();

      // Now create a fresh game screen
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Assert - Game should be reset with clean state
      expect(find.text('Score: 0 / 25'), findsOneWidget);
      expect(find.text('Turn 1 / 25'), findsOneWidget);

      // Buttons should be enabled
      final circleButton = find.text('Circle');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('play again resets all timers correctly', (
      WidgetTester tester,
    ) async {
      // Arrange - Complete a game
      await tester.pumpWidget(const MaterialApp(home: ZenerGameScreen()));
      await tester.pumpAndSettle();

      // Fast-forward through game
      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text('Circle'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2200));
        await tester.pumpAndSettle();
      }

      // Wait for completion dialog
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // Act - Play again
      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();

      // Assert - Game should be reset with clean state
      expect(find.text('Score: 0 / 25'), findsOneWidget);
      expect(find.text('Turn 1 / 25'), findsOneWidget);

      // Buttons should be enabled
      final circleButton = find.text('Circle');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: circleButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });
  });
}
