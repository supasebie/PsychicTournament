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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: ZenerSymbol.values.map((symbol) {
              return _buildSymbolButton(context, symbol);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds an individual symbol button
  Widget _buildSymbolButton(BuildContext context, ZenerSymbol symbol) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Semantics(
        label: symbol.displayName,
        button: true,
        child: ElevatedButton(
          onPressed: buttonsEnabled ? () => onSymbolSelected(symbol) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: buttonsEnabled ? 2 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(symbol.iconData, size: 32),
              const SizedBox(height: 4),
              Text(
                symbol.displayName,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
