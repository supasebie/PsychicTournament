import 'dart:math' as dm;
import 'package:flutter/material.dart';

/// Purple glow shimmer specialized for symbols: uses a purple gradient sweep
/// and additive blend so the symbol appears to glow rather than wash out.
class PurpleGlowShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration period;
  final double angle; // in radians
  final double highlightWidth; // fraction of child width, 0-1
  // Portion of the cycle spent idle (no sweep). 0.0..0.9 recommended.
  final double idleFraction;

  const PurpleGlowShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    // Much slower default period for a more relaxed, infrequent sweep
    this.period = const Duration(milliseconds: 13000),
    this.angle = 0.6,
    this.highlightWidth = 0.28,
    this.idleFraction = 0.8,
  });

  @override
  State<PurpleGlowShimmer> createState() => _PurpleGlowShimmerState();
}

class _PurpleGlowShimmerState extends State<PurpleGlowShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant PurpleGlowShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (_controller.isAnimating) {
        _controller
          ..reset()
          ..repeat();
      }
    }
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        if (!_controller.isAnimating) {
          _controller
            ..reset()
            ..repeat();
        }
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    // We use srcATop to color only non-transparent parts of child (the SVG strokes/fills).
    // Additionally, we overlay a faint outer glow via a Stack with a blurred purple behind.
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow behind the symbol for a soft purple aura
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tRaw = _controller.value;
              final t = _withIdle(tRaw, widget.idleFraction);
              // Pulse the glow slightly for life
              final glowStrength = 0.25 + 0.15 * _easeInOutSine(t);
              return IgnorePointer(
                child: Transform.scale(
                  scale: 1.05 + 0.02 * _easeInOutSine((t + 0.25) % 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // Purple gradient radial glow
                      gradient: RadialGradient(
                        colors: [
                          _purple(context).withValues(alpha: glowStrength),
                          _purple(context).withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
          // Foreground moving purple gradient that tints the symbol
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (Rect bounds) {
                  final width = bounds.width;
                  final height = bounds.height;

                  final tRaw = _controller.value; // 0..1
                  final t = _easeInOutSine(
                    _withIdle(tRaw, widget.idleFraction),
                  );
                  final dx = width * (t * 2 - 1); // -w .. +w sweep

                  final angle = widget.angle;
                  final cosA = MathCos._(angle);
                  final sinA = MathSin._(angle);

                  final highlightW =
                      (widget.highlightWidth.clamp(0.08, 0.6)) * width;

                  // Purple tones for shimmer band
                  final c1 = _purple(context).withValues(alpha: 0.10);
                  final c2 = _purpleBright(context).withValues(alpha: 0.65);
                  final c3 = _purple(context).withValues(alpha: 0.10);

                  // Direction vector for gradient
                  final vx = cosA;
                  final vy = sinA;

                  final centerX = bounds.center.dx + dx * vx;
                  final centerY = bounds.center.dy + dx * vy;

                  final start = Offset(
                    centerX - vx * (width + highlightW),
                    centerY - vy * (height + highlightW),
                  );
                  final end = Offset(
                    centerX + vx * (width + highlightW),
                    centerY + vy * (height + highlightW),
                  );

                  // Three-stop purple band for bright center sweep
                  return LinearGradient(
                    colors: [c1, c2, c3],
                    stops: const [0.4, 0.5, 0.6],
                  ).createShader(Rect.fromPoints(start, end));
                },
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }

  // Theming helpers for purple shades
  Color _purple(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Prefer secondary (often purple in many themes); fallback to a fixed purple
    return scheme.secondary;
  }

  Color _purpleBright(BuildContext context) {
    // Brighter accent purple for the highlight
    return const Color(0xFFB388FF); // Light purple accent
  }

  // Easing util
  double _easeInOutSine(double t) => -0.5 * (dm.cos(dm.pi * t) - 1.0);
}

class Shimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration period;
  final double angle; // in radians
  final double highlightWidth; // fraction of child width, 0-1
  final double baseOpacity;
  final double highlightOpacity;
  // Portion of the cycle spent idle (no sweep). 0.0..0.9 recommended.
  final double idleFraction;

  const Shimmer({
    super.key,
    required this.child,
    this.enabled = true,
    // Much slower default period for a more relaxed, infrequent sweep
    this.period = const Duration(milliseconds: 12000),
    this.angle = 0.6, // slight diagonal
    this.highlightWidth = 0.25,
    this.baseOpacity = 0.15,
    this.highlightOpacity = 0.65,
    this.idleFraction = 0.8,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (_controller.isAnimating) {
        _controller
          ..reset()
          ..repeat();
      }
    }
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        if (!_controller.isAnimating) {
          _controller
            ..reset()
            ..repeat();
        }
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              final width = bounds.width;

              // Compute translation along the orthogonal axis to sweep across
              final tRaw = _controller.value; // 0..1
              final t = _easeInOutSine(_withIdle(tRaw, widget.idleFraction));
              final dx = width * (t * 2 - 1); // -w .. +w sweep

              final angle = widget.angle;
              final cosA = MathCos._(angle);
              final sinA = MathSin._(angle);

              // Build a gradient line that moves across the child
              final highlightW =
                  (widget.highlightWidth.clamp(0.05, 0.6)) * width;

              // Base/Highlight colors using onSurface with adjustable opacities
              final scheme = Theme.of(context).colorScheme;
              final base = scheme.onSurface.withValues(
                alpha: widget.baseOpacity,
              );
              final highlight = scheme.onSurface.withValues(
                alpha: widget.highlightOpacity,
              );

              // Gradient direction vector
              final vx = cosA;
              final vy = sinA;

              // Start/end points across the rect, translated by dx
              final centerX = bounds.center.dx + dx * vx;
              final centerY = bounds.center.dy + dx * vy;

              final start = Offset(
                centerX - vx * (width + highlightW),
                centerY - vy * (width + highlightW),
              );

              final end = Offset(
                centerX + vx * (width + highlightW),
                centerY + vy * (width + highlightW),
              );

              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [base, base, highlight, base, base],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                // Create shader with custom start/end via transform on rect
              ).createShader(Rect.fromPoints(start, end));
            },
            child: widget.child,
          );
        },
      ),
    );
  }
}

// Easing util available to all shimmer types
double _easeInOutSine(double t) => -0.5 * (dm.cos(dm.pi * t) - 1.0);

// Map controller progress into a value with an idle region at both ends.
// idleFraction indicates how much of the full cycle time is spent idle across both ends.
// For example, idleFraction 0.6 means 30% idle at start and 30% idle at end, 40% active.
// Returns 0..1 progression only during the active middle window.
double _withIdle(double t, double idleFraction) {
  final f = idleFraction.clamp(0.0, 0.9);
  final edge = f / 2.0;
  if (t <= edge) return 0.0;
  if (t >= 1.0 - edge) return 1.0;
  final u = (t - edge) / (1.0 - f); // normalize to 0..1
  return u;
}

/// Avoid importing dart:math publicly; tiny wrappers reduce import churn here.
class MathCos {
  static double _(double r) => dm.cos(r);
}

class MathSin {
  static double _(double r) => dm.sin(r);
}
