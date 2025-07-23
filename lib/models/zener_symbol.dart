import 'package:flutter/material.dart';

/// Enum representing the five Zener card symbols used in psychic testing
enum ZenerSymbol { circle, cross, waves, square, star }

/// Extension methods for ZenerSymbol enum to provide display names and icons
extension ZenerSymbolExtension on ZenerSymbol {
  /// Returns the human-readable display name for the symbol
  String get displayName {
    switch (this) {
      case ZenerSymbol.circle:
        return 'Circle';
      case ZenerSymbol.cross:
        return 'Cross';
      case ZenerSymbol.waves:
        return 'Waves';
      case ZenerSymbol.square:
        return 'Square';
      case ZenerSymbol.star:
        return 'Star';
    }
  }

  /// Returns the Material Design icon for the symbol
  /// Used as placeholder until custom assets are added
  IconData get iconData {
    switch (this) {
      case ZenerSymbol.circle:
        return Icons.circle_outlined;
      case ZenerSymbol.cross:
        return Icons.add;
      case ZenerSymbol.waves:
        return Icons.waves;
      case ZenerSymbol.square:
        return Icons.crop_square;
      case ZenerSymbol.star:
        return Icons.star_outline;
    }
  }

  /// Returns the asset path for the symbol image
  /// Will be used when custom assets are added
  String get assetPath {
    switch (this) {
      case ZenerSymbol.circle:
        return 'assets/images/symbols/circle.svg';
      case ZenerSymbol.cross:
        return 'assets/images/symbols/cross.svg';
      case ZenerSymbol.waves:
        return 'assets/images/symbols/waves.svg';
      case ZenerSymbol.square:
        return 'assets/images/symbols/square.svg';
      case ZenerSymbol.star:
        return 'assets/images/symbols/star.svg';
    }
  }
}
