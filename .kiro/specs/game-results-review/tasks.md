# Implementation Plan

- [x] 1. Extend GameState model to track game results

  - Add `gameResults` property as `List<List<ZenerSymbol>>` to GameState class
  - Update the copyWith method to handle the new gameResults parameter
  - Initialize gameResults as empty list in constructor
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 2. Enhance GameController to store guess results during gameplay

  - Modify the `makeGuess` method to store each guess result in the format `[userGuess, correctAnswer]`
  - Add `getGameResults()` method to retrieve the complete results list
  - Update `_createInitialGameState()` to initialize empty results list
  - Ensure results are cleared when `resetGame()` is called
  - _Requirements: 2.1, 2.2, 2.4_

- [x] 3. Create TurnResult model class for structured data handling

  - Create `lib/models/turn_result.dart` with TurnResult class
  - Include properties: turnNumber, userGuess, correctAnswer, isCorrect
  - Add constructor with required parameters and validation
  - Implement equality operator and toString method
  - _Requirements: 1.1, 2.1_

- [x] 4. Create ResultsReviewScreen widget for displaying game results

  - Create `lib/screens/results_review_screen.dart` with StatelessWidget
  - Accept gameResults and finalScore as constructor parameters
  - Implement AppBar with title "Game Results" and back navigation
  - Create scaffold structure with proper SafeArea and padding
  - _Requirements: 1.2, 3.3, 4.1_

- [x] 5. Implement results grid layout in ResultsReviewScreen

  - Create 5x5 GridView.builder to display all 25 turns
  - Design individual grid cells to show user guess on left, correct answer on right
  - Implement visual separator between guess and correct answer within each cell
  - Ensure grid is responsive and fits properly on different screen sizes
  - _Requirements: 1.2, 1.3, 4.4, 4.5_

- [x] 6. Add visual indicators for correct and incorrect guesses

  - Implement blue border/background highlighting for correct guesses (when userGuess == correctAnswer)
  - Apply neutral styling for incorrect guesses
  - Use existing ZenerSymbol.iconData for consistent symbol display
  - Ensure symbols are properly sized for grid cell constraints
  - _Requirements: 1.4, 1.5, 4.1, 4.2_

- [x] 7. Enhance FinalScoreDialog to include results navigation

  - Add optional `gameResults` parameter to FinalScoreDialog constructor
  - Add optional `onViewResults` callback parameter for navigation handling
  - Create "View Detailed Results" button in dialog actions
  - Maintain backward compatibility with existing dialog usage
  - _Requirements: 3.1, 3.2_

- [x] 8. Update ZenerGameScreen to pass results data to final score dialog

  - Modify `_showFinalScoreDialog()` method to retrieve game results from controller
  - Pass gameResults to FinalScoreDialog constructor
  - Implement navigation callback to open ResultsReviewScreen
  - Ensure proper data flow from game completion to results display
  - _Requirements: 3.1, 3.2, 3.4_

- [x] 9. Implement navigation between screens and proper state management

  - Remove the existing popup that is displayed after a session and navigate directly to the new screen
  - Add navigation logic to get to the main screen
  - Implement back navigation from ResultsReviewScreen to main menu or new game
  - Ensure results data persists during navigation until new game starts
  - Handle navigation errors gracefully with fallback options
  - _Requirements: 3.2, 3.3, 3.4_

- [ ] 10. Add results grid cell widget for reusable turn display

  - Create `lib/widgets/result_cell_widget.dart` for individual turn display
  - Accept turnNumber, userGuess, correctAnswer, and isCorrect parameters
  - Implement left/right symbol layout with visual separator
  - Apply correct/incorrect styling based on isCorrect parameter
  - _Requirements: 1.3, 1.4, 4.2, 4.3_

- [ ] 11. Integrate results tracking with existing game flow

  - Verify results are properly stored during each turn in ZenerGameScreen
  - Test that results data is maintained throughout complete game session
  - Ensure results are cleared when starting new game via "Play Again"
  - Validate that all 25 turns are captured in the results list
  - _Requirements: 2.1, 2.3, 2.4_

- [ ] 12. Add error handling and data validation for results system
  - Implement validation to ensure gameResults contains exactly 25 entries when game is complete
  - Add null safety checks for gameResults data throughout the system
  - Handle edge cases where results data might be incomplete or corrupted
  - Provide fallback UI states for missing or invalid results data
  - _Requirements: 1.1, 2.1, 2.3_
