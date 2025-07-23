import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';

/// Widget that displays a card area with placeholder and symbol reveal states
class CardRevealWidget extends StatefulWidget {
  /// The symbol to reveal, null for placeholder state
  final ZenerSymbol? revealedSymbol;

  /// Whether to show the symbol (true) or placeholder (false)
  final bool isRevealed;

  /// Optional feedback message to display below the card
  final String? feedbackMessage;

  /// Duration for the reveal animation
  final Duration animationDuration;

  const CardRevealWidget({
    super.key,
    this.revealedSymbol,
    this.isRevealed = false,
    this.feedbackMessage,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CardRevealWidget> createState() => _CardRevealWidgetState();
}

class _CardRevealWidgetState extends State<CardRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card display area
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
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
        ),

        // Feedback message area
        const SizedBox(height: 12.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.feedbackMessage != null ? 32.0 : 0.0,
          child: widget.feedbackMessage != null
              ? AnimatedBuilder(
                  animation: _opacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: widget.isRevealed
                          ? _opacityAnimation.value
                          : 0.0,
                      child: Text(
                        widget.feedbackMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getFeedbackColor(context),
                        ),
                        textAlign: TextAlign.center,
                        semanticsLabel: widget.feedbackMessage,
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
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
              size: 48.0,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 8.0),
            Text(
              '?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  size: 64.0,
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

  Color _getFeedbackColor(BuildContext context) {
    if (widget.feedbackMessage == null) {
      return Theme.of(context).colorScheme.onSurface;
    }

    if (widget.feedbackMessage!.toLowerCase().contains('correct')) {
      return Colors.green.shade700;
    } else if (widget.feedbackMessage!.toLowerCase().contains('incorrect')) {
      return Colors.red.shade700;
    }

    return Theme.of(context).colorScheme.onSurface;
  }
}
