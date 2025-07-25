import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/widgets/final_score_dialog.dart';

void main() {
  group('FinalScoreDialog', () {
    testWidgets('should display correct score message', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool playAgainCalled = false;
      const int testScore = 15;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalScoreDialog(
              score: testScore,
              onPlayAgain: () {
                playAgainCalled = true;
              },
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Game Complete!'), findsOneWidget);
      expect(find.text('You scored 15 out of 25'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
      expect(playAgainCalled, isFalse);
    });

    testWidgets('should call onPlayAgain when Play Again button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool playAgainCalled = false;
      const int testScore = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinalScoreDialog(
              score: testScore,
              onPlayAgain: () {
                playAgainCalled = true;
              },
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Act - Tap the button widget instead of just the text
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(playAgainCalled, isTrue);
    });

    group('Score descriptions', () {
      testWidgets('should show exceptional message for score >= 20', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 22, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Exceptional psychic ability!'), findsOneWidget);
      });

      testWidgets('should show strong potential message for score >= 15', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 17, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Strong psychic potential!'), findsOneWidget);
      });

      testWidgets('should show good awareness message for score >= 10', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 12, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Good psychic awareness!'), findsOneWidget);
      });

      testWidgets('should show some sensitivity message for score >= 5', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 7, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Some psychic sensitivity detected.'), findsOneWidget);
      });

      testWidgets('should show practice message for score < 5', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 3, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Keep practicing your psychic abilities!'),
          findsOneWidget,
        );
      });
    });

    group('Icon display', () {
      testWidgets('should show star icon for high scores (>= 13)', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 15, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        final starIcon = find.byIcon(Icons.star);
        expect(starIcon, findsOneWidget);

        final iconWidget = tester.widget<Icon>(starIcon);
        expect(
          iconWidget.color,
          equals(Colors.white),
        ); // Icon is white, background is amber
        expect(iconWidget.size, equals(48));
      });

      testWidgets('should show psychology icon for lower scores (< 13)', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: 8, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        final psychologyIcon = find.byIcon(Icons.psychology);
        expect(psychologyIcon, findsOneWidget);

        final iconWidget = tester.widget<Icon>(psychologyIcon);
        expect(
          iconWidget.color,
          equals(Colors.white),
        ); // Icon is white, background is blue
        expect(iconWidget.size, equals(48));
      });
    });

    testWidgets('should have proper button styling', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FinalScoreDialog(score: 10, onPlayAgain: () {})),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(
        button.style?.padding?.resolve({}),
        equals(
          const EdgeInsets.symmetric(vertical: 16),
        ), // Updated to match implementation
      );
    });

    testWidgets('should display score with correct format', (
      WidgetTester tester,
    ) async {
      // Test various score values
      final testCases = [0, 5, 13, 20, 25];

      for (final score in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FinalScoreDialog(score: score, onPlayAgain: () {}),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        expect(find.text('You scored $score out of 25'), findsOneWidget);

        // Clean up for next iteration - wait for all timers to complete
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should have proper text styling', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FinalScoreDialog(score: 12, onPlayAgain: () {})),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert title is present
      final titleFinder = find.text('Game Complete!');
      expect(titleFinder, findsOneWidget);

      // Assert score text styling
      final scoreFinder = find.text('You scored 12 out of 25');
      expect(scoreFinder, findsOneWidget);
      final scoreWidget = tester.widget<Text>(scoreFinder);
      expect(scoreWidget.style?.fontSize, equals(20));
      expect(scoreWidget.style?.fontWeight, equals(FontWeight.w600));
      expect(scoreWidget.textAlign, equals(TextAlign.center));

      // Assert button is present and functional
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Assert button text is present
      final buttonTextFinder = find.descendant(
        of: buttonFinder,
        matching: find.text('Play Again'),
      );
      expect(buttonTextFinder, findsOneWidget);
    });
  });
}
