import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';
import 'svg_symbol.dart';

/// Widget that displays a card area with placeholder and symbol reveal states
class CardRevealWidget extends StatefulWidget {
  /// The symbol to reveal, null for placeholder state
  final ZenerSymbol? revealedSymbol;

  /// Whether to show the symbol (true) or placeholder (false)
  final bool isRevealed;

  /// Duration for the reveal animation
  final Duration animationDuration;

  const CardRevealWidget({
    super.key,
    this.revealedSymbol,
    this.isRevealed = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CardRevealWidget> createState() => _CardRevealWidgetState();
}

class _CardRevealWidgetState extends State<CardRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(CardRevealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when reveal state changes
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        // Glass-like base to match the new style system until GlassContainer is introduced.
        color: cs.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.10),
            blurRadius: 18.0,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: AnimatedSwitcher(
          duration: widget.animationDuration,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: widget.isRevealed && widget.revealedSymbol != null
              ? _buildRevealedCard()
              : _buildPlaceholderCard(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('placeholder'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 1.0],
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.30),
            cs.surface.withValues(alpha: 0.20),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 98.0,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealedCard() {
    final symbol = widget.revealedSymbol!;

    return AnimatedBuilder(
      key: ValueKey('revealed_${symbol.name}'),
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 172,
                  height: 172,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: SvgSymbol(
                    assetPath: symbol.assetPath,
                    size: 162.0,
                    semanticLabel: symbol.displayName,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Removed text label below the revealed symbol per request
                const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
