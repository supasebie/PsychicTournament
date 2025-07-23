import 'dart:async';
import 'package:flutter/material.dart';

/// Widget that displays feedback messages with timer-based auto-hide functionality
class FeedbackDisplayWidget extends StatefulWidget {
  /// The feedback message to display
  final String? feedbackMessage;

  /// Duration to display the feedback message (1-2 seconds as per requirements)
  final Duration displayDuration;

  /// Callback when feedback display completes
  final VoidCallback? onFeedbackComplete;

  /// Whether the feedback represents a correct guess (affects styling)
  final bool isCorrect;

  const FeedbackDisplayWidget({
    super.key,
    this.feedbackMessage,
    this.displayDuration = const Duration(milliseconds: 1500),
    this.onFeedbackComplete,
    this.isCorrect = false,
  });

  @override
  State<FeedbackDisplayWidget> createState() => _FeedbackDisplayWidgetState();
}

class _FeedbackDisplayWidgetState extends State<FeedbackDisplayWidget> {
  Timer? _feedbackTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // Start feedback display if we have a message on initial creation
    if (widget.feedbackMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startFeedbackDisplay();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FeedbackDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start feedback display when a new message is provided
    if (widget.feedbackMessage != oldWidget.feedbackMessage &&
        widget.feedbackMessage != null) {
      _startFeedbackDisplay();
    }

    // Clear feedback when message is removed
    if (widget.feedbackMessage == null && oldWidget.feedbackMessage != null) {
      _clearFeedback();
    }
  }

  void _startFeedbackDisplay() {
    // Cancel any existing timer
    _feedbackTimer?.cancel();

    // Show feedback
    setState(() {
      _isVisible = true;
    });

    // Set timer to hide feedback after specified duration
    _feedbackTimer = Timer(widget.displayDuration, () {
      if (mounted) {
        _hideFeedback();
      }
    });
  }

  void _hideFeedback() {
    setState(() {
      _isVisible = false;
    });

    // Notify parent that feedback display is complete
    widget.onFeedbackComplete?.call();
  }

  void _clearFeedback() {
    _feedbackTimer?.cancel();
    setState(() {
      _isVisible = false;
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackMessage == null || !_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _getFeedbackBackgroundColor(context, widget.isCorrect),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: _getFeedbackBorderColor(context, widget.isCorrect),
            width: 1.0,
          ),
        ),
        child: Text(
          widget.feedbackMessage!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _getFeedbackTextColor(context, widget.isCorrect),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          semanticsLabel: widget.feedbackMessage,
        ),
      ),
    );
  }

  Color _getFeedbackBackgroundColor(BuildContext context, bool isCorrect) {
    if (isCorrect) {
      return Colors.green.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  Color _getFeedbackBorderColor(BuildContext context, bool isCorrect) {
    if (isCorrect) {
      return Colors.green.shade200;
    } else {
      return Colors.red.shade200;
    }
  }

  Color _getFeedbackTextColor(BuildContext context, bool isCorrect) {
    if (isCorrect) {
      return Colors.green.shade800;
    } else {
      return Colors.red.shade800;
    }
  }
}
