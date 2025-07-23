import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/controllers/game_controller.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
    });

    group('Initialization', () {
      test('should initialize with valid game state', () {
        final gameState = controller.gameState;

        expect(gameState.deck.length, equals(25));
        expect(gameState.currentTurn, equals(1));
        expect(gameState.score, equals(0));
        expect(gameState.isComplete, isFalse);
        expect(gameState.remoteViewingCoordinates, isNotEmpty);
      });

      test('should have remote viewing coordinates in correct format', () {
        final coordinates = controller.getRemoteViewingCoordinates();

        expect(coordinates.length, equals(9)); // XXXX-XXXX format
        expect(coordinates[4], equals('-'));
        expect(
          RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(coordinates),
          isTrue,
        );
      });
    });

    group('Deck Creation', () {
      test('should create deck with exactly 25 cards', () {
        final deck = GameController.createShuffledDeck();

        expect(deck.length, equals(25));
      });

      test('should create deck with 5 of each symbol', () {
        final deck = GameController.createShuffledDeck();

        for (final symbol in ZenerSymbol.values) {
          final count = deck.where((card) => card == symbol).length;
          expect(
            count,
            equals(5),
            reason: 'Should have 5 ${symbol.displayName} cards',
          );
        }
      });

      test('should create different shuffled decks', () {
        final deck1 = GameController.createShuffledDeck();
        final deck2 = GameController.createShuffledDeck();

        // While theoretically possible to be the same, it's extremely unlikely
        expect(deck1, isNot(equals(deck2)));
      });
    });

    group('Remote Viewing Coordinates', () {
      test('should generate coordinates in XXXX-XXXX format', () {
        final coordinates = GameController.generateRemoteViewingCoordinates();

        expect(coordinates.length, equals(9));
        expect(coordinates[4], equals('-'));
        expect(
          RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(coordinates),
          isTrue,
        );
      });

      test('should generate different coordinates each time', () {
        final coords1 = GameController.generateRemoteViewingCoordinates();
        final coords2 = GameController.generateRemoteViewingCoordinates();

        expect(coords1, isNot(equals(coords2)));
      });

      test('should only contain valid characters', () {
        final coordinates = GameController.generateRemoteViewingCoordinates();
        final validChars = RegExp(r'^[A-Z0-9-]+$');

        expect(validChars.hasMatch(coordinates), isTrue);
      });
    });

    group('Guess Processing', () {
      test('should process correct guess correctly', () {
        final correctSymbol = controller.getCurrentCorrectSymbol();
        final initialScore = controller.getCurrentScore();
        final initialTurn = controller.getCurrentTurn();

        final result = controller.makeGuess(correctSymbol);

        expect(result.isCorrect, isTrue);
        expect(result.correctSymbol, equals(correctSymbol));
        expect(result.userGuess, equals(correctSymbol));
        expect(result.newScore, equals(initialScore + 1));
        expect(controller.getCurrentScore(), equals(initialScore + 1));
        expect(controller.getCurrentTurn(), equals(initialTurn + 1));
      });

      test('should process incorrect guess correctly', () {
        final correctSymbol = controller.getCurrentCorrectSymbol();
        final initialScore = controller.getCurrentScore();
        final initialTurn = controller.getCurrentTurn();

        // Find a different symbol to guess
        final wrongSymbol = ZenerSymbol.values.firstWhere(
          (symbol) => symbol != correctSymbol,
        );

        final result = controller.makeGuess(wrongSymbol);

        expect(result.isCorrect, isFalse);
        expect(result.correctSymbol, equals(correctSymbol));
        expect(result.userGuess, equals(wrongSymbol));
        expect(result.newScore, equals(initialScore));
        expect(controller.getCurrentScore(), equals(initialScore));
        expect(controller.getCurrentTurn(), equals(initialTurn + 1));
      });

      test('should advance turn after each guess', () {
        final initialTurn = controller.getCurrentTurn();

        controller.makeGuess(ZenerSymbol.circle);

        expect(controller.getCurrentTurn(), equals(initialTurn + 1));
      });

      test('should throw error when making guess on completed game', () {
        // Complete the game by making 25 guesses
        for (int i = 0; i < 25; i++) {
          controller.makeGuess(ZenerSymbol.circle);
        }

        expect(controller.isGameComplete(), isTrue);
        expect(
          () => controller.makeGuess(ZenerSymbol.circle),
          throwsStateError,
        );
      });
    });

    group('Game Completion', () {
      test('should detect game completion after 25 turns', () {
        expect(controller.isGameComplete(), isFalse);

        // Make 24 guesses
        for (int i = 0; i < 24; i++) {
          controller.makeGuess(ZenerSymbol.circle);
          expect(controller.isGameComplete(), isFalse);
        }

        // Make final guess
        controller.makeGuess(ZenerSymbol.circle);
        expect(controller.isGameComplete(), isTrue);
        expect(controller.getCurrentTurn(), equals(26));
      });

      test('should not have more turns when game is complete', () {
        // Complete the game
        for (int i = 0; i < 25; i++) {
          controller.makeGuess(ZenerSymbol.circle);
        }

        expect(controller.hasMoreTurns(), isFalse);
      });
    });

    group('Game Reset', () {
      test('should reset game state to initial values', () {
        // Make some progress in the game
        controller.makeGuess(
          controller.getCurrentCorrectSymbol(),
        ); // Correct guess
        controller.makeGuess(ZenerSymbol.circle); // Potentially incorrect

        final originalCoordinates = controller.getRemoteViewingCoordinates();

        controller.resetGame();

        expect(controller.getCurrentTurn(), equals(1));
        expect(controller.getCurrentScore(), equals(0));
        expect(controller.isGameComplete(), isFalse);
        expect(controller.hasMoreTurns(), isTrue);
        expect(controller.gameState.deck.length, equals(25));

        // Should have new coordinates
        expect(
          controller.getRemoteViewingCoordinates(),
          isNot(equals(originalCoordinates)),
        );
      });

      test('should create new shuffled deck on reset', () {
        final originalDeck = List<ZenerSymbol>.from(controller.gameState.deck);

        controller.resetGame();

        final newDeck = controller.gameState.deck;
        expect(newDeck.length, equals(25));
        // Decks should be different (extremely unlikely to be the same)
        expect(newDeck, isNot(equals(originalDeck)));
      });
    });

    group('Score Calculation', () {
      test('should increment score only on correct guesses', () {
        int expectedScore = 0;

        for (int i = 0; i < 5; i++) {
          final correctSymbol = controller.getCurrentCorrectSymbol();
          final result = controller.makeGuess(correctSymbol);

          expectedScore++;
          expect(result.newScore, equals(expectedScore));
          expect(controller.getCurrentScore(), equals(expectedScore));
        }
      });

      test('should not increment score on incorrect guesses', () {
        final initialScore = controller.getCurrentScore();
        final correctSymbol = controller.getCurrentCorrectSymbol();

        // Find a different symbol
        final wrongSymbol = ZenerSymbol.values.firstWhere(
          (symbol) => symbol != correctSymbol,
        );

        final result = controller.makeGuess(wrongSymbol);

        expect(result.newScore, equals(initialScore));
        expect(controller.getCurrentScore(), equals(initialScore));
      });
    });

    group('Current Symbol Access', () {
      test('should return correct symbol for current turn', () {
        final symbol = controller.getCurrentCorrectSymbol();

        expect(ZenerSymbol.values.contains(symbol), isTrue);
        expect(symbol, equals(controller.gameState.currentCard));
      });

      test('should return different symbols as turns progress', () {
        final symbols = <ZenerSymbol>[];

        // Collect symbols from first 5 turns
        for (int i = 0; i < 5; i++) {
          symbols.add(controller.getCurrentCorrectSymbol());
          controller.makeGuess(ZenerSymbol.circle);
        }

        // Should have collected 5 symbols
        expect(symbols.length, equals(5));

        // All should be valid Zener symbols
        for (final symbol in symbols) {
          expect(ZenerSymbol.values.contains(symbol), isTrue);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle rapid consecutive guesses', () {
        final initialTurn = controller.getCurrentTurn();

        // Make multiple guesses rapidly
        controller.makeGuess(ZenerSymbol.circle);
        controller.makeGuess(ZenerSymbol.cross);
        controller.makeGuess(ZenerSymbol.waves);

        expect(controller.getCurrentTurn(), equals(initialTurn + 3));
      });

      test('should maintain deck integrity throughout game', () {
        final originalDeck = List<ZenerSymbol>.from(controller.gameState.deck);

        // Make several guesses
        for (int i = 0; i < 10; i++) {
          controller.makeGuess(ZenerSymbol.star);
        }

        // Deck should remain unchanged
        expect(controller.gameState.deck, equals(originalDeck));
      });
    });
  });
}
