# Design Document

## Overview

The Enhanced Feedback System adds immersive visual and haptic feedback to the Zener card game by displaying prominent overlay notifications ("Hit!" or "Miss") with high z-index positioning and device vibration. The system integrates seamlessly with the existing game flow while providing more engaging user feedback through modern mobile interaction patterns.

## Architecture

### Integration Points

The enhanced feedback system integrates with the existing game architecture at the following points:

```
ZenerGameScreen (Main Integration Point)
├── _onSymbolSelected() - Trigger point for feedback
├── Enhanced Feedback Overlay (New Component)
├── Haptic Feedback Service (New Service)
└── Existing CardRevealWidget (Unchanged)
```

### Component Hierarchy

```
ZenerGameScreen
├── Scaffold
│   ├── AppBar
│   └── Body
│       ├── Game Content (Existing)
│       └── FeedbackOverlay (New - Positioned with Stack)
│           ├── AnimatedContainer (Overlay Background)
│           └── FeedbackText (Hit!/Miss Text)
```

### State Management Integration

The feedback system extends the existing state management in `ZenerGameScreen`:

```dart
class _ZenerGameScreenState extends State<ZenerGameScreen> {
  // Existing state variables...

  // New feedback state variables
  bool _showFeedbackOverlay = false;
  String _overlayFeedbackText = '';
  bool _isCorrectGuess = false;
  Timer? _overlayTimer;
}
```

## Components and Interfaces

### 1. FeedbackOverlay Widget

**Purpose:** Displays prominent overlay feedback with high z-index positioning
**Responsibilities:**

- Render "Hit!" or "Miss" text with appropriate styling
- Handle fade-in/fade-out animations
- Ensure proper z-index positioning above all content

**Implementation:**

```dart
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
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Animation and styling implementation
}
```

### 2. HapticFeedbackService

**Purpose:** Manages device vibration for guess feedback
**Responsibilities:**

- Trigger appropriate haptic feedback patterns
- Handle platform differences gracefully
- Provide fallback behavior for unsupported devices

**Implementation:**

```dart
class HapticFeedbackService {
  static Future<void> triggerCorrectGuessFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Graceful fallback - no vibration
      debugPrint('Haptic feedback not available: $e');
    }
  }

  static Future<void> triggerIncorrectGuessFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Graceful fallback - no vibration
      debugPrint('Haptic feedback not available: $e');
    }
  }
}
```

### 3. Enhanced ZenerGameScreen Integration

**Modified Methods:**

```dart
void _onSymbolSelected(ZenerSymbol selectedSymbol) {
  // Existing logic...

  // New: Trigger enhanced feedback
  _showEnhancedFeedback(result);

  // Existing logic continues...
}

void _showEnhancedFeedback(GuessResult result) {
  // Show overlay
  setState(() {
    _showFeedbackOverlay = true;
    _overlayFeedbackText = result.isCorrect ? 'Hit!' : 'Miss';
    _isCorrectGuess = result.isCorrect;
  });

  // Trigger haptic feedback
  if (result.isCorrect) {
    HapticFeedbackService.triggerCorrectGuessFeedback();
  } else {
    HapticFeedbackService.triggerIncorrectGuessFeedback();
  }

  // Auto-hide overlay after delay
  _overlayTimer?.cancel();
  _overlayTimer = Timer(const Duration(milliseconds: 1500), () {
    if (mounted) {
      setState(() {
        _showFeedbackOverlay = false;
      });
    }
  });
}
```

## Data Models

### FeedbackState Model

```dart
class FeedbackState {
  final bool isVisible;
  final String message;
  final bool isCorrect;
  final DateTime timestamp;

  const FeedbackState({
    required this.isVisible,
    required this.message,
    required this.isCorrect,
    required this.timestamp,
  });

  FeedbackState copyWith({
    bool? isVisible,
    String? message,
    bool? isCorrect,
    DateTime? timestamp,
  }) {
    return FeedbackState(
      isVisible: isVisible ?? this.isVisible,
      message: message ?? this.message,
      isCorrect: isCorrect ?? this.isCorrect,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
```

## Visual Design Specifications

### Overlay Styling

**Hit! Message:**

