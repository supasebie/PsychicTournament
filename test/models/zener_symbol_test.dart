import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychictournament/models/zener_symbol.dart';

void main() {
  group('ZenerSymbol', () {
    test('should have exactly 5 symbols', () {
      expect(ZenerSymbol.values.length, equals(5));
    });

    test('should contain all expected symbols', () {
      expect(
        ZenerSymbol.values,
        containsAll([
          ZenerSymbol.circle,
          ZenerSymbol.cross,
          ZenerSymbol.waves,
          ZenerSymbol.square,
          ZenerSymbol.star,
        ]),
      );
    });
  });

  group('ZenerSymbolExtension', () {
    group('displayName', () {
      test('should return correct display names', () {
        expect(ZenerSymbol.circle.displayName, equals('Circle'));
        expect(ZenerSymbol.cross.displayName, equals('Cross'));
        expect(ZenerSymbol.waves.displayName, equals('Waves'));
        expect(ZenerSymbol.square.displayName, equals('Square'));
        expect(ZenerSymbol.star.displayName, equals('Star'));
      });

      test('should return unique display names for all symbols', () {
        final displayNames = ZenerSymbol.values
            .map((s) => s.displayName)
            .toSet();
        expect(displayNames.length, equals(ZenerSymbol.values.length));
      });
    });

    group('iconData', () {
      test('should return valid IconData for all symbols', () {
        for (final symbol in ZenerSymbol.values) {
          expect(symbol.iconData, isA<IconData>());
        }
      });

      test('should return correct icons', () {
        expect(ZenerSymbol.circle.iconData, equals(Icons.circle_outlined));
        expect(ZenerSymbol.cross.iconData, equals(Icons.add));
        expect(ZenerSymbol.waves.iconData, equals(Icons.waves));
        expect(ZenerSymbol.square.iconData, equals(Icons.crop_square));
        expect(ZenerSymbol.star.iconData, equals(Icons.star_outline));
      });
    });

    group('assetPath', () {
      test('should return correct asset paths', () {
        expect(
          ZenerSymbol.circle.assetPath,
          equals('assets/images/symbols/circle.svg'),
        );
        expect(
          ZenerSymbol.cross.assetPath,
          equals('assets/images/symbols/cross.svg'),
        );
        expect(
          ZenerSymbol.waves.assetPath,
          equals('assets/images/symbols/waves.svg'),
        );
        expect(
          ZenerSymbol.square.assetPath,
          equals('assets/images/symbols/square.svg'),
        );
        expect(
          ZenerSymbol.star.assetPath,
          equals('assets/images/symbols/star.svg'),
        );
      });

      test('should return unique asset paths for all symbols', () {
        final assetPaths = ZenerSymbol.values.map((s) => s.assetPath).toSet();
        expect(assetPaths.length, equals(ZenerSymbol.values.length));
      });

      test('should return paths with correct format', () {
        for (final symbol in ZenerSymbol.values) {
          expect(symbol.assetPath, startsWith('assets/images/symbols/'));
          expect(symbol.assetPath, endsWith('.svg'));
        }
      });
    });
  });
}
