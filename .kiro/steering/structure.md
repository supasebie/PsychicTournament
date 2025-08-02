# Project Structure

## Root Directory

```
psychictournament/
├── lib/                    # Main application source code
├── test/                   # Test files (mirrors lib/ structure)
├── android/                # Android-specific configuration
├── web/                    # Web platform assets
├── pubspec.yaml           # Dependencies and project configuration
├── analysis_options.yaml  # Dart analyzer and linting rules
└── README.md              # Project documentation
```

## Source Code Organization (`lib/`)

### Core Structure

```
lib/
├── main.dart              # App entry point and routing
├── controllers/           # Business logic and game state management
├── models/               # Data models and enums
├── screens/              # Full-screen UI components
├── widgets/              # Reusable UI components
└── services/             # Cross-cutting concerns and utilities
```

### Detailed Breakdown

**Controllers** (`lib/controllers/`)

- `game_controller.dart` - Core game logic, deck management, scoring

**Models** (`lib/models/`)

- `zener_symbol.dart` - Enum with display names, icons, and asset paths
- `game_state.dart` - Immutable game state representation
- `guess_result.dart` - Result data from user guesses

**Screens** (`lib/screens/`)

- `main_menu_screen.dart` - Initial app screen
- `zener_game_screen.dart` - Main game interface

**Widgets** (`lib/widgets/`)

- `card_reveal_widget.dart` - Card display and reveal animations
- `symbol_selection_widget.dart` - Five symbol selection buttons
- `score_display_widget.dart` - Current score presentation
- `feedback_display_widget.dart` - Guess result feedback
- `feedback_overlay_widget.dart` - Full-screen feedback overlay
- `final_score_dialog.dart` - End-game results dialog

**Services** (`lib/services/`)

- `haptic_feedback_service.dart` - Device vibration management

## Testing DO NOT WRITE TESTS

```
Do not write any test methods at this moment. They test methods will be created manually by a developer
```

## Naming Conventions

- **Files**: snake_case (e.g., `zener_game_screen.dart`)
- **Classes**: PascalCase (e.g., `ZenerGameScreen`)
- **Variables/Methods**: camelCase (e.g., `currentScore`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_TURNS`)
- **Private members**: Leading underscore (e.g., `_gameController`)

## Import Organization

1. Dart core libraries
2. Flutter framework imports
3. Third-party package imports
4. Local project imports (relative paths)
