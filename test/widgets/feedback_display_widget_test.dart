import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/widgets/feedback_display_widget.dart';

void main() {
  group('FeedbackDisplayWidget', () {
    testWidgets('displays nothing when no feedback message provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeedbackDisplayWidget())),
      );

      // Assert
      expect(find.byType(FeedbackDisplayWidget), findsOneWidget);
      expect(find.text('Correct!'), findsNothing);
      expect(find.text('Incorrect'), findsNothing);
    });

    testWidgets('displays correct feedback message', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Correct!',
              isCorrect: true,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert
      expect(find.text('Correct!'), findsOneWidget);
    });

    testWidgets('displays incorrect feedback message', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Incorrect. The card was a Star',
              isCorrect: false,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert
      expect(find.text('Incorrect. The card was a Star'), findsOneWidget);
    });

    testWidgets('calls onFeedbackComplete after display duration', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool callbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Correct!',
              isCorrect: true,
              displayDuration: const Duration(milliseconds: 100),
              onFeedbackComplete: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert feedback is visible
      expect(find.text('Correct!'), findsOneWidget);
      expect(callbackCalled, isFalse);

      // Wait for display duration to complete
      await tester.pump(const Duration(milliseconds: 100));

      // Assert callback was called
      expect(callbackCalled, isTrue);
    });

    testWidgets('updates feedback when message changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      String? currentMessage = 'Correct!';
      bool isCorrect = true;

      // Act - Initial state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    FeedbackDisplayWidget(
                      feedbackMessage: currentMessage,
                      isCorrect: isCorrect,
                      displayDuration: const Duration(milliseconds: 200),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = 'Incorrect. The card was a Star';
                          isCorrect = false;
                        });
                      },
                      child: const Text('Change Message'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Wait for initial display
      await tester.pump();

      // Assert initial state
      expect(find.text('Correct!'), findsOneWidget);

      // Act - Change message
      await tester.tap(find.text('Change Message'));
      await tester.pump();

      // Assert updated state
      expect(find.text('Incorrect. The card was a Star'), findsOneWidget);
    });

    testWidgets('handles custom display duration', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Incorrect. The card was a Cross',
              isCorrect: false,
              displayDuration: const Duration(milliseconds: 50),
              onFeedbackComplete: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert feedback is visible
      expect(find.text('Incorrect. The card was a Cross'), findsOneWidget);
      expect(callbackCalled, isFalse);

      // Wait for custom duration to complete
      await tester.pump(const Duration(milliseconds: 50));

      // Assert callback was called after custom duration
      expect(callbackCalled, isTrue);
    });

    testWidgets('displays correct styling for correct feedback', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Correct!',
              isCorrect: true,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert
      expect(find.text('Correct!'), findsOneWidget);

      // Find the container with feedback styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FeedbackDisplayWidget),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green.shade50);
    });

    testWidgets('displays correct styling for incorrect feedback', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Incorrect. The card was a Waves',
              isCorrect: false,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert
      expect(find.text('Incorrect. The card was a Waves'), findsOneWidget);

      // Find the container with feedback styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FeedbackDisplayWidget),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
    });

    testWidgets('maintains accessibility semantics', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackDisplayWidget(
              feedbackMessage: 'Correct!',
              isCorrect: true,
            ),
          ),
        ),
      );

      // Wait for the widget to show
      await tester.pump();

      // Assert
      final feedbackText = tester.widget<Text>(find.text('Correct!'));
      expect(feedbackText.semanticsLabel, 'Correct!');
    });

    testWidgets('clears feedback when message becomes null', (
      WidgetTester tester,
    ) async {
      // Arrange
      String? currentMessage = 'Correct!';

      // Act - Initial state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    FeedbackDisplayWidget(
                      feedbackMessage: currentMessage,
                      isCorrect: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = null;
                        });
                      },
                      child: const Text('Clear Feedback'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Wait for initial display
      await tester.pump();

      // Assert initial state
      expect(find.text('Correct!'), findsOneWidget);

      // Act - Clear feedback
      await tester.tap(find.text('Clear Feedback'));
      await tester.pump();

      // Assert feedback is cleared
      expect(find.text('Correct!'), findsNothing);
    });

    testWidgets('handles rapid message changes gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      String? currentMessage;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    FeedbackDisplayWidget(
                      feedbackMessage: currentMessage,
                      isCorrect: true,
                      displayDuration: const Duration(milliseconds: 50),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = 'Correct!';
                        });
                      },
                      child: const Text('Show Feedback'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = null;
                        });
                      },
                      child: const Text('Hide Feedback'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Rapid state changes
      await tester.tap(find.text('Show Feedback'));
      await tester.pump();
      await tester.tap(find.text('Hide Feedback'));
      await tester.pump();
      await tester.tap(find.text('Show Feedback'));
      await tester.pump();

      // Assert - Should handle rapid changes without errors
      expect(find.byType(FeedbackDisplayWidget), findsOneWidget);
    });

    testWidgets('timer cancellation works correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      int callbackCount = 0;
      String currentMessage = 'First message';

      // Act - Initial state
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    FeedbackDisplayWidget(
                      feedbackMessage: currentMessage,
                      isCorrect: true,
                      displayDuration: const Duration(milliseconds: 200),
                      onFeedbackComplete: () => callbackCount++,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = 'Second message';
                        });
                      },
                      child: const Text('Change Message'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Wait for initial display
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Act - Change message before timer completes
      await tester.tap(find.text('Change Message'));
      await tester.pump();

      // Wait for new timer to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Assert - Only one callback should be called (from the second timer)
      expect(callbackCount, equals(1));
    });
  });
}
