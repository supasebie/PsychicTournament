# Product Overview

**Psychic Tournament** is a Flutter mobile application that implements a digital version of the Zener card ESP (extrasensory perception) test. The app presents users with a series of 25 cards containing one of five Zener symbols (circle, cross, waves, square, star) and challenges them to guess the correct symbol using their psychic abilities.

## Core Features

- **Zener Card Game**: 25-turn game with 5 cards of each symbol type
- **Remote Viewing Coordinates**: Randomly generated alphanumeric coordinates (XXXX-XXXX format) for each game session
- **Real-time Feedback**: Immediate visual and haptic feedback for correct/incorrect guesses
- **Score Tracking**: Live score display with final results dialog
- **Debug Mode**: Developer tool showing next 3 cards in sequence

## Game Flow

1. User sees remote viewing coordinates and current turn/score
2. User selects one of five Zener symbols
3. Card is revealed with immediate feedback ("Hit!" or "Miss")
4. Score updates and advances to next turn
5. After 25 turns, final score is displayed with option to play again

## Target Platforms

- Primary: Mobile (iOS/Android via Flutter)
- Secondary: Web support available
