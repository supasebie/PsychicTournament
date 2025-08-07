# Animated Background Tuning Guide

This guide explains how to adjust the visual effects in the animated background used by the main menu.

File to edit:
- lib/widgets/animated_gradient_background.dart

The background is composed of four layered effects:
- A multi-stop animated gradient
- Soft neon radial glows that drift
- A subtle starfield that twinkles
- A diagonal shimmer sweep overlay

Below are the most common tweaks and where to change them.

## Increase the number of stars

Where:
- In the Stack where painters are composed, look for the Starfield painter:

```
CustomPaint(
  painter: _StarfieldPainter(
    color: scheme.onSurface.withValues(alpha: 0.7),
    t: _t.value,
    count: 96, // <- increase this
  ),
)
```

How:
- Increase `count` (e.g., 120, 160) for a denser starfield.
- Performance tip: Higher counts mean more draws per frame. Increase gradually and test on device.

## Increase the twinkle of the stars

Where:
- Inside class `_StarfieldPainter`:

```
// Twinkle frequency and amplitude
final double f = 0.10 + 0.20 * ((_hash(i + 7) * 1.3) % 1.0); // frequency
final double a = 0.03 + 0.05 * (0.5 + 0.5 * math.sin((t * 0.4 * 2 * math.pi * f) + phase));
```

How:
- Increase brightness amplitude by raising the constants in `a`:
  - Base brightness (minimum): `0.03`
  - Twinkle amplitude (adds on top): `0.05`
  - Example for stronger twinkle:
    - `final double a = 0.04 + 0.08 * (0.5 + 0.5 * math.sin(...));`
- Make twinkle faster by raising frequency:
  - Increase the range of `f` (e.g., `0.20 + 0.40 * (...)`)
  - Or reduce the time scaling factor `0.4` (e.g., to `0.8`) in `t * 0.4 * 2 * math.pi * f`.

Tip: Brighter or faster twinkle can be distracting—tune subtly and test against foreground readability.

## Increase the glow drift

Where:
- In the Stack where painters are composed, the glow drift speed is set by the multiplier passed into `_NeonGlowPainter`:

```
CustomPaint(
  painter: _NeonGlowPainter(
    color: scheme.primary,
    t: _t.value * 0.60, // drift speed
  ),
)
```

How:
- Increase the multiplier to move glows faster (e.g., `0.80`, `1.0`).
- For even more control, you can decouple the glow from the main controller by creating a separate `AnimationController` for the glow and using its value instead of `_t.value`.

## Increase the shimmer sweep

Where:
- Inside class `_ShimmerSweepPainter`:

```
final Paint paint = Paint()
  ..blendMode = BlendMode.plus
  ..shader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      color.withValues(alpha: 0.0),
      color.withValues(alpha: 0.06),
      color.withValues(alpha: 0.12), // peak intensity
      color.withValues(alpha: 0.06),
      color.withValues(alpha: 0.0),
    ],
    stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
  ).createShader(r);
```

How:
- Increase the center alpha to make the sweep brighter (e.g., `0.14`, `0.18`).
- Widen the band by increasing its width factor:
  - Find: `final double band = (math.sqrt(w * w + h * h)) * 0.22;`
  - Raise `0.22` (e.g., `0.28`) for a wider, more present sweep.
- Make the sweep pass more often:
  - It currently completes one pass per background controller cycle via `final double p = (t) * 2.0 - 0.5;`.
  - Increase the overall animation speed by passing a shorter `duration:` into `AnimatedGradientBackground`, or multiply `t` (e.g., `p = (t * 1.5) * 2.0 - 0.5;`).

## Global tempo (advanced)

Where:
- In `AnimatedGradientBackground.initState`:

```
_controller = AnimationController(
  vsync: this,
  duration: widget.duration ?? const Duration(seconds: 30),
)..repeat(reverse: true);
```

How:
- Pass a custom `duration:` when constructing `AnimatedGradientBackground` to speed up or slow down all effects at once.
- Example:

```
AnimatedGradientBackground(
  duration: const Duration(seconds: 15),
  child: ...,
)
```

## Notes
- Keep changes small and test on device—subtlety preserves readability and reduces motion sickness.
- Consider exposing settings or a developer toggle to quickly adjust these values without code changes.

