# Requirements Document

## Introduction

This feature adds a detailed results review screen that displays all 25 turns from a completed Zener card game session. After the user completes all 25 guesses, they can view a comprehensive breakdown showing their guess versus the correct answer for each turn, with visual indicators for correct matches. This enhances the user experience by providing detailed feedback on their psychic performance and allows them to analyze their guessing patterns.

## Requirements

### Requirement 1

**User Story:** As a player, I want to see all my guesses compared to the correct answers after completing a game, so that I can review my performance in detail.

#### Acceptance Criteria

1. WHEN the user completes all 25 turns THEN the system SHALL store each turn's guess and correct answer as a pair
2. WHEN the user views the results review THEN the system SHALL display all 25 turns in a 5x5 grid layout
3. WHEN displaying each turn THEN the system SHALL show the user's guess symbol on the left and the correct answer symbol on the right within each cell
4. WHEN the user's guess matches the correct answer THEN the system SHALL highlight that cell with a blue border or background
5. WHEN the user's guess does not match the correct answer THEN the system SHALL display the cell with a neutral appearance

### Requirement 2

**User Story:** As a player, I want the results to be stored during gameplay, so that no data is lost and the review is accurate.

#### Acceptance Criteria

1. WHEN the user makes a guess THEN the system SHALL immediately store the guess along with the correct answer for that turn
2. WHEN storing turn data THEN the system SHALL use the format [[userGuess, correctAnswer], [userGuess, correctAnswer], ...]
3. WHEN the game progresses THEN the system SHALL maintain the chronological order of turns in the stored data
4. WHEN the user restarts or starts a new game THEN the system SHALL clear the previous game's stored results

### Requirement 3

**User Story:** As a player, I want to access the detailed results review from the final score dialog, so that I can easily navigate to see my performance breakdown.

#### Acceptance Criteria

1. WHEN the final score dialog is displayed THEN the system SHALL provide a button or option to "View Detailed Results"
2. WHEN the user selects the detailed results option THEN the system SHALL navigate to the results review screen
3. WHEN on the results review screen THEN the system SHALL provide a way to return to the main menu or start a new game
4. WHEN the user navigates away from results THEN the system SHALL maintain the results data until a new game begins

### Requirement 4

**User Story:** As a player, I want the results display to be visually clear and easy to understand, so that I can quickly identify my correct and incorrect guesses.

#### Acceptance Criteria

1. WHEN displaying symbols THEN the system SHALL use the same visual representation as used during gameplay
2. WHEN showing turn results THEN the system SHALL clearly separate the user's guess from the correct answer within each cell
3. WHEN indicating correct guesses THEN the system SHALL use a consistent visual highlight (blue border/background)
4. WHEN the screen has limited space THEN the system SHALL display only the symbol icons without text labels
5. WHEN displaying the grid THEN the system SHALL ensure all 25 cells are visible and appropriately sized for the screen
