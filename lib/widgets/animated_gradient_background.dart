import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/gradients.dart';
import '../theme/motion.dart';

/// Fullscreen animated gradient background with subtle parallax glow.
/// Wrap your screens' Scaffold body with this for the modern ambience.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final bool useAlternate;
  final Duration? duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.useAlternate = false,
    this.duration,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppMotion.xlong,
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _controller, curve: AppMotion.standard);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = widget.useAlternate
        ? AppGradients.aurora
        : AppGradients.cosmic;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        // Use a vertical multi-stop gradient with very subtle color morphing to avoid top-edge jitter.
        // Keep direction fixed and animate a mild hue/brightness shift on middle stops.
        final double k = (_t.value - 0.5); // -0.5..0.5
        // Clamp small modulation to keep it tasteful
        final double o1 = (0.95 + k * 0.04).clamp(0.88, 0.98);
        final double o2 = (0.90 + k * 0.04).clamp(0.84, 0.95);

        // Slightly tint the mid colors toward scheme.secondary to enrich motion without shifting position
        final Color mid1 = Color.lerp(
          base[1],
          scheme.secondary,
          0.06 + k * 0.06,
        )!.withValues(alpha: o1.toDouble());
        final Color mid2 = Color.lerp(
          base[2],
          scheme.primary,
          0.06 - k * 0.06,
        )!.withValues(alpha: o2.toDouble());

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Fixed stops eliminate perceived bouncing near the top edge.
              stops: const [0.0, 0.42, 0.72, 1.0],
              colors: [base[0], mid1, mid2, base[3]],
            ),
          ),
          child: Stack(
            children: [
              // Soft neon radial glows that drift slightly, slowed down to reduce visual noise at the top.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _NeonGlowPainter(
                      color: scheme.primary,
                      t: _t.value * 0.6, // slow the drift
                    ),
                  ),
                ),
              ),
              // Content
              Positioned.fill(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

class _NeonGlowPainter extends CustomPainter {
  final Color color;
  final double t;

  _NeonGlowPainter({required this.color, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Keep glows away from the very top to prevent perceptual "shifting" at the status bar area.
    final double slowT = t;
    final center1 = Offset(
      size.width * (0.25 + 0.08 * math.sin(slowT * 2 * math.pi)),
      size.height * 0.38,
    );
    final center2 = Offset(
      size.width * (0.75 + 0.08 * math.cos(slowT * 2 * math.pi)),
      size.height * 0.82,
    );

    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: center1, radius: size.shortestSide * 0.56),
          );

    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: center2, radius: size.shortestSide * 0.66),
          );

    canvas.drawCircle(center1, size.shortestSide * 0.56, paint1);
    canvas.drawCircle(center2, size.shortestSide * 0.66, paint2);
  }

  @override
  bool shouldRepaint(covariant _NeonGlowPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
