# Contributing to GitSyncMarks-Mobile

Thank you for considering contributing to GitSyncMarks-Mobile!

## Development Setup

1. Install Flutter SDK (3.41.0 or higher; 3.41.1 recommended for CI parity)
2. Clone the repository:
   ```bash
   git clone git@github.com:d0dg3r/GitSyncMarks-Mobile.git
   cd GitSyncMarks-Mobile
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

### Linux
```bash
flutter run -d linux
```

### Windows (Windows host only)
```bash
flutter run -d windows
```

### macOS (macOS host only)
```bash
flutter run -d macos
```

## Generating Screenshots

Screenshots werden lokal generiert (CI-Job ist deaktiviert). Vor jedem Release:

```bash
./scripts/generate-screenshots.sh
git add test/goldens/ flatpak/screenshots/
git commit -m "chore: update screenshots"
```

Oder manuell: `flutter test test/screenshot_test.dart --update-goldens` → `cp test/goldens/*.png flatpak/screenshots/`

Erzeugt: `bookmark-list.png` (Light), `bookmark-list-dark.png` (Dark), `settings-github.png` – für README und Flatpak-Metainfo.

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
├── config/          # Configuration (credentials)
├── models/          # Data models (bookmark_node, profile)
├── services/        # GitHub API, cache, settings sync, storage
├── repositories/    # Bookmark repository (orchestration)
├── providers/       # State management (BookmarkProvider)
├── screens/         # bookmark_list_screen, settings_screen, home_screen
├── utils/           # Favicon, filename helpers
├── widgets/         # Reusable widgets
└── main.dart        # App entry point

test/                # Unit and widget tests
android/             # Android-specific files
ios/                 # iOS-specific files
```

## F-Droid Metadata

When changing app metadata, release notes, or screenshots, update F-Droid metadata in `fdroid/`:

- `fdroid/metadata/com.d0dg3r.gitsyncmarks.yml` — version, build config
- `fdroid/metadata/com.d0dg3r.gitsyncmarks/en-US/changelogs/{versionCode}.txt` — changelog per release
- `fdroid/README.md` — submission instructions

See [fdroid/README.md](fdroid/README.md) for submission workflow.

## Flatpak Test Workflow

To test the Flatpak build without running the full release (Windows, macOS, release job):

- **Manual:** Go to Actions → "Flatpak test" → Run workflow
- **Tag:** Push `v0.3.0-flatpak-test.1` (or any `v*-flatpak-test*` tag)

Downloads only `build-android-linux` and `build-flatpak`. The `.flatpak` artifact is available from the workflow run.

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
