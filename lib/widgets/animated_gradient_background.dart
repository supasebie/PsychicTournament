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
      // Slow default background motion substantially; caller can override via duration
      duration: widget.duration ?? const Duration(seconds: 30),
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

        final int timeMs = _controller.lastElapsedDuration?.inMilliseconds ?? 0;

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
                      t:
                          _t.value *
                          1.20, // doubled again (2x of the previous 0.60)
                    ),
                  ),
                ),
              ),
              // Subtle starfield twinkle for depth
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _StarfieldPainter(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        t: _t.value,
                        count: 384,
                      ),
                    ),
                  ),
                ),
              ),
              // Sparkle twinkle overlay for a subset of stars
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _TwinkleSparklePainter(
                        color: scheme.onSurface,
                        timeMs: timeMs,
                        count: 96,
                        seed: 2025,
                      ),
                    ),
                  ),
                ),
              ),
              // Occasional shooting star layer
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ShootingStarPainter(
                        color: scheme.onSurface,
                        timeMs: timeMs,
                        seed: 1337,
                      ),
                    ),
                  ),
                ),
              ),
              // Diagonal shimmer sweep overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ShimmerSweepPainter(
                        color: scheme.secondary,
                        t: _t.value,
                      ),
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

class _ShimmerSweepPainter extends CustomPainter {
  final Color color;
  final double t;

  _ShimmerSweepPainter({required this.color, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a diagonal sweep that moves across the screen.
    final double w = size.width;
    final double h = size.height;

    // Position progresses from -0.5 to 1.5 to ensure full pass off-screen.
    // Multiply time to slow the sweep frequency further if needed.
    final double p =
        (t) * 2.0 - 0.5; // -0.5..1.5 (full sweep per controller cycle)

    // Shimmer band thickness relative to diagonal length
    final double band = (math.sqrt(w * w + h * h)) * 0.22;

    // Compute center of the sweep along a diagonal path
    final Offset center = Offset(w * p, h * (1.0 - p));

    // Set up a rotated gradient rect covering the screen
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 6); // slight tilt for visual interest

    final Rect r = Rect.fromCenter(
      center: Offset.zero,
      width: band,
      height: h * 2.2,
    );

    // Use a plus blend to add a gentle glow without washing out colors
    final Paint paint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.24),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
      ).createShader(r);

    // Use saveLayer so blend mode applies softly over the background
    canvas.saveLayer(r, Paint());
    canvas.drawRect(r, paint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerSweepPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}

class _StarfieldPainter extends CustomPainter {
  final Color color;
  final double t; // 0..1
  final int count;

  _StarfieldPainter({required this.color, required this.t, this.count = 36});

