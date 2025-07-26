# Implementation Plan

- [x] 1. Create MainMenuScreen widget with basic structure

  - Create `lib/screens/main_menu_screen.dart` file with StatelessWidget class
  - Implement basic Scaffold structure with AppBar and body
  - Add placeholder content for title and buttons
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Implement main menu UI components and styling

  - [x] 2.1 Create header section with app title and subtitle

    - Add "Psychic Tournament" title with prominent styling
    - Add "Test Your Psychic Abilities" subtitle
    - Apply consistent theming with existing app color scheme
    - _Requirements: 1.2, 4.1, 4.4_

  - [x] 2.2 Create navigation buttons with proper styling

    - Implement "Zener Cards" primary button with icon and descriptive text
    - Implement "Coming Soon" secondary button with disabled styling
    - Apply Material Design 3 button styling consistent with app theme
    - Add proper spacing and visual hierarchy between buttons
    - _Requirements: 2.1, 3.1, 4.1, 4.2_

  - [x] 2.3 Implement responsive layout for different screen sizes
    - Create responsive button layout (vertical for mobile, horizontal for larger screens)
    - Implement proper spacing and sizing for different screen dimensions
    - Ensure buttons are accessible and properly sized on all devices
    - _Requirements: 4.3_

- [x] 3. Add navigation functionality to MainMenuScreen

  - [x] 3.1 Implement navigation to ZenerGameScreen

    - Add onPressed handler for "Zener Cards" button
    - Implement Navigator.push to navigate to ZenerGameScreen
    - Add error handling for navigation failures
    - _Requirements: 2.2, 2.3_

  - [x] 3.2 Implement coming soon dialog functionality
    - Create dialog widget for placeholder "Coming Soon" message
    - Add onPressed handler for secondary button to show dialog
    - Implement dialog dismissal and return to main menu
    - _Requirements: 3.2, 3.3_

- [x] 4. Update main.dart to use MainMenuScreen as home

  - Modify MaterialApp home property to use MainMenuScreen instead of ZenerGameScreen
  - Add named routes configuration for better navigation management
  - Maintain existing theme configuration and app structure
  - _Requirements: 1.1_

- [ ] 5. Modify ZenerGameScreen for navigation support

  - [ ] 5.1 Add navigation parameter to ZenerGameScreen constructor

    - Add optional showBackButton parameter to control back navigation
    - Update constructor to accept navigation configuration
    - Maintain backward compatibility with existing functionality
    - _Requirements: 2.4_

  - [ ] 5.2 Update final score dialog with main menu navigation
    - Modify FinalScoreDialog to include "Main Menu" button option
    - Implement navigation back to MainMenuScreen from final score dialog
    - Ensure proper navigation stack management
    - _Requirements: 2.4_

- [ ] 6. Add smooth animations and transitions

  - [ ] 6.1 Implement screen transition animations

    - Add custom page route transitions between MainMenuScreen and ZenerGameScreen
    - Ensure transitions complete within 300ms as per requirements
    - Implement smooth slide or fade transitions
    - _Requirements: 5.1, 5.2_

  - [ ] 6.2 Add button interaction animations
    - Implement scale and color animations for button press states
    - Add hover effects for buttons where appropriate
    - Ensure animations are smooth and responsive
    - _Requirements: 5.1_

- [ ] 7. Create comprehensive unit tests for MainMenuScreen

  - [ ] 7.1 Test MainMenuScreen widget rendering

    - Write tests for proper widget tree structure
    - Test button rendering and styling
    - Test responsive layout behavior across screen sizes
    - _Requirements: 1.1, 1.2, 1.3, 4.3_

  - [ ] 7.2 Test navigation functionality
    - Write tests for Zener Cards button navigation
    - Test coming soon dialog functionality
    - Test error handling for navigation failures
    - _Requirements: 2.2, 3.2, 5.4_

- [ ] 8. Create integration tests for navigation flow

  - Write integration tests for complete navigation flow from main menu to game and back
  - Test app lifecycle navigation behavior
  - Test navigation with different screen orientations and sizes
  - _Requirements: 2.2, 2.3, 2.4, 5.3_

- [ ] 9. Implement accessibility features

  - Add semantic labels for all interactive elements
  - Implement proper focus management for navigation
  - Add keyboard navigation support for buttons
  - Test screen reader compatibility
  - _Requirements: 1.3, 4.2_

- [ ] 10. Add error handling and edge case management
  - Implement debounce mechanism for button double-tap prevention
  - Add proper Android back button handling
  - Implement graceful error recovery for navigation failures
  - Add logging for navigation events and errors
  - _Requirements: 5.4_
