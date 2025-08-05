import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  /// Prefer Sora via google_fonts, but fall back to system fonts if offline or blocked.
  static TextTheme soraTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData(brightness: Brightness.dark).textTheme
        : ThemeData(brightness: Brightness.light).textTheme;

    // Start with base to ensure we always have a valid theme even if Google Fonts fails.
    TextTheme themed = base;

    try {
      // This will use cached/bundled fonts if available; if it tries to fetch and fails,
      // the catch below keeps us on base so no crash occurs.
      themed = GoogleFonts.soraTextTheme(base);
    } catch (_) {
      themed = base;
    }

    return themed.copyWith(
      displayLarge: themed.displayLarge?.copyWith(
        letterSpacing: 0.5,
        height: 1.1,
      ),
      displayMedium: themed.displayMedium?.copyWith(
        letterSpacing: 0.4,
        height: 1.1,
      ),
      displaySmall: themed.displaySmall?.copyWith(
        letterSpacing: 0.3,
        height: 1.15,
      ),
      headlineLarge: themed.headlineLarge?.copyWith(
        letterSpacing: 0.25,
        height: 1.15,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        letterSpacing: 0.2,
        height: 1.2,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        letterSpacing: 0.15,
        height: 1.2,
      ),
      titleLarge: themed.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: themed.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: themed.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      labelMedium: themed.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: themed.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.4),
      bodySmall: themed.bodySmall?.copyWith(height: 1.35),
    );
  }
}