  double _hash(int i) {
    // Deterministic pseudo-random from index
    return (math.sin(i * 12.9898) * 43758.5453) % 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..style = PaintingStyle.fill;
    final double w = size.width;
    final double h = size.height;

    for (int i = 0; i < count; i++) {
      final double rx = (_hash(i) + 0.5 * _hash(i + 97)) % 1.0;
      final double ry = (_hash(i + 13) + 0.5 * _hash(i + 131)) % 1.0;

      // Keep a margin from the very top to avoid status bar shimmer artifacts
      final double y = 0.08 * h + ry * (0.88 * h);
      final double x = rx * w;

      // Twinkle using different frequencies per star (slowed and softened)
      final double f =
          0.10 + 0.20 * ((_hash(i + 7) * 1.3) % 1.0); // 0.10..0.30x
      final double phase = _hash(i + 23) * 2 * math.pi;
      final double a =
          0.03 +
          0.10 * (0.5 + 0.5 * math.sin((t * 0.4 * 2 * math.pi * f) + phase));

      final double sizePx = 0.6 + 1.4 * (_hash(i + 211) * 1.0);

      p.color = color.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), sizePx, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.color != color ||
        oldDelegate.count != count;
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

class _TwinkleSparklePainter extends CustomPainter {
  final Color color;
  final int timeMs;
  final int count;
  final int seed;

  _TwinkleSparklePainter({
    required this.color,
    required this.timeMs,
    this.count = 72,
    this.seed = 2025,
  });

  double _hashDouble(int i) {
    final double s = math.sin((i + seed) * 12.9898) * 43758.5453;
    return s - s.floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus; // add glow nicely

    final double w = size.width;
    final double h = size.height;

    // Time in seconds
    final double t = timeMs / 1000.0;
    final int sec = t.floor();

    // Roughly 2 events per minute on average
    const double eventsPerMinute = 4.0;
    const double pPerSecond = eventsPerMinute / 60.0; // ≈ 0.0333

    // Deterministic RNG per second to decide if a twinkle occurs and which star
    final double r = _hashDouble(sec + 100003);
    final bool twinkleNow = r < pPerSecond;

    if (!twinkleNow) return; // Nothing to draw this frame

    // Pick a random star index for this second
    int idx = (count * _hashDouble(sec * 7 + 2027)).floor();
    if (idx < 0) idx = 0;
    if (idx >= count) idx = count - 1;

    // Position for the chosen star (same distribution as starfield)
    final double rx = (_hashDouble(idx) + 0.5 * _hashDouble(idx + 97)) % 1.0;
    final double ry =
        (_hashDouble(idx + 13) + 0.5 * _hashDouble(idx + 131)) % 1.0;
    final double x = rx * w;
    final double y = 0.08 * h + ry * (0.88 * h);

    // Short flash duration within the current second
    const double duration = 0.8; // seconds
    final double frac = t - sec; // 0..1 within this second
    if (frac > duration) return;

    // Smooth in/out pulse curve
    final double u = frac / duration; // 0..1
    final double intensity = math
        .pow(math.sin(u * math.pi).clamp(0.0, 1.0), 3)
        .toDouble();

    // Size and alpha scale with intensity
    final double baseSize = 0.9 + 1.1 * _hashDouble(idx + 211);
    final double radius = baseSize * (1.0 + 1.8 * intensity);

    // Core point glow
    p.color = color.withValues(alpha: (0.18 + 0.42 * intensity));
    canvas.drawCircle(Offset(x, y), radius, p);

    // Tiny cross sparkle
    final Paint line = Paint()
      ..color = color.withValues(alpha: (0.10 + 0.35 * intensity))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2 + 1.8 * intensity
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;

    final double len = 4.0 + 10.0 * intensity;
    canvas.drawLine(Offset(x - len, y), Offset(x + len, y), line);
    canvas.drawLine(Offset(x, y - len), Offset(x, y + len), line);
  }

  @override
  bool shouldRepaint(covariant _TwinkleSparklePainter oldDelegate) {
    return oldDelegate.timeMs != timeMs ||
        oldDelegate.color != color ||
        oldDelegate.count != count ||
        oldDelegate.seed != seed;
  }
}

class _ShootingStarPainter extends CustomPainter {
  final Color color;
  final int timeMs;
  final int seed;

  _ShootingStarPainter({
    required this.color,
    required this.timeMs,
    this.seed = 1337,
  });

  double _hashDouble(int x) {
    final double s = math.sin((x + seed) * 12.9898) * 43758.5453;
    return s - s.floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Drive appearance in epochs so it's occasional and deterministic.
    const int periodMs = 12000; // evaluate spawn every 12s
    final int epoch = timeMs ~/ periodMs;
    final double phase = ((timeMs % periodMs) / periodMs);

    // Only render a shooting star in some epochs (about 2/3 probability for higher frequency)
    final double chance = _hashDouble(epoch);
    if (chance > 0.666) {
      return; // no shooting star this epoch
    }

    // Use only a sub-window of the period to actually animate the star (about 1.4s window)
    const double windowStart = 0.15;
    const double windowEnd = 0.30;
    final double windowLen = (windowEnd - windowStart);
    double p = (phase - windowStart) / windowLen; // 0..1 during active window
    if (p <= 0.0 || p >= 1.0) {
      return;
    }

    // Randomize start position and trajectory slightly per epoch
    final double xStartJitter =
        (_hashDouble(epoch + 17) - 0.5) * 0.4; // -0.2..0.2 of width
    final double yBase =
        0.15 + 0.45 * _hashDouble(epoch + 29); // 15%..60% height
    final double slope =
        0.18 + 0.24 * _hashDouble(epoch + 41); // gentle downward slope

    final double w = size.width;
    final double h = size.height;

    final Offset start = Offset(w * (xStartJitter), h * yBase);
    final Offset dir = Offset(
      w * 1.2,
      h * slope,
    ); // mostly right with slight down
    final Offset pos = start + dir * p;

    // Trail parameters
    final Offset unitDir = dir / dir.distance;
    final double mainLen = 80.0 + 60.0 * _hashDouble(epoch + 53);
    final double tailLen = mainLen * (0.6 + 0.3 * (1.0 - p));
    final double thickness = 2.0 + 1.0 * _hashDouble(epoch + 61);

    final Paint headPaint = Paint()
      ..color = color.withValues(
        alpha: (0.80 * (0.8 + 0.2 * _hashDouble(epoch + 73))),
      )
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;

    final Paint tailPaint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..strokeWidth = thickness * 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;

    // Draw tail first (fainter and longer), then bright head segment
    final Offset tailEnd = pos - unitDir * tailLen;
    canvas.drawLine(tailEnd, pos, tailPaint);

    final Offset headEnd = pos - unitDir * (tailLen * 0.35);
    canvas.drawLine(headEnd, pos, headPaint);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) {
    return oldDelegate.timeMs != timeMs ||
        oldDelegate.color != color ||
        oldDelegate.seed != seed;
  }
}
