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
    color: scheme.onSurface.withValues(alpha: 2.1),
    t: _t.value,
    count: 288, // <- increase this
  ),
)
```

How:
- Increase `count` (e.g., 360, 480) for a denser starfield.
- Performance tip: Higher counts mean more draws per frame. Increase gradually and test on device.

## Increase the twinkle of the stars

Where:
- Inside class `_StarfieldPainter`:

```
// Twinkle frequency and amplitude
final double f = 0.30 + 0.60 * ((_hash(i + 21) * 3.9) % 3.0); // frequency
final double a = 0.09 + 0.15 * (1.5 + 1.5 * math.sin((t * 1.2 * 6 * math.pi * f) + phase));
```

How:
- Increase brightness amplitude by raising the constants in `a`:
  - Base brightness (minimum): `0.09`
  - Twinkle amplitude (adds on top): `0.15`
  - Example for stronger twinkle:
    - `final double a = 0.12 + 0.24 * (1.5 + 1.5 * math.sin(...));`
- Make twinkle faster by raising frequency:
  - Increase the range of `f` (e.g., `0.60 + 1.20 * (...)`)
  - Or reduce the time scaling factor `1.2` (e.g., to `2.4`) in `t * 1.2 * 6 * math.pi * f`.

Tip: Brighter or faster twinkle can be distracting—tune subtly and test against foreground readability.

## Increase the glow drift

Where:
- In the Stack where painters are composed, the glow drift speed is set by the multiplier passed into `_NeonGlowPainter`:

```
CustomPaint(
  painter: _NeonGlowPainter(
    color: scheme.primary,
    t: _t.value * 1.80, // drift speed
  ),
)
```

How:
- Increase the multiplier to move glows faster (e.g., `2.40`, `3.0`).
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
      color.withValues(alpha: 0.18),
      color.withValues(alpha: 0.36), // peak intensity
      color.withValues(alpha: 0.18),
      color.withValues(alpha: 0.0),
    ],
    stops: const [0.0, 0.96, 1.5, 2.04, 3.0],
  ).createShader(r);
```

How:
- Increase the center alpha to make the sweep brighter (e.g., `0.42`, `0.54`).
- Widen the band by increasing its width factor:
  - Find: `final double band = (math.sqrt(w * w + h * h)) * 0.66;`
  - Raise `0.66` (e.g., `0.84`) for a wider, more present sweep.
- Make the sweep pass more often:
  - It currently completes one pass per background controller cycle via `final double p = (t) * 6.0 - 1.5;`.
  - Increase the overall animation speed by passing a shorter `duration:` into `AnimatedGradientBackground`, or multiply `t` (e.g., `p = (t * 4.5) * 6.0 - 1.5;`).

## Global tempo (advanced)

Where:
- In `AnimatedGradientBackground.initState`:

```
_controller = AnimationController(
  vsync: this,
  duration: widget.duration ?? const Duration(seconds: 90),
)..repeat(reverse: true);
```

How:
- Pass a custom `duration:` when constructing `AnimatedGradientBackground` to speed up or slow down all effects at once.
- Example:

```
AnimatedGradientBackground(
  duration: const Duration(seconds: 45),
  child: ...,
)
```

## Notes
- Keep changes small and test on device—subtlety preserves readability and reduces motion sickness.
- Consider exposing settings or a developer toggle to quickly adjust these values without code changes.

