# Contributing to GitSyncMarks

Thank you for considering contributing to GitSyncMarks!

## Development Setup

1. Install Flutter SDK (3.0.0 or higher)
2. Clone the repository:
   ```bash
   git clone https://github.com/d0dg3r/GitSyncMarks-Android.git
   cd GitSyncMarks-Android
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the App

### Android
```bash
flutter run -d android
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### Chrome (for web testing)
```bash
flutter run -d chrome
```

## Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Code Style

This project uses the official Flutter lints. Run the analyzer:
```bash
flutter analyze
```

Format your code before committing:
```bash
dart format .
```

## Project Structure

```
lib/
├── models/          # Data models
├── services/        # Business logic and API services
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── main.dart        # App entry point

test/                # Unit and widget tests
android/             # Android-specific files
ios/                 # iOS-specific files
```

## Adding New Features

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the existing code style

3. Add tests for your changes

4. Run tests and ensure they pass:
   ```bash
   flutter test
   flutter analyze
   ```

5. Commit your changes:
   ```bash
   git commit -m "Add feature: your feature description"
   ```

6. Push to your fork and submit a pull request

## Pull Request Guidelines

- Keep PRs focused on a single feature or fix
- Update documentation if needed
- Ensure all tests pass
- Follow the existing code style
- Add tests for new functionality
- Update the README.md if needed

## Reporting Issues

When reporting issues, please include:
- Flutter version (`flutter --version`)
- Device/OS information
- Steps to reproduce
- Expected vs actual behavior
- Any relevant error messages or logs

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Keep discussions on topic

## Questions?

Feel free to open an issue for any questions about contributing!
