import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/zener_symbol.dart';
import 'svg_symbol.dart';

/// Widget that displays a card area with placeholder and symbol reveal states
/// Now includes a 3D flip animation when revealing the card
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
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<CardRevealWidget> createState() => _CardRevealWidgetState();
}

class _CardRevealWidgetState extends State<CardRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  // Keep track of the symbol to display during animation
  ZenerSymbol? _displayedSymbol;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Flip animation for 3D rotation effect
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Scale animation for additional visual impact
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(CardRevealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when reveal state changes
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed && widget.revealedSymbol != null) {
        // Card is being revealed - store the symbol and flip forward
        setState(() {
          _displayedSymbol = widget.revealedSymbol;
        });
        _animationController.forward();
      } else if (!widget.isRevealed && oldWidget.isRevealed) {
        // Card is being hidden - flip back but keep the symbol until animation completes
        setState(() {});
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _displayedSymbol = null;
            });
          }
        });
      }
    }

    // Update symbol if it changes while card is revealed
    if (widget.isRevealed &&
        widget.revealedSymbol != oldWidget.revealedSymbol) {
      setState(() {
        _displayedSymbol = widget.revealedSymbol;
      });
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

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        // Calculate the rotation angle for the flip effect
        final angle = _flipAnimation.value * math.pi;

        // Determine which side of the card to show
        final showFront = angle >= math.pi / 2;

        // Apply perspective transform for 3D effect
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          child: Container(
            width: 290.0,
            height: 400.0,
            decoration: BoxDecoration(
              // Glass-like base to match the new style system
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
              child: Transform(
                alignment: Alignment.center,
                // Flip the content horizontally when showing the front
                transform: Matrix4.identity()..rotateY(showFront ? math.pi : 0),
                child: showFront && _displayedSymbol != null
                    ? _buildRevealedCard(_displayedSymbol!)
                    : _buildPlaceholderCard(),
              ),
            ),
          ),
        );
      },
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
      // Empty card back - no question mark or content
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildRevealedCard(ZenerSymbol symbol) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      key: ValueKey('revealed_${symbol.name}'),
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer.withValues(alpha: 0.3),
                cs.surface.withValues(alpha: 0.2),
              ],
            ),
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SvgSymbol(
                      assetPath: symbol.assetPath,
                      size: 178,
                      semanticLabel: symbol.displayName,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
