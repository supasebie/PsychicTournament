import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared SVG renderer wrapper around flutter_svg's SvgPicture.asset.
/// Centralizing here lets us control defaults and fallbacks in one place.
class SvgSymbol extends StatelessWidget {
  final String assetPath;
  final double size;
  final String? semanticLabel;

  /// Set a uniform color for the monochrome SVG strokes/fills.
  /// Default is white per request.
  final Color color;

  const SvgSymbol({
    super.key,
    required this.assetPath,
    required this.size,
    this.semanticLabel,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        // If an asset is missing or invalid, show a neutral placeholder.
        placeholderBuilder: (context) => SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
    );
  }
}
