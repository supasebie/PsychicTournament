import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/widgets/score_display_widget.dart';

void main() {
  group('ScoreDisplayWidget', () {
    testWidgets('displays score in correct format', (
      WidgetTester tester,
    ) async {
      // Arrange
      const score = 15;
      const totalCards = 25;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreDisplayWidget(score: score, totalCards: totalCards),
          ),
        ),
      );

      // Assert
      expect(find.text('Score: 15 / 25'), findsOneWidget);
    });

    testWidgets('displays zero score correctly', (WidgetTester tester) async {
      // Arrange
      const score = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScoreDisplayWidget(score: score)),
        ),
      );

      // Assert
      expect(find.text('Score: 0 / 25'), findsOneWidget);
    });

    testWidgets('displays maximum score correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      const score = 25;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScoreDisplayWidget(score: score)),
        ),
      );

      // Assert
      expect(find.text('Score: 25 / 25'), findsOneWidget);
    });

    testWidgets('uses custom total cards when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const score = 10;
      const totalCards = 20;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreDisplayWidget(score: score, totalCards: totalCards),
          ),
        ),
      );

      // Assert
      expect(find.text('Score: 10 / 20'), findsOneWidget);
    });

    testWidgets('has proper styling and container', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ScoreDisplayWidget(score: 5))),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8.0));
    });

    testWidgets('has proper semantics for accessibility', (
      WidgetTester tester,
    ) async {
      // Arrange
      const score = 12;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScoreDisplayWidget(score: score)),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text('Score: 12 / 25'));
      expect(text.semanticsLabel, 'Current score: 12 out of 25');
    });

    testWidgets('updates when score changes', (WidgetTester tester) async {
      // Arrange
      int score = 5;

      // Act - Initial render
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ScoreDisplayWidget(score: score),
                    ElevatedButton(
                      onPressed: () => setState(() => score++),
                      child: const Text('Increment'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Assert initial state
      expect(find.text('Score: 5 / 25'), findsOneWidget);

      // Act - Update score
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Assert updated state
      expect(find.text('Score: 6 / 25'), findsOneWidget);
      expect(find.text('Score: 5 / 25'), findsNothing);
    });
  });
}
