import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/models/game_state.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('GameState', () {
    late List<ZenerSymbol> testDeck;
    late GameState testGameState;

    setUp(() {
      testDeck = [
        ZenerSymbol.circle,
        ZenerSymbol.cross,
        ZenerSymbol.waves,
        ZenerSymbol.square,
        ZenerSymbol.star,
      ];
      testGameState = GameState(
        deck: testDeck,
        remoteViewingCoordinates: 'ABCD-1234',
      );
    });

    group('constructor', () {
      test('should create GameState with required parameters', () {
        final gameState = GameState(
          deck: testDeck,
          remoteViewingCoordinates: 'ABCD-1234',
        );

        expect(gameState.deck, equals(testDeck));
        expect(gameState.remoteViewingCoordinates, equals('ABCD-1234'));
        expect(gameState.currentTurn, equals(1));
        expect(gameState.score, equals(0));
        expect(gameState.isComplete, equals(false));
      });

      test('should create GameState with custom values', () {
        final gameState = GameState(
          deck: testDeck,
          remoteViewingCoordinates: 'WXYZ-9876',
          currentTurn: 10,
          score: 5,
          isComplete: true,
        );

        expect(gameState.currentTurn, equals(10));
        expect(gameState.score, equals(5));
        expect(gameState.isComplete, equals(true));
      });
    });

    group('copyWith', () {
      test(
        'should create copy with no changes when no parameters provided',
        () {
          final copy = testGameState.copyWith();

          expect(copy.deck, equals(testGameState.deck));
          expect(
            copy.remoteViewingCoordinates,
            equals(testGameState.remoteViewingCoordinates),
          );
          expect(copy.currentTurn, equals(testGameState.currentTurn));
          expect(copy.score, equals(testGameState.score));
          expect(copy.isComplete, equals(testGameState.isComplete));
        },
      );

      test('should create copy with updated currentTurn', () {
        final copy = testGameState.copyWith(currentTurn: 5);

        expect(copy.currentTurn, equals(5));
        expect(copy.deck, equals(testGameState.deck));
        expect(copy.score, equals(testGameState.score));
      });

      test('should create copy with updated score', () {
        final copy = testGameState.copyWith(score: 10);

        expect(copy.score, equals(10));
        expect(copy.currentTurn, equals(testGameState.currentTurn));
        expect(copy.deck, equals(testGameState.deck));
      });

      test('should create copy with updated isComplete', () {
        final copy = testGameState.copyWith(isComplete: true);

        expect(copy.isComplete, equals(true));
        expect(copy.currentTurn, equals(testGameState.currentTurn));
        expect(copy.score, equals(testGameState.score));
      });

      test('should create copy with multiple updated properties', () {
        final copy = testGameState.copyWith(
          currentTurn: 15,
          score: 8,
          isComplete: true,
        );

        expect(copy.currentTurn, equals(15));
        expect(copy.score, equals(8));
        expect(copy.isComplete, equals(true));
        expect(copy.deck, equals(testGameState.deck));
        expect(
          copy.remoteViewingCoordinates,
          equals(testGameState.remoteViewingCoordinates),
        );
      });
    });

    group('currentCard', () {
      test('should return correct card for current turn', () {
        expect(testGameState.currentCard, equals(ZenerSymbol.circle));

        final gameState2 = testGameState.copyWith(currentTurn: 3);
        expect(gameState2.currentCard, equals(ZenerSymbol.waves));
      });

      test('should throw StateError for invalid turn number', () {
        final invalidGameState = testGameState.copyWith(currentTurn: 0);
        expect(() => invalidGameState.currentCard, throwsStateError);

        final invalidGameState2 = testGameState.copyWith(currentTurn: 26);
        expect(() => invalidGameState2.currentCard, throwsStateError);
      });
    });

    group('hasMoreTurns', () {
      test('should return true when game is not complete and turn <= 25', () {
        expect(testGameState.hasMoreTurns, equals(true));

        final gameState2 = testGameState.copyWith(currentTurn: 25);
        expect(gameState2.hasMoreTurns, equals(true));
      });

      test('should return false when game is complete', () {
        final completedGameState = testGameState.copyWith(isComplete: true);
        expect(completedGameState.hasMoreTurns, equals(false));
      });

      test('should return false when turn > 25', () {
        final gameState = testGameState.copyWith(currentTurn: 26);
        expect(gameState.hasMoreTurns, equals(false));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final gameState1 = GameState(
          deck: testDeck,
          remoteViewingCoordinates: 'ABCD-1234',
          currentTurn: 5,
          score: 3,
          isComplete: false,
        );

        final gameState2 = GameState(
          deck: testDeck,
          remoteViewingCoordinates: 'ABCD-1234',
          currentTurn: 5,
          score: 3,
          isComplete: false,
        );

        expect(gameState1, equals(gameState2));
        expect(gameState1.hashCode, equals(gameState2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final gameState1 = testGameState;
        final gameState2 = testGameState.copyWith(score: 1);

        expect(gameState1, isNot(equals(gameState2)));
      });

      test('should not be equal when decks differ', () {
        final differentDeck = [ZenerSymbol.star, ZenerSymbol.circle];
        final gameState1 = testGameState;
        final gameState2 = GameState(
          deck: differentDeck,
          remoteViewingCoordinates: 'ABCD-1234',
        );

        expect(gameState1, isNot(equals(gameState2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final result = testGameState.toString();

        expect(result, contains('GameState'));
        expect(result, contains('deck: ${testDeck.length} cards'));
        expect(result, contains('coordinates: ABCD-1234'));
        expect(result, contains('turn: 1'));
        expect(result, contains('score: 0'));
        expect(result, contains('complete: false'));
      });
    });
  });
}
