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

    testWidgets('displays symbol name when revealed', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.star,
              isRevealed: true,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(ZenerSymbol.star.displayName), findsOneWidget);
    });

    testWidgets('displays symbol name when revealed', (
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
      expect(find.text(ZenerSymbol.cross.displayName), findsOneWidget);
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
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12.0));
      expect(decoration.border, isA<Border>());

      // Check that the widget has the expected size by checking the render box
      final renderBox = tester.renderObject(find.byType(CardRevealWidget));
      expect(renderBox.paintBounds.width, 240);
      expect(renderBox.paintBounds.height, 320);
    });

    testWidgets('displays symbol with correct styling', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.square,
              isRevealed: true,
            ),
          ),
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // Assert symbol name is displayed
      expect(find.text(ZenerSymbol.square.displayName), findsOneWidget);

      // Assert symbol icon is displayed
      expect(find.byIcon(ZenerSymbol.square.iconData), findsOneWidget);
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
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardRevealWidget(
              revealedSymbol: ZenerSymbol.star,
              isRevealed: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert that symbol name text is accessible
      expect(find.text(ZenerSymbol.star.displayName), findsOneWidget);

      // Assert that icon is accessible
      expect(find.byIcon(ZenerSymbol.star.iconData), findsOneWidget);
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
