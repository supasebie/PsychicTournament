import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/widgets/feedback_overlay_widget.dart';

void main() {
  group('FeedbackOverlay Widget Tests', () {
    testWidgets('should not render when not visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FeedbackOverlay(
                  isVisible: false,
                  message: 'Hit!',
                  isCorrect: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Hit!'), findsNothing);
    });

    testWidgets(
      'should render Hit! message with correct styling when visible and correct',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  FeedbackOverlay(
                    isVisible: true,
                    message: 'Hit!',
                    isCorrect: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Allow animation to start
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Hit!'), findsOneWidget);

        // Check text styling
        final textWidget = tester.widget<Text>(find.text('Hit!'));
        expect(textWidget.style?.fontSize, 48.0);
        expect(textWidget.style?.fontWeight, FontWeight.bold);
        expect(textWidget.style?.color, const Color(0xFF4CAF50));
      },
    );

    testWidgets(
      'should render Miss message with correct styling when visible and incorrect',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  FeedbackOverlay(
                    isVisible: true,
                    message: 'Miss',
                    isCorrect: false,
                  ),
                ],
              ),
            ),
          ),
        );

        // Allow animation to start
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Miss'), findsOneWidget);

        // Check text styling
        final textWidget = tester.widget<Text>(find.text('Miss'));
        expect(textWidget.style?.fontSize, 48.0);
        expect(textWidget.style?.fontWeight, FontWeight.bold);
        expect(textWidget.style?.color, const Color(0xFFF44336));
      },
    );

    testWidgets('should animate in when visibility changes to true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FeedbackOverlay(
                  isVisible: false,
                  message: 'Hit!',
                  isCorrect: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Hit!'), findsNothing);

      // Change visibility to true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FeedbackOverlay(
                  isVisible: true,
                  message: 'Hit!',
                  isCorrect: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Animation should start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hit!'), findsOneWidget);
    });

    testWidgets('should handle animation lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FeedbackOverlay(
                  isVisible: true,
                  message: 'Hit!',
                  isCorrect: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Allow animation to start and progress
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hit!'), findsOneWidget);

      // Change visibility to false
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FeedbackOverlay(
                  isVisible: false,
                  message: 'Hit!',
                  isCorrect: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Allow reverse animation to complete
      await tester.pumpAndSettle();

      // Widget should be hidden after animation completes
      expect(find.text('Hit!'), findsNothing);
    });

    testWidgets(
      'should position text towards top of screen for correct guess',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  FeedbackOverlay(
                    isVisible: true,
                    message: 'Hit!',
                    isCorrect: true,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Check that text is positioned using Positioned widget
        final positionedFinder = find.byType(Positioned);
        expect(positionedFinder, findsOneWidget);

        final positioned = tester.widget<Positioned>(positionedFinder);
        expect(positioned.top, greaterThan(100.0)); // Should be towards top
        expect(positioned.left, 0);
        expect(positioned.right, 0);
      },
    );

    testWidgets(
      'should position text towards top of screen for incorrect guess',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  FeedbackOverlay(
                    isVisible: true,
                    message: 'Miss',
                    isCorrect: false,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Check that text is positioned using Positioned widget
        final positionedFinder = find.byType(Positioned);
        expect(positionedFinder, findsOneWidget);

        final positioned = tester.widget<Positioned>(positionedFinder);
        expect(positioned.top, greaterThan(100.0)); // Should be towards top
        expect(positioned.left, 0);
        expect(positioned.right, 0);
      },
    );
  });
}
