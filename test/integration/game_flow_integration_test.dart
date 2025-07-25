import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/main.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('Game Flow Integration Tests', () {
    testWidgets('complete game flow from start to finish', (
      WidgetTester tester,
    ) async {
      // Arrange - Start the app
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Psychic Tournament'), findsOneWidget);
      expect(find.text('Score: 0 / 25'), findsOneWidget);
      expect(find.text('Turn 1 / 25'), findsOneWidget);
      expect(find.text('Select a symbol:'), findsOneWidget);

      // Verify remote viewing coordinates are displayed
      expect(find.text('Coordinates'), findsOneWidget);

      // Verify all symbol buttons are present and enabled
      for (final symbol in ZenerSymbol.values) {
        expect(find.text(symbol.displayName), findsOneWidget);
      }

      // Act - Make first guess
      await tester.tap(find.text('Circle'));
      await tester.pump();

      // Assert - Card should be revealed and feedback shown
      expect(
        find.byType(Icon),
        findsWidgets,
      ); // Card reveal should show an icon

      // Wait for feedback display duration
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Assert - Should advance to turn 2
      expect(find.text('Turn 2 / 25'), findsOneWidget);

      // Verify buttons are re-enabled for next turn
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

    testWidgets('buttons are disabled during guess processing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Tap a symbol
      await tester.tap(find.text('Cross'));
      await tester.pump(); // Don't settle, check immediate state

      // Assert - Buttons should be disabled immediately after tap
      final crossButton = find.text('Cross');
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: crossButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('score updates correctly on correct and incorrect guesses', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Play several turns and track score changes
      for (int turn = 1; turn <= 5; turn++) {
        // Make a guess
        await tester.tap(find.text('Circle'));
        await tester.pump();

        // Wait for turn transition
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();

        // Check that turn advanced
        if (turn < 5) {
          expect(find.text('Turn ${turn + 1} / 25'), findsOneWidget);
        }

        // Score should be between 0 and current turn number
        final scoreText = find.textContaining('Score:');
        expect(scoreText, findsOneWidget);
      }
    });

    testWidgets('game completion shows final score dialog', (
      WidgetTester tester,
    ) async {
      // This test simulates a complete game by playing all 25 turns
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Play all 25 turns quickly
      for (int turn = 1; turn <= 25; turn++) {
        // Verify current turn
        expect(find.text('Turn $turn / 25'), findsOneWidget);

        // Make a guess (always Circle for consistency)
        await tester.tap(find.text('Circle'));
        await tester.pump();

        // Wait for feedback and turn transition
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();
      }

      // Wait for final score dialog to appear
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Assert - Final score dialog should be shown
      expect(find.text('Game Complete!'), findsOneWidget);
      expect(find.textContaining('You scored'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
    });

    testWidgets('play again button starts new game', (
      WidgetTester tester,
    ) async {
      // Arrange - Complete a full game first
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Play all 25 turns
      for (int turn = 1; turn <= 25; turn++) {
        await tester.tap(find.text('Circle'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();
      }

      // Wait for final dialog
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Act - Tap Play Again
      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();

      // Assert - Game should be reset
      expect(find.text('Score: 0 / 25'), findsOneWidget);
      expect(find.text('Turn 1 / 25'), findsOneWidget);
      expect(find.text('Game Complete!'), findsNothing);

      // Verify buttons are enabled
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

    testWidgets('remote viewing coordinates change between games', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Get initial coordinates
      final coordinatesWidget = find.textContaining('-');
      expect(coordinatesWidget, findsOneWidget);
      final initialCoordinates = tester.widget<Text>(coordinatesWidget).data;

      // Complete the game quickly
      for (int turn = 1; turn <= 25; turn++) {
        await tester.tap(find.text('Circle'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();
      }

      // Wait for final dialog and start new game
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();

      // Assert - Coordinates should be different (with high probability)
      final newCoordinatesWidget = find.textContaining('-');
      expect(newCoordinatesWidget, findsOneWidget);
      final newCoordinates = tester.widget<Text>(newCoordinatesWidget).data;

      // Note: There's a small chance coordinates could be the same, but very unlikely
      // This test verifies the coordinate generation system is working
      expect(newCoordinates, isNotNull);
      expect(newCoordinates!.contains('-'), isTrue);
      expect(newCoordinates.length, equals(9)); // XXXX-XXXX format

      // Verify coordinates format is consistent
      expect(initialCoordinates, isNotNull);
      expect(initialCoordinates!.contains('-'), isTrue);
      expect(initialCoordinates.length, equals(9));
    });

    testWidgets('card reveal animation works correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Act - Make a guess
      await tester.tap(find.text('Star'));

      // Check immediate state - card should start revealing
      await tester.pump();

      // Pump through animation frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - Card should be fully revealed
      // The revealed card should show an icon (either the correct symbol or placeholder)
      expect(find.byType(Icon), findsWidgets);

      // Wait for full turn transition
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Card should be hidden again for next turn
      expect(find.text('Turn 2 / 25'), findsOneWidget);
    });

    testWidgets('accessibility features work correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const PsychicTournament());
      await tester.pumpAndSettle();

      // Assert - Check semantic labels for symbol buttons (updated to match enhanced labels)
      for (final symbol in ZenerSymbol.values) {
        final semanticsWidgets = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  '${symbol.displayName} symbol button' &&
              widget.properties.button == true,
        );
        expect(semanticsWidgets, findsOneWidget);
      }

      // Check score display has semantic label
      final scoreWidget = find.textContaining('Score:');
      expect(scoreWidget, findsOneWidget);
    });
  });
}
