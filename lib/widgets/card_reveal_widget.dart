import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';

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

    // _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
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
    return Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      key: const ValueKey('placeholder'),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 98.0,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
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
                Icon(
                  symbol.iconData,
                  size: 162.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8.0),
                Text(
                  symbol.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
