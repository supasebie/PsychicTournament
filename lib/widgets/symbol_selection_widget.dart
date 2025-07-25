import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                symbol.iconData,
                size: (buttonWidth * 0.4).clamp(24.0, 36.0),
                semanticLabel: symbol.displayName,
              ),
              SizedBox(height: buttonHeight * 0.05),
              Flexible(
                child: Text(
                  symbol.displayName,
                  style: TextStyle(
                    fontSize: (buttonWidth * 0.12).clamp(8.0, 12.0),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
