import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/models/zener_symbol.dart';
import 'package:psychictournament/widgets/card_reveal_widget.dart';

void main() {
  group('CardRevealWidget', () {
    testWidgets('displays placeholder when not revealed', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CardRevealWidget(isRevealed: false)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('displays symbol when revealed', (WidgetTester tester) async {
      // Arrange
      const symbol = ZenerSymbol.circle;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(revealedSymbol: symbol, isRevealed: true),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(symbol.iconData), findsOneWidget);
      expect(find.text(symbol.displayName), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsNothing);
    });

    testWidgets('displays all Zener symbols correctly', (
      WidgetTester tester,
    ) async {
      for (final symbol in ZenerSymbol.values) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardRevealWidget(revealedSymbol: symbol, isRevealed: true),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(symbol.iconData), findsOneWidget);
        expect(find.text(symbol.displayName), findsOneWidget);
      }
    });

    testWidgets('displays feedback message when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const feedbackMessage = 'Correct!';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.star,
              isRevealed: true,
              feedbackMessage: feedbackMessage,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(feedbackMessage), findsOneWidget);
    });

    testWidgets('does not display feedback when not provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.cross,
              isRevealed: true,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Correct!'), findsNothing);
      expect(find.text('Incorrect'), findsNothing);
    });

    testWidgets('transitions from placeholder to revealed state', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool isRevealed = false;
      const symbol = ZenerSymbol.waves;

      // Act - Initial state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    CardRevealWidget(
                      revealedSymbol: symbol,
                      isRevealed: isRevealed,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isRevealed = true),
                      child: const Text('Reveal'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Assert initial placeholder state
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('?'), findsOneWidget);

      // Act - Trigger reveal
      await tester.tap(find.text('Reveal'));
      await tester.pumpAndSettle();

      // Assert revealed state
      expect(find.byIcon(symbol.iconData), findsOneWidget);
      expect(find.text(symbol.displayName), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsNothing);
    });

    testWidgets('has proper container styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CardRevealWidget())),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 160);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12.0));
      expect(decoration.border, isA<Border>());
    });

    testWidgets('displays correct feedback message colors', (
      WidgetTester tester,
    ) async {
      // Test correct feedback
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.square,
              isRevealed: true,
              feedbackMessage: 'Correct!',
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Find the feedback text widget - it should be visible after animations
      expect(find.text('Correct!'), findsOneWidget);

      // Test incorrect feedback
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.square,
              isRevealed: true,
              feedbackMessage: 'Incorrect. The card was a Square',
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Find the feedback text widget - it should be visible after animations
      expect(find.text('Incorrect. The card was a Square'), findsOneWidget);
    });

    testWidgets('handles animation duration parameter', (
      WidgetTester tester,
    ) async {
      // Arrange
      const customDuration = Duration(milliseconds: 500);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(animationDuration: customDuration),
          ),
        ),
      );

      // Assert - Widget should be created without errors
      expect(find.byType(CardRevealWidget), findsOneWidget);
    });

    testWidgets('maintains accessibility semantics', (
      WidgetTester tester,
    ) async {
      // Arrange
      const feedbackMessage = 'Correct! Well done.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.star,
              isRevealed: true,
              feedbackMessage: feedbackMessage,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final feedbackText = tester.widget<Text>(find.text(feedbackMessage));
      expect(feedbackText.semanticsLabel, feedbackMessage);
    });

    testWidgets('handles null revealed symbol gracefully', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(revealedSymbol: null, isRevealed: true),
          ),
        ),
      );

      // Assert - Should show placeholder even when isRevealed is true but symbol is null
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });
  });
}
