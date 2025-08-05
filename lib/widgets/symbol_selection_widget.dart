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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select a symbol:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive button size based on available width
              final availableWidth = constraints.maxWidth;
              final spacing = 8.0;
              final buttonWidth = ((availableWidth - (4 * spacing)) / 5).clamp(
                60.0,
                80.0,
              );
              final buttonHeight = buttonWidth;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: ZenerSymbol.values.map((symbol) {
                  return _buildSymbolButton(
                    context,
                    symbol,
                    buttonWidth,
                    buttonHeight,
                  );
                }).toList(),
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
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: buttonsEnabled ? 2 : 0,
            // Ensure minimum touch target size for accessibility
            minimumSize: const Size(44, 44),
          ),
          child: PurpleGlowShimmer(
            enabled: true,
            period: const Duration(milliseconds: 2600),
            angle: 0.6,
            highlightWidth: 0.24,
            child: SvgSymbol(
              assetPath: symbol.assetPath,
              size: (buttonWidth * 0.55).clamp(28.0, 48.0),
              semanticLabel: symbol.displayName,
              // Svg remains white; purple glow/shimmer will tint/shine over it.
            ),
          ),
        ),
      ),
    );
  }
}