- Text: "Hit!"
- Font Size: 48px
- Font Weight: Bold
- Color: Green (#4CAF50)
- Background: Semi-transparent white with green tint
- Border: 2px solid green
- Border Radius: 12px
- Shadow: Elevated shadow for depth

**Miss Message:**

- Text: "Miss"
- Font Size: 48px
- Font Weight: Bold
- Color: Red (#F44336)
- Background: Semi-transparent white with red tint
- Border: 2px solid red
- Border Radius: 12px
- Shadow: Elevated shadow for depth

### Animation Specifications

**Fade-In Animation:**

- Duration: 300ms
- Curve: Curves.easeOutBack
- Scale: 0.8 → 1.0
- Opacity: 0.0 → 1.0

**Fade-Out Animation:**

- Duration: 200ms
- Curve: Curves.easeInQuart
- Scale: 1.0 → 0.9
- Opacity: 1.0 → 0.0

### Positioning

- Position: Center of screen
- Z-Index: 1000 (above all other content)
- Padding: 24px horizontal, 16px vertical
- Margin: 16px from screen edges

## Haptic Feedback Patterns

### Correct Guess (Hit!)

- Pattern: Light impact
- Duration: ~50ms
- Intensity: Light
- Platform: `HapticFeedback.lightImpact()`

### Incorrect Guess (Miss)

- Pattern: Medium impact
- Duration: ~100ms
- Intensity: Medium
- Platform: `HapticFeedback.mediumImpact()`

## Error Handling

### Haptic Feedback Failures

- Graceful degradation when haptic feedback is unavailable
- No user-visible errors for haptic failures
- Debug logging for development troubleshooting

### Animation Failures

- Fallback to instant show/hide if animations fail
- Ensure overlay state consistency
- Timer cleanup on widget disposal

### State Consistency

- Prevent multiple overlays from showing simultaneously
- Ensure overlay dismissal even if timers fail
- Handle rapid user interactions gracefully

## Performance Considerations

### Animation Optimization

- Use `SingleTickerProviderStateMixin` for efficient animation control
- Dispose animation controllers properly
- Minimize widget rebuilds during animations

### Memory Management

- Cancel timers on widget disposal
- Avoid memory leaks from animation controllers
- Efficient overlay rendering with minimal widget tree changes

### Haptic Feedback Efficiency

- Async haptic calls to prevent UI blocking
- Minimal overhead for unsupported devices
- No repeated haptic calls for rapid interactions

## Testing Strategy

### Unit Testing

**HapticFeedbackService Tests:**

- Test correct/incorrect feedback triggering
- Test graceful fallback behavior
- Test platform compatibility

**FeedbackOverlay Tests:**

- Test visibility state changes
- Test message and styling updates
- Test animation lifecycle

### Widget Testing

**Integration Tests:**

- Test overlay positioning and z-index
- Test animation timing and smoothness
- Test haptic feedback integration
- Test overlay dismissal timing

**User Experience Tests:**

- Test overlay visibility during game flow
- Test non-interference with existing UI
- Test accessibility compliance
- Test performance under rapid interactions

### Accessibility Testing

**Screen Reader Compatibility:**

- Ensure overlay messages are announced
- Test semantic labels for feedback states
- Verify focus management during overlays

**Visual Accessibility:**

- Test high contrast mode compatibility
- Verify color differentiation for colorblind users
- Test text scaling compatibility

## Implementation Dependencies

### Required Flutter Packages

- `flutter/services.dart` - For HapticFeedback
- `flutter/material.dart` - For overlay and animation components
- `dart:async` - For timer management

### Platform Requirements

- iOS: Haptic feedback requires iOS 10.0+
- Android: Haptic feedback requires API level 23+
- Web: Haptic feedback gracefully degrades (no vibration)

## Integration Timeline

### Phase 1: Core Overlay Implementation

1. Create FeedbackOverlay widget
2. Integrate overlay into ZenerGameScreen
3. Implement basic show/hide functionality

### Phase 2: Animation and Styling

1. Add fade-in/fade-out animations
2. Implement visual styling for Hit!/Miss
3. Add proper z-index positioning

### Phase 3: Haptic Feedback

1. Create HapticFeedbackService
2. Integrate haptic triggers with guess results
3. Add platform compatibility handling

### Phase 4: Testing and Polish

1. Comprehensive testing across platforms
2. Performance optimization
3. Accessibility compliance verification
