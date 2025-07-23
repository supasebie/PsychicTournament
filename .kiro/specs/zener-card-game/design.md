# Design Document

## Overview

The Zener Card Game is a Flutter mobile application that implements a psychic ability testing game using the traditional 25-card Zener deck format. The application provides an intuitive interface for users to guess symbols, receive immediate feedback, and track their performance across game sessions. The design follows Flutter's Material Design principles while maintaining a clean, focused user experience optimized for the guessing game mechanics.

## Architecture

### Application Structure

The application follows a layered architecture pattern suitable for Flutter applications:

```
Presentation Layer (UI)
├── Game Screen Widget
├── Final Score Screen Widget
└── Symbol Selection Components

Business Logic Layer
├── Game Controller
├── Deck Manager
└── Score Manager

Data Layer
├── Game State Model
├── Zener Symbol Enum
└── Remote Viewing Coordinates Generator
```

### State Management

The application uses Flutter's built-in `StatefulWidget` and `setState()` for local state management, which is appropriate for the relatively simple state requirements of this game. The game state is contained within a single screen widget to ensure proper lifecycle management.

### Navigation

The application uses a single-screen approach with conditional rendering:

- Main game interface during active gameplay
- Final score overlay/dialog upon game completion
- Smooth transitions between game states without complex navigation

## Components and Interfaces

### Core Components

#### 1. ZenerGameScreen (StatefulWidget)

**Purpose:** Main game interface container
**Responsibilities:**

- Manages overall game state and lifecycle
- Coordinates between child components
- Handles game flow transitions

**Key Properties:**

```dart
class ZenerGameScreen extends StatefulWidget {
  // Game state properties managed in _ZenerGameScreenState
}

class _ZenerGameScreenState extends State<ZenerGameScreen> {
  GameController _gameController;
  int _currentScore;
  int _currentTurn;
  bool _buttonsEnabled;
  ZenerSymbol? _revealedSymbol;
  String _feedbackMessage;
}
```

#### 2. GameController

**Purpose:** Core game logic management
**Responsibilities:**

- Deck creation and shuffling
- Turn progression
- Score calculation
- Game completion detection

**Key Methods:**

```dart
class GameController {
  List<ZenerSymbol> createShuffledDeck();
  String generateRemoteViewingCoordinates();
  bool makeGuess(ZenerSymbol userGuess);
  ZenerSymbol getCurrentCorrectSymbol();
  bool isGameComplete();
  void resetGame();
}
```

#### 3. SymbolSelectionWidget

**Purpose:** User input interface for symbol selection
**Responsibilities:**

- Display five Zener symbol buttons
- Handle user input
- Manage button enabled/disabled states

**Key Properties:**

```dart
class SymbolSelectionWidget extends StatelessWidget {
  final Function(ZenerSymbol) onSymbolSelected;
  final bool buttonsEnabled;
}
```

#### 4. ScoreDisplayWidget

**Purpose:** Score tracking display
**Responsibilities:**

- Show current score in "X / 25" format
- Update display when score changes

#### 5. CardRevealWidget

**Purpose:** Card display and feedback area
**Responsibilities:**

- Show placeholder when no card is revealed
- Display correct symbol after guess
- Show feedback messages (Correct/Incorrect)

#### 6. FinalScoreDialog

**Purpose:** End-game results and replay option
**Responsibilities:**

- Display final score summary
- Provide "Play Again" functionality

## Data Models

### ZenerSymbol Enum

```dart
enum ZenerSymbol {
  circle,
  cross,
  waves,
  square,
  star
}

extension ZenerSymbolExtension on ZenerSymbol {
  String get displayName;
  String get assetPath;
  IconData get iconData; // For initial implementation
}
```

### GameState Model

```dart
class GameState {
  final List<ZenerSymbol> deck;
  final String remoteViewingCoordinates;
  final int currentTurn;
  final int score;
  final bool isComplete;

  GameState({
    required this.deck,
    required this.remoteViewingCoordinates,
    this.currentTurn = 1,
    this.score = 0,
    this.isComplete = false,
  });

  GameState copyWith({...});
}
```

### GuessResult Model

```dart
class GuessResult {
  final bool isCorrect;
  final ZenerSymbol correctSymbol;
  final ZenerSymbol userGuess;
  final int newScore;

  GuessResult({
    required this.isCorrect,
    required this.correctSymbol,
    required this.userGuess,
    required this.newScore,
  });
}
```

## Error Handling

### Input Validation

- Prevent multiple guesses per turn through button state management
- Validate symbol selection before processing
- Handle edge cases in turn progression

### State Consistency

- Ensure deck always contains exactly 25 cards
- Validate turn counter bounds (1-25)
- Maintain score integrity throughout game session

### User Experience Error Handling

- Graceful handling of rapid button taps
- Smooth transitions even if state updates are delayed
- Fallback UI states for any rendering issues

## Testing Strategy

### Unit Testing

**Game Logic Tests:**

- Deck creation and shuffling validation
- Score calculation accuracy
- Turn progression logic
- Remote viewing coordinate generation
- Game completion detection

**Model Tests:**

- GameState immutability and copying
- ZenerSymbol enum functionality
- GuessResult creation and validation

### Widget Testing

**UI Component Tests:**

- Symbol button rendering and interaction
- Score display updates
- Card reveal animations
- Feedback message display
- Final score dialog functionality

**Integration Tests:**

- Complete game flow from start to finish
- State transitions between turns
- Score persistence throughout game
- Play again functionality

### User Experience Testing

**Interaction Flow Tests:**

- Button disable/enable timing
- Feedback display duration
- Smooth transitions between game states
- Responsive design across different screen sizes

## Implementation Notes

### Asset Management

- Zener symbol assets will be stored in `assets/images/symbols/`
- Initial implementation can use Material Icons as placeholders
- SVG format preferred for scalability across device sizes

### Performance Considerations

- Minimal state updates to prevent unnecessary rebuilds
- Efficient list operations for deck management
- Optimized widget tree structure to minimize render cycles

### Accessibility

- Semantic labels for all interactive elements
- High contrast support for symbol differentiation
- Screen reader compatibility for feedback messages
- Appropriate touch target sizes (minimum 44px)

### Platform Considerations

- Material Design components for Android
- Cupertino-style adaptations for iOS (if needed)
- Responsive layout for various screen sizes
- Safe area handling for modern device screens

## Technical Dependencies

### Required Flutter Packages

- `flutter/material.dart` - Core UI components
- `dart:math` - Random number generation for shuffling
- `dart:async` - Timer functionality for feedback delays

### Potential Future Dependencies

- `flutter_svg` - If SVG assets are used
- `shared_preferences` - For persistent high scores (future feature)
- `provider` or `bloc` - If state management needs become more complex
