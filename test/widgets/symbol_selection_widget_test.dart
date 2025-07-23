import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/models/zener_symbol.dart';
import 'package:psychictournament/widgets/symbol_selection_widget.dart';

void main() {
  group('SymbolSelectionWidget', () {
    testWidgets('displays all five Zener symbols', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(onSymbolSelected: (symbol) {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Select a symbol:'), findsOneWidget);

      // Check that all five symbols are displayed
      for (final symbol in ZenerSymbol.values) {
        expect(find.text(symbol.displayName), findsOneWidget);
        expect(find.byIcon(symbol.iconData), findsOneWidget);
      }
    });

    testWidgets('calls onSymbolSelected when button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      ZenerSymbol? selectedSymbol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(
              onSymbolSelected: (symbol) => selectedSymbol = symbol,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Circle'));
      await tester.pump();

      // Assert
      expect(selectedSymbol, equals(ZenerSymbol.circle));
    });

    testWidgets('buttons are enabled when buttonsEnabled is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(
              onSymbolSelected: (symbol) {},
              buttonsEnabled: true,
            ),
          ),
        ),
      );

      // Assert
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final button in buttons) {
        expect(button.onPressed, isNotNull);
      }
    });

    testWidgets('buttons are disabled when buttonsEnabled is false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(
              onSymbolSelected: (symbol) {},
              buttonsEnabled: false,
            ),
          ),
        ),
      );

      // Assert
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('does not call onSymbolSelected when buttons are disabled', (
      WidgetTester tester,
    ) async {
      // Arrange
      ZenerSymbol? selectedSymbol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(
              onSymbolSelected: (symbol) => selectedSymbol = symbol,
              buttonsEnabled: false,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Circle'));
      await tester.pump();

      // Assert
      expect(selectedSymbol, isNull);
    });

    testWidgets('has proper semantic labels for accessibility', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(onSymbolSelected: (symbol) {}),
          ),
        ),
      );

      // Assert
      for (final symbol in ZenerSymbol.values) {
        // Find the Semantics widget that has both the label and button properties
        final semanticsWidgets = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == symbol.displayName &&
              widget.properties.button == true,
        );
        expect(semanticsWidgets, findsOneWidget);
      }
    });

    testWidgets('buttons have correct size and styling', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(onSymbolSelected: (symbol) {}),
          ),
        ),
      );

      // Assert
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(SymbolSelectionWidget),
          matching: find.byType(SizedBox),
        ),
      );

      // Find the SizedBoxes that wrap the buttons (80x80)
      final buttonSizedBoxes = sizedBoxes.where(
        (box) => box.width == 80 && box.height == 80,
      );

      expect(buttonSizedBoxes.length, equals(5));
    });

    testWidgets('displays icons with correct size', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolSelectionWidget(onSymbolSelected: (symbol) {}),
          ),
        ),
      );

      // Assert
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        expect(icon.size, equals(32));
      }
    });
  });
}
