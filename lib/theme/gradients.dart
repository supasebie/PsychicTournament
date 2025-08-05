import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  // Blue/Purple neon space gradients
  static const List<Color> cosmic = [
    Color(0xFF0D0C1D), // near-black indigo
    Color(0xFF1A1446), // deep indigo
    Color(0xFF2D1B69), // purple
    Color(0xFF3D1F8B), // electric violet
  ];

  static const List<Color> aurora = [
    Color(0xFF0E0B1F),
    Color(0xFF0E1236),
    Color(0xFF10295E),
    Color(0xFF1643A4),
  ];

  static const List<Color> neonBlue = [
    Color(0xFF0B1020),
    Color(0xFF0E1E3A),
    Color(0xFF0F2C62),
    Color(0xFF1256C4),
  ];

  static const List<Color> neonPurple = [
    Color(0xFF100B1F),
    Color(0xFF1E133F),
    Color(0xFF351A6D),
    Color(0xFF6B2DD9),
  ];

  static LinearGradient vertical(List<Color> colors) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );

  static Gradient radial(
    List<Color> colors, {
    Offset? center,
    double? radius,
  }) => RadialGradient(
    center: Alignment(center?.dx ?? 0.0, center?.dy ?? -0.2),
    radius: radius ?? 1.2,
    colors: colors,
  );

  static Gradient sweep(
    List<Color> colors, {
    double? startAngle,
    double? endAngle,
  }) => SweepGradient(
    startAngle: startAngle ?? 0,
    endAngle: endAngle ?? 3.14 * 2,
    colors: colors,
  );
}
