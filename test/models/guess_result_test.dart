import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/models/guess_result.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('GuessResult', () {
    group('constructor', () {
      test('should create GuessResult with all required properties', () {
        final guessResult = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.circle,
          userGuess: ZenerSymbol.circle,
          newScore: 5,
        );

        expect(guessResult.isCorrect, equals(true));
        expect(guessResult.correctSymbol, equals(ZenerSymbol.circle));
        expect(guessResult.userGuess, equals(ZenerSymbol.circle));
        expect(guessResult.newScore, equals(5));
      });
    });

    group('feedbackMessage', () {
      test('should return "Correct!" for correct guesses', () {
        final correctGuess = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.star,
          userGuess: ZenerSymbol.star,
          newScore: 1,
        );

        expect(correctGuess.feedbackMessage, equals('Correct!'));
      });

      test('should return detailed message for incorrect guesses', () {
        final incorrectGuess = GuessResult(
          isCorrect: false,
          correctSymbol: ZenerSymbol.cross,
          userGuess: ZenerSymbol.circle,
          newScore: 2,
        );

        expect(
          incorrectGuess.feedbackMessage,
          equals('Incorrect. The card was a Cross'),
        );
      });

      test('should use correct symbol display name in incorrect message', () {
        final testCases = [
          (ZenerSymbol.circle, 'Circle'),
          (ZenerSymbol.cross, 'Cross'),
          (ZenerSymbol.waves, 'Waves'),
          (ZenerSymbol.square, 'Square'),
          (ZenerSymbol.star, 'Star'),
        ];

        for (final (symbol, displayName) in testCases) {
          final incorrectGuess = GuessResult(
            isCorrect: false,
            correctSymbol: symbol,
            userGuess: ZenerSymbol.circle,
            newScore: 0,
          );

          expect(
            incorrectGuess.feedbackMessage,
            equals('Incorrect. The card was a $displayName'),
          );
        }
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final guessResult1 = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.waves,
          userGuess: ZenerSymbol.waves,
          newScore: 10,
        );

        final guessResult2 = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.waves,
          userGuess: ZenerSymbol.waves,
          newScore: 10,
        );

        expect(guessResult1, equals(guessResult2));
        expect(guessResult1.hashCode, equals(guessResult2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final guessResult1 = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.square,
          userGuess: ZenerSymbol.square,
          newScore: 5,
        );

        final guessResult2 = GuessResult(
          isCorrect: false,
          correctSymbol: ZenerSymbol.square,
          userGuess: ZenerSymbol.circle,
          newScore: 5,
        );

        expect(guessResult1, isNot(equals(guessResult2)));
      });

      test('should not be equal when scores differ', () {
        final guessResult1 = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.star,
          userGuess: ZenerSymbol.star,
          newScore: 3,
        );

        final guessResult2 = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.star,
          userGuess: ZenerSymbol.star,
          newScore: 4,
        );

        expect(guessResult1, isNot(equals(guessResult2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final guessResult = GuessResult(
          isCorrect: false,
          correctSymbol: ZenerSymbol.cross,
          userGuess: ZenerSymbol.waves,
          newScore: 7,
        );

        final result = guessResult.toString();

        expect(result, contains('GuessResult'));
        expect(result, contains('correct: false'));
        expect(result, contains('correctSymbol: ZenerSymbol.cross'));
        expect(result, contains('userGuess: ZenerSymbol.waves'));
        expect(result, contains('newScore: 7'));
      });
    });

    group('edge cases', () {
      test('should handle score of 0', () {
        final guessResult = GuessResult(
          isCorrect: false,
          correctSymbol: ZenerSymbol.circle,
          userGuess: ZenerSymbol.star,
          newScore: 0,
        );

        expect(guessResult.newScore, equals(0));
        expect(
          guessResult.feedbackMessage,
          equals('Incorrect. The card was a Circle'),
        );
      });

      test('should handle maximum possible score', () {
        final guessResult = GuessResult(
          isCorrect: true,
          correctSymbol: ZenerSymbol.square,
          userGuess: ZenerSymbol.square,
          newScore: 25,
        );

        expect(guessResult.newScore, equals(25));
        expect(guessResult.feedbackMessage, equals('Correct!'));
      });
    });
  });
}
