# Technology Stack

## Framework & Language

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK ^3.8.0-278.1.beta)
- **Material Design 3**: UI design system with `useMaterial3: true`

## Dependencies

- `cupertino_icons: ^1.0.8` - iOS-style icons
- `vibration: ^2.0.0` - Haptic feedback support
- `supabase_flutter: ^2.8.0` - Supabase authentication and database

## Development Dependencies

- `flutter_test` - Testing framework
- `flutter_lints: ^5.0.0` - Dart/Flutter linting rules

## Build System & Commands

### Development

```bash
# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload during development (r in terminal)
# Hot restart (R in terminal)
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage
```

### Building

```bash
# Build APK for Android
flutter build apk

# Build app bundle for Android
flutter build appbundle

# Build for iOS (requires macOS)
flutter build ios

# Build for web
flutter build web
```

### Analysis & Linting

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .
```

## Architecture Patterns

- **MVC Pattern**: Controllers manage game logic, Views handle UI
- **State Management**: StatefulWidget with setState() for local state
- **Service Layer**: Separate services for cross-cutting concerns (haptic feedback, authentication)
- **Model Classes**: Immutable data classes with copyWith() methods
- **Authentication**: Supabase-based user authentication with email/password
