import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphism container with optional gradient border,
/// backdrop blur, and configurable tint. Centralizes frosted panel styling.
///
/// Example:
/// GlassContainer(
///   padding: const EdgeInsets.all(16),
///   child: Text('Content'),
/// )
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;

  /// Shadow strength; used as alpha multiplier on primary for glow-style shadow.
  final double elevation;

  /// Base tint color for the frosted fill; defaults to surfaceContainerHighest.
  final Color? tintColor;

  /// Opacity for tint.
  final double tintOpacity;

  /// Optional gradient border. If null, no border is drawn.
  final Gradient? borderGradient;
  final double borderWidth;
  final GestureTapCallback? onTap;

  const GlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blurSigma = 18.0,
    this.elevation = 0.14,
    this.tintColor,
    this.tintOpacity = 0.65,
    this.borderGradient,
    this.borderWidth = 1.2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color effectiveTint = (tintColor ?? cs.surfaceContainerHighest)
        .withValues(alpha: tintOpacity);

    final BoxShadow shadow = BoxShadow(
      color: cs.primary.withValues(alpha: elevation),
      blurRadius: 24,
      spreadRadius: 1.5,
      offset: const Offset(0, 10),
    );

    final BorderRadius br = BorderRadius.circular(borderRadius);

    Widget panel = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: effectiveTint),
          child: child,
        ),
      ),
    );

    // Optional gradient border overlay
    if (borderGradient != null && borderWidth > 0) {
      panel = Stack(
        children: [
          panel,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  gradient: borderGradient!,
                  strokeWidth: borderWidth,
                  radius: borderRadius,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Elevation/glow
    panel = DecoratedBox(
      decoration: BoxDecoration(borderRadius: br, boxShadow: [shadow]),
      child: panel,
    );

    if (onTap != null) {
      panel = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          splashColor: cs.primary.withValues(alpha: 0.08),
          highlightColor: cs.primary.withValues(alpha: 0.05),
          child: panel,
        ),
      );
    }

    return Container(margin: margin, child: panel);
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double radius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
