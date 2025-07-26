import 'package:flutter/material.dart';

/// A widget that displays prominent overlay feedback for correct/incorrect guesses
/// with smooth animations and distinct visual styling.
class FeedbackOverlay extends StatefulWidget {
  final bool isVisible;
  final String message;
  final bool isCorrect;
  final VoidCallback? onAnimationComplete;

  const FeedbackOverlay({
    super.key,
    required this.isVisible,
    required this.message,
    required this.isCorrect,
    this.onAnimationComplete,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 800ms total duration for bounce effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create scale animation: fade-in (0.8 → 1.0), fade-out (1.0 → 0.9)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInQuart,
      ),
    );

    // Create opacity animation: fade-in (0.0 → 1.0), fade-out (1.0 → 0.0)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    // Create bounce animation: moves up then down with bouncing effect
    _bounceAnimation = Tween<double>(begin: 20.0, end: -10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
        reverseCurve: Curves.bounceIn,
      ),
    );

    // Listen for animation completion
    _animationController.addStatusListener(_onAnimationStatusChanged);
  }

  /// Handles animation status changes and triggers completion callback
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void didUpdateWidget(FeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle visibility changes with error handling
    if (widget.isVisible != oldWidget.isVisible) {
      try {
        if (widget.isVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      } catch (e) {
        // Handle animation errors gracefully
        debugPrint('Animation error in FeedbackOverlay: $e');
        // Fallback: set visibility state directly without animation
        if (mounted) {
          setState(() {
            // Animation failed, but we can still show/hide the overlay
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Ensure animation controller is properly cleaned up
    _animationController.removeStatusListener(_onAnimationStatusChanged);
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _animationController.isDismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Ensure animation values are within valid bounds
        final double clampedOpacity = _opacityAnimation.value.clamp(0.0, 1.0);
        final double clampedScale = _scaleAnimation.value.clamp(0.1, 2.0);

        return Positioned(
          top:
              90.0 +
              _bounceAnimation.value, // Position towards top with bounce offset
          left: 0,
          right: 0,
          child: Transform.scale(
            scale: clampedScale,
            child: Opacity(
              opacity: clampedOpacity,
              child: Text(
                widget.message,
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Returns the text color based on whether the guess was correct
  Color _getTextColor() {
    return widget.isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  }
}
