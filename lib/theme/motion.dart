import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  // Durations
  static const Duration xshort = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration xlong = Duration(milliseconds: 800);

  // Curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
  static const Curve accelerate = Curves.fastOutSlowIn;
}
