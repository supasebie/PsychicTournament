import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';
import 'svg_symbol.dart';
import 'shimmer.dart';

/// Widget that displays five symbol buttons for user selection during the game
class SymbolSelectionWidget extends StatelessWidget {
  /// Callback function called when a symbol is selected
  final Function(ZenerSymbol) onSymbolSelected;

  /// Whether the buttons should be enabled for interaction
  final bool buttonsEnabled;

  const SymbolSelectionWidget({
    super.key,
    required this.onSymbolSelected,
    this.buttonsEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select a symbol:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two-row layout: 3 on top, 2 on bottom
              final double availableWidth = constraints.maxWidth;
              final double spacing = 12.0;

              // Compute square button size that fits BOTH rows
              final double perTop =
                  (availableWidth - spacing * 2) / 3; // 3 buttons, 2 gaps
              final double perBottom =
                  (availableWidth - spacing * 1) / 2; // 2 buttons, 1 gap
              // Base size that fits both rows
              double buttonSize = perTop;
              if (buttonSize > perBottom) buttonSize = perBottom;
              // Current baseline (previously reduced to ~75%)
              buttonSize = buttonSize * 0.75;
              // Increase by 10% per request
              buttonSize = buttonSize * 1.10;
              // Clamp to reasonable/accessibility-friendly bounds (also increased by 10%)
              const double minButton = 59.4; // 54 * 1.10
              const double maxButton = 105.6; // 96 * 1.10
              if (buttonSize < minButton) buttonSize = minButton;
              if (buttonSize > maxButton) buttonSize = maxButton;

              final symbols = ZenerSymbol.values;
              final topRow = symbols.sublist(0, 3);
              final bottomRow = symbols.sublist(3);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row (3 symbols)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < topRow.length; i++) ...[
                        _buildSymbolButton(
                          context,
                          topRow[i],
                          buttonSize,
                          buttonSize,
                        ),
                        if (i < topRow.length - 1) SizedBox(width: spacing),
                      ],
                    ],
                  ),
                  SizedBox(height: spacing),
                  // Bottom row (2 symbols)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < bottomRow.length; i++) ...[
                        _buildSymbolButton(
                          context,
                          bottomRow[i],
                          buttonSize,
                          buttonSize,
                        ),
                        if (i < bottomRow.length - 1) SizedBox(width: spacing),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds an individual symbol button with responsive sizing
  Widget _buildSymbolButton(
    BuildContext context,
    ZenerSymbol symbol,
    double buttonWidth,
    double buttonHeight,
  ) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Semantics(
        label: '${symbol.displayName} symbol button',
        hint: 'Tap to select ${symbol.displayName}',
        button: true,
        enabled: buttonsEnabled,
        child: ElevatedButton(
          onPressed: buttonsEnabled ? () => onSymbolSelected(symbol) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: buttonsEnabled ? 2 : 0,
            // Ensure minimum touch target size for accessibility
            minimumSize: const Size(48, 48),
          ),
          child: PurpleGlowShimmer(
            enabled: true,
            period: const Duration(milliseconds: 2600),
            angle: 0.6,
            highlightWidth: 0.24,
            child: SvgSymbol(
              assetPath: symbol.assetPath,
              // Increase icon size proportionally with larger buttons
              size: _iconSizeFor(buttonWidth),
              semanticLabel: symbol.displayName,
            ),
          ),
        ),
      ),
    );
  }

  // Computes icon size as a double, scaled for current button sizing
  double _iconSizeFor(double buttonWidth) {
    double size = buttonWidth * 0.62;
    // Adjust min/max to keep icons proportional (increase clamps by 10%)
    const double minIcon = 29.7; // 27 * 1.10
    const double maxIcon = 59.4; // 54 * 1.10
    if (size < minIcon) size = minIcon;
    if (size > maxIcon) size = maxIcon;
    return size;
  }
}
