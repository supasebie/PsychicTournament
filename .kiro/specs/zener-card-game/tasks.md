# Implementation Plan

- [x] 1. Set up core data models and enums

  - Create ZenerSymbol enum with all five symbols and extension methods
  - Implement GameState model with immutable properties and copyWith method
  - Create GuessResult model for handling guess outcomes
  - Write unit tests for all data models
  - _Requirements: 1.1, 2.1, 3.1_

- [x] 2. Implement game controller and deck management

  - Create GameController class with deck creation and shuffling logic
  - Implement Fisher-Yates shuffle algorithm for deck randomization
  - Add remote viewing coordinates generation (XXXX-XXXX format)
  - Implement guess processing and score calculation methods
  - Write comprehensive unit tests for GameController
  - _Requirements: 1.1, 1.2, 2.3, 3.4_

- [x] 3. Create symbol selection UI component

  - Build SymbolSelectionWidget with five symbol buttons using ZenerSymbol.iconData
  - Implement button styling and layout using Material Design
  - Add button enable/disable functionality for turn management
  - Create callback mechanism for symbol selection
  - Write widget tests for symbol selection interactions
  - _Requirements: 2.1, 2.2, 6.3_

- [ ] 4. Implement score display and card reveal components

  - Create ScoreDisplayWidget showing "Score: X / 25" format
  - Build CardRevealWidget with placeholder and symbol reveal states
  - Implement smooth transitions between hidden and revealed states
  - Add proper styling and layout for both components
  - Write widget tests for display components
  - _Requirements: 4.1, 4.2, 6.2_

- [ ] 5. Create feedback system and messaging

  - Implement feedback message display for correct/incorrect guesses
  - Add "Correct!" and "Incorrect. The card was a [Symbol Name]" messages
  - Create timer-based feedback display with 1-2 second duration
  - Ensure feedback integrates smoothly with card reveal component
  - Write tests for feedback timing and message accuracy
  - _Requirements: 3.1, 3.2, 3.3_

- [ ] 6. Build main game screen and state management

  - Create ZenerGameScreen StatefulWidget as main game container
  - Implement game state management using setState pattern
  - Integrate all UI components into cohesive game interface
  - Add game flow logic for turn progression and state transitions
  - Handle button enabling/disabling during guess processing
  - Write integration tests for complete game flow
  - _Requirements: 1.3, 2.2, 2.4, 4.3, 6.1_

- [ ] 7. Implement game completion and final score screen

  - Create FinalScoreDialog for displaying end-game results
  - Add "You scored X out of 25" message formatting
  - Implement "Play Again" button with game reset functionality
  - Ensure proper game state cleanup and reinitialization
  - Write tests for game completion detection and reset logic
  - _Requirements: 1.4, 5.1, 5.2, 5.3, 5.4_

- [ ] 8. Add game timing and turn transitions

  - Implement turn transition logic with proper delays
  - Add smooth state resets between turns (hide card, clear feedback, enable buttons)
  - Ensure score updates happen immediately after correct guesses
  - Create seamless user experience with appropriate timing
  - Write tests for turn timing and state transitions
  - _Requirements: 3.3, 4.2, 4.4, 6.4_

- [ ] 9. Integrate components and finalize main application

  - Replace default Flutter counter app with ZenerGameScreen
  - Update app title and theme to match Psychic Tournament branding
  - Ensure proper app initialization and navigation
  - Add error handling for edge cases and invalid states
  - Perform end-to-end testing of complete application
  - _Requirements: 6.1, 6.4_

- [ ] 10. Add comprehensive testing and polish
  - Create integration tests covering complete game sessions
  - Add accessibility features (semantic labels, screen reader support)
  - Implement responsive design for different screen sizes
  - Add visual polish and animations for better user experience
  - Perform thorough testing on multiple devices and screen sizes
  - _Requirements: 6.3, 6.4_
