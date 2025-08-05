import 'package:flutter/material.dart';
import 'gradients.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  // Base dark ColorScheme with blue/purple neon accents
  static ColorScheme get _darkScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6B2DD9),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF2D1B69),
    onPrimaryContainer: Color(0xFFE7DBFF),
    secondary: Color(0xFF1256C4),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF0F2C62),
    onSecondaryContainer: Color(0xFFCFE3FF),
    tertiary: Color(0xFF00D4FF),
    onTertiary: Color(0xFF00131A),
    tertiaryContainer: Color(0xFF002B3B),
    onTertiaryContainer: Color(0xFFA2F2FF),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF3B0F0F),
    onErrorContainer: Color(0xFFFFD9D9),
    surface: Color(0xFF0E0B1F),
    onSurface: Color(0xFFE9E6FF),
    surfaceContainerLowest: Color(0xFF0B0A16),
    surfaceContainerLow: Color(0xFF110F23),
    surfaceContainer: Color(0xFF151331),
    surfaceContainerHigh: Color(0xFF1B1A3B),
    surfaceContainerHighest: Color(0xFF1F1E49),
    outline: Color(0xFF4D4A7D),
    outlineVariant: Color(0xFF2C2950),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE9E6FF),
    onInverseSurface: Color(0xFF12111D),
    inversePrimary: Color(0xFFD6C2FF),
  );

  static ThemeData dark() {
    final scheme = _darkScheme;
    final textTheme = AppTypography.soraTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return scheme.primaryContainer;
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(
              color: scheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            scheme.onSurface.withValues(alpha: 0.8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 24,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[
        _Backgrounds(
          primary: AppGradients.vertical(AppGradients.cosmic),
          alternate: AppGradients.vertical(AppGradients.aurora),
        ),
      ],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
    );
  }
}

// Theme extension for gradient backgrounds
class _Backgrounds extends ThemeExtension<_Backgrounds> {
  final Gradient primary;
  final Gradient alternate;

  const _Backgrounds({required this.primary, required this.alternate});

  @override
  _Backgrounds copyWith({Gradient? primary, Gradient? alternate}) {
    return _Backgrounds(
      primary: primary ?? this.primary,
      alternate: alternate ?? this.alternate,
    );
  }

  @override
  _Backgrounds lerp(ThemeExtension<_Backgrounds>? other, double t) {
    if (other is! _Backgrounds) return this;
    return _Backgrounds(
      primary: Gradient.lerp(primary, other.primary, t)!,
      alternate: Gradient.lerp(alternate, other.alternate, t)!,
    );
  }
}
