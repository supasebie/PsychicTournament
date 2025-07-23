# Requirements Document

## Introduction

The Zener card mobile application features a core guessing game where users attempt to predict which of five Zener symbols will be drawn from a virtual deck. The game follows the traditional Zener card test format with 25 trials per session, providing users with immediate feedback on their psychic abilities through an intuitive mobile interface.

## Requirements

### Requirement 1

**User Story:** As a player, I want to play a complete 25-card Zener guessing game, so that I can test my psychic abilities in a structured format.

#### Acceptance Criteria

1. WHEN a new game starts THEN the system SHALL create a virtual deck of exactly 25 cards containing 5 of each Zener symbol (Circle, Cross, Waves, Square, Star)
2. WHEN the deck is created it should be completely random and THEN assigned remote viewing coordinates that is a unique combination of letters and numbers XXXX-XXXX
3. WHEN a game session begins THEN the system SHALL initialize the score to 0 and turn counter to 1
4. WHEN the user completes 25 guesses THEN the system SHALL end the current game session

### Requirement 2

**User Story:** As a player, I want to make guesses by selecting from five symbol options, so that I can participate in each turn of the game.

#### Acceptance Criteria

1. WHEN the game screen loads THEN the system SHALL display five distinct, clearly labeled buttons for each Zener symbol
2. WHEN the user taps a symbol button THEN the system SHALL record the guess and disable all symbol buttons temporarily
3. WHEN a guess is made THEN the system SHALL compare the user's selection against the correct card for that turn
4. WHEN the result is processed THEN the system SHALL re-enable the symbol buttons for the next turn

### Requirement 3

**User Story:** As a player, I want to see immediate feedback on my guesses, so that I know whether I was correct and what the actual card was.

#### Acceptance Criteria

1. WHEN the user makes a correct guess THEN the system SHALL display "Correct!" message and reveal the matching symbol
2. WHEN the user makes an incorrect guess THEN the system SHALL display "Incorrect. The card was a [Symbol Name]" and reveal the correct symbol
3. WHEN feedback is shown THEN the system SHALL maintain the display for 1-2 seconds before resetting for the next turn
4. WHEN a correct guess is made THEN the system SHALL increment the user's score by 1

### Requirement 4

**User Story:** As a player, I want to track my progress throughout the game, so that I can see how well I'm performing.

#### Acceptance Criteria

1. WHEN the game is active THEN the system SHALL display the current score in "Score: X / 25" format
2. WHEN a correct guess is made THEN the system SHALL update the score display immediately
3. WHEN each turn completes THEN the system SHALL advance the turn counter from 1 to 25
4. WHEN the game screen loads THEN the system SHALL show a card display area for revealing correct symbols

### Requirement 5

**User Story:** As a player, I want to see my final results and start a new game, so that I can review my performance and play again.

#### Acceptance Criteria

1. WHEN the 25th guess is completed THEN the system SHALL display a final score screen showing "You scored X out of 25"
2. WHEN the final score screen appears THEN the system SHALL include a prominent "Play Again" button
3. WHEN the "Play Again" button is tapped THEN the system SHALL reset all game state and start a new game with a freshly shuffled deck
4. WHEN a new game starts after completion THEN the system SHALL return to the main game screen with score reset to 0

### Requirement 6

**User Story:** As a player, I want a clean and intuitive interface, so that I can focus on the guessing game without distractions.

#### Acceptance Criteria

1. WHEN the main game screen loads THEN the system SHALL display a clean interface with score tracker, card display area, and symbol selection controls
2. WHEN no guess has been made THEN the system SHALL show a placeholder in the card display area
3. WHEN the user interface loads THEN the system SHALL ensure all Zener symbols are clearly distinguishable and properly labeled
4. WHEN transitioning between turns THEN the system SHALL provide smooth visual feedback and state changes
