/// Enum representing the five Zener card symbols used in psychic testing
enum ZenerSymbol { circle, cross, waves, square, star }

/// Extension methods for ZenerSymbol enum to provide display names and asset paths
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

  /// Returns the asset path for the SVG symbol image (new assets)
  String get assetPath {
    switch (this) {
      case ZenerSymbol.circle:
        return 'assets/zener/circle.svg';
      case ZenerSymbol.cross:
        return 'assets/zener/plus.svg';
      case ZenerSymbol.waves:
        return 'assets/zener/waves.svg';
      case ZenerSymbol.square:
        return 'assets/zener/square.svg';
      case ZenerSymbol.star:
        return 'assets/zener/star.svg';
    }
  }
}
