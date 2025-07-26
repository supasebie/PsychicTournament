# Design Document

## Overview

This design document outlines the implementation of a main menu navigation system for the Psychic Tournament application. The main menu will serve as the central hub for accessing different game modes, starting with the existing Zener card game and providing a foundation for future game modes.

The design maintains consistency with the existing app's Material Design 3 theme, deep purple color scheme, and mystical aesthetic while introducing a clean, intuitive navigation structure.

## Architecture

### Current Architecture Analysis

The current app structure follows a simple single-screen approach:

- `main.dart` directly launches `ZenerGameScreen`
- Uses Material Design 3 with deep purple color scheme
- Follows Flutter best practices with StatefulWidget pattern

### Proposed Architecture Changes

The new architecture will introduce a navigation layer:

```
PsychicTournament (MaterialApp)
├── MainMenuScreen (new) - Entry point
│   ├── Navigate to ZenerGameScreen
│   └── Navigate to Future Game Modes
└── ZenerGameScreen (existing) - Modified for navigation
```

### Navigation Flow

1. App launches → MainMenuScreen
2. User selects "Zener Cards" → Navigate to ZenerGameScreen
3. Game completes → Option to return to MainMenuScreen
4. User selects "Coming Soon" → Show placeholder dialog

## Components and Interfaces

### 1. MainMenuScreen Widget

**Purpose**: Primary navigation hub for the application

**Key Features**:

- Displays app title prominently
- Two main navigation buttons
- Consistent theming with existing app
- Responsive layout for different screen sizes
- Smooth animations and transitions

**Interface**:

```dart
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementation details
  }

  void _navigateToZenerGame(BuildContext context) {
    // Navigation logic
  }

  void _showComingSoonDialog(BuildContext context) {
    // Placeholder dialog
  }
}
```

### 2. Navigation Updates to ZenerGameScreen

**Modifications Required**:

- Add navigation back to main menu from final score dialog
- Maintain all existing game functionality
- Update app bar to include back navigation when appropriate

**Interface Changes**:

```dart
class ZenerGameScreen extends StatefulWidget {
  final bool showBackButton; // New parameter
  const ZenerGameScreen({super.key, this.showBackButton = true});
}
```

### 3. Updated Main App Structure

**Changes to main.dart**:

- Change home route from `ZenerGameScreen` to `MainMenuScreen`
- Add named routes for better navigation management
- Maintain existing theme configuration

## Data Models

### Navigation State

No complex data models are required for this feature. Navigation will use Flutter's built-in navigation system with simple route management.

### Route Configuration

```dart
// Named routes for better navigation management
static const String mainMenuRoute = '/';
static const String zenerGameRoute = '/zener-game';
```

## User Interface Design

### Main Menu Layout

**Visual Hierarchy**:

1. **Header Section** (Top 30%)

   - App title: "Psychic Tournament"
   - Subtitle: "Test Your Psychic Abilities"
   - Mystical background gradient

2. **Navigation Section** (Middle 40%)

   - Primary button: "Zener Cards" (prominent, themed)
   - Secondary button: "Coming Soon" (subtle, disabled style)
   - Buttons with icons and descriptive text

3. **Footer Section** (Bottom 30%)
   - Version information (subtle)
   - Decorative elements maintaining mystical theme

### Button Design

**Zener Cards Button**:

- Primary color scheme (deep purple)
- Icon: Card or mystical symbol
- Text: "Zener Cards" with subtitle "Test ESP with classic cards"
- Enabled state with hover/press animations

**Coming Soon Button**:

- Secondary/disabled color scheme
- Icon: Clock or lock symbol
- Text: "More Games" with subtitle "Coming Soon"
- Disabled state with appropriate visual feedback

### Responsive Design

- **Mobile Portrait**: Vertical button layout with full-width buttons
- **Mobile Landscape**: Horizontal button layout with side-by-side buttons
- **Tablet/Desktop**: Centered layout with optimal button sizing

### Animation and Transitions

- **Screen Transitions**: Smooth slide transitions between screens
- **Button Interactions**: Scale and color animations on press
- **Loading States**: Subtle loading indicators during navigation

## Error Handling

### Navigation Errors

- **Route Not Found**: Fallback to main menu
- **Navigation Failure**: Show error dialog with retry option
- **Memory Issues**: Graceful degradation with simplified UI

### User Experience Errors

- **Button Double-Tap**: Debounce mechanism to prevent multiple navigations
- **Back Button Handling**: Proper Android back button support
- **App State Recovery**: Restore to main menu on app resume

### Error Recovery Strategies

```dart
// Example error handling for navigation
void _safeNavigate(BuildContext context, String route) {
  try {
    Navigator.pushNamed(context, route);
  } catch (e) {
    // Log error and show user-friendly message
    _showErrorDialog(context, 'Navigation failed. Please try again.');
  }
}
```

## Testing Strategy

### Unit Tests

1. **MainMenuScreen Widget Tests**

   - Button rendering and styling
   - Navigation function calls
   - Responsive layout behavior

2. **Navigation Logic Tests**
   - Route handling
   - Parameter passing
   - Error scenarios

### Integration Tests

1. **Navigation Flow Tests**

   - Main menu → Zener game → Back to main menu
   - Coming soon dialog functionality
   - App lifecycle navigation behavior

2. **User Experience Tests**
   - Button interaction responsiveness
   - Animation smoothness
   - Screen transition timing

### Accessibility Tests

1. **Screen Reader Support**

   - Proper semantic labels for all interactive elements
   - Navigation announcements
   - Focus management

2. **Keyboard Navigation**
   - Tab order for buttons
   - Enter/Space key activation
   - Escape key for dialog dismissal

### Performance Tests

1. **Navigation Performance**

   - Screen transition timing (target: <300ms)
   - Memory usage during navigation
   - Animation frame rate consistency

2. **Responsive Design Tests**
   - Layout behavior across screen sizes
   - Button sizing and spacing
   - Text readability at different scales

## Implementation Considerations

### Code Organization

- Create new `screens/main_menu_screen.dart`
- Update `main.dart` for route configuration
- Modify `screens/zener_game_screen.dart` for navigation support
- Maintain existing widget structure and patterns

### Theme Consistency

- Use existing `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- Maintain Material Design 3 components
- Consistent typography and spacing
- Preserve mystical/psychic aesthetic

### Performance Optimization

- Lazy loading of game screens
- Efficient widget rebuilding
- Minimal memory footprint for navigation
- Smooth 60fps animations

### Future Extensibility

- Modular button system for easy addition of new game modes
- Configurable navigation structure
- Plugin architecture for game mode registration
- Consistent navigation patterns for all future screens

## Security Considerations

### Navigation Security

- Validate route parameters
- Prevent unauthorized navigation
- Secure handling of navigation state

### User Data Protection

- No sensitive data stored in navigation state
- Proper cleanup of navigation history
- Secure transition between screens

This design provides a solid foundation for the main menu navigation system while maintaining the existing app's quality and user experience standards.
