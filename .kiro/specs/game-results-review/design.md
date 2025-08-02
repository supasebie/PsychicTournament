# Design Document

## Overview

The Game Results Review feature adds comprehensive post-game analysis by tracking all user guesses during gameplay and displaying them in a detailed review screen. This feature integrates seamlessly with the existing game architecture by extending the GameController and GameState models to store turn-by-turn data, and adding a new results review screen accessible from the final score dialog.

## Architecture

### Data Flow

1. **During Gameplay**: Each guess is immediately logged to a results list in GameState
2. **Game Completion**: Results data is passed to the final score dialog
3. **Results Navigation**: User can access detailed review screen from final score dialog
4. **Results Display**: Grid layout shows all 25 turns with visual indicators for correct guesses

### Integration Points

- **GameController**: Extended to track and store guess results
- **GameState**: Modified to include results history
- **FinalScoreDialog**: Enhanced with "View Results" navigation
- **New ResultsReviewScreen**: Dedicated screen for displaying detailed results

## Components and Interfaces

### Enhanced GameState Model

```dart
class GameState {
  // Existing properties...
  final List<List<ZenerSymbol>> gameResults; // [[userGuess, correctAnswer], ...]

  // Enhanced copyWith method to handle results
  GameState copyWith({
    // existing parameters...
    List<List<ZenerSymbol>>? gameResults,
  });
}
```

### Enhanced GameController

```dart
class GameController {
  // New method to get complete results
  List<List<ZenerSymbol>> getGameResults();

  // Modified makeGuess to store results
  GuessResult makeGuess(ZenerSymbol userGuess) {
    // Existing logic...
    // Add: Store [userGuess, correctSymbol] to gameResults
  }
}
```

### New ResultsReviewScreen

```dart
class ResultsReviewScreen extends StatelessWidget {
  final List<List<ZenerSymbol>> gameResults;
  final int finalScore;

  // Displays 5x5 grid of results
  // Highlights correct guesses with blue border
  // Shows symbols using existing ZenerSymbol.iconData
}
```

### Enhanced FinalScoreDialog

```dart
class FinalScoreDialog extends StatefulWidget {
  // Existing properties...
  final List<List<ZenerSymbol>>? gameResults; // Optional for backward compatibility

  // New callback for results navigation
  final VoidCallback? onViewResults;
}
```

## Data Models

### Results Data Structure

The game results are stored as a list of two-element lists:

```dart
List<List<ZenerSymbol>> gameResults = [
  [ZenerSymbol.circle, ZenerSymbol.star],    // Turn 1: guessed circle, correct was star
  [ZenerSymbol.star, ZenerSymbol.star],      // Turn 2: guessed star, correct was star (match)
  [ZenerSymbol.square, ZenerSymbol.square],  // Turn 3: guessed square, correct was square (match)
  // ... continues for all 25 turns
];
```

### Turn Result Model

```dart
class TurnResult {
  final int turnNumber;
  final ZenerSymbol userGuess;
  final ZenerSymbol correctAnswer;
  final bool isCorrect;

  const TurnResult({
    required this.turnNumber,
    required this.userGuess,
    required this.correctAnswer,
    required this.isCorrect,
  });
}
```

## Error Handling

### Data Integrity

- **Validation**: Ensure gameResults list always contains exactly 25 entries when game is complete
- **Null Safety**: Handle cases where gameResults might be incomplete or null
- **State Consistency**: Verify results data matches the actual game progression

### Navigation Errors

- **Screen Navigation**: Graceful handling of navigation failures between screens
- **Data Passing**: Ensure results data is properly passed between components
- **Back Navigation**: Proper cleanup when returning from results screen

### Display Errors

- **Grid Layout**: Handle different screen sizes and orientations
- **Symbol Rendering**: Fallback for missing or invalid symbol data
- **Memory Management**: Efficient rendering of 25 result cells

## Testing Strategy

### Unit Testing (Note: Tests will be created manually by developer)

- **GameController**: Test results tracking and retrieval methods
- **GameState**: Test results storage and state transitions
- **TurnResult**: Test data model validation and properties

### Widget Testing

- **ResultsReviewScreen**: Test grid layout and symbol display
- **FinalScoreDialog**: Test enhanced dialog with results navigation
- **Results Grid**: Test correct/incorrect visual indicators

### Integration Testing

- **End-to-End Flow**: Test complete game → results → navigation flow
- **Data Persistence**: Test results data integrity throughout game lifecycle
- **Screen Transitions**: Test smooth navigation between game, dialog, and results screens

## UI/UX Design

### Results Grid Layout

- **5x5 Grid**: 25 cells arranged in 5 rows and 5 columns
- **Cell Structure**: Each cell divided into left (user guess) and right (correct answer) sections
- **Visual Indicators**: Blue border/background for correct guesses, neutral for incorrect
- **Responsive Design**: Grid adapts to different screen sizes while maintaining readability

### Symbol Display

- **Icon Usage**: Leverage existing ZenerSymbol.iconData for consistent visual representation
- **Size Optimization**: Symbols sized appropriately for grid cell constraints
- **Color Coding**: Maintain existing symbol colors (blue waves, red cross, etc.)

### Navigation Flow

```
Game Complete → Final Score Dialog → [View Results Button] → Results Review Screen
                     ↓                                              ↓
                [Play Again]                                   [Back/New Game]
```

### Accessibility

- **Screen Reader Support**: Proper semantic labels for grid cells and symbols
- **High Contrast**: Ensure visual indicators work with accessibility settings
- **Touch Targets**: Adequate spacing for navigation elements
