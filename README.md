# GitSyncMarks-Android

Mobile app (iOS + Android) that syncs bookmarks from your GitHub repo and opens URLs in your preferred browser. Read-only companion to the [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) browser extension.

**Documentation:** See [docs/README.md](docs/README.md) – start there when resuming work.

## Features

- Sync bookmarks from a GitHub repo (format like GitSyncMarks)
- Local cache: Bookmarks saved after sync, loaded from cache on app start (offline-capable)
- GitHub Personal Access Token authentication
- Select which root folders to display (toolbar, menu, mobile, other, etc.)
- Favicons for bookmarks (via DuckDuckGo)
- Pull-to-refresh
- Light and Dark mode (follows system)
- i18n: German, English, Spanish, French
- About, Help, Settings as tabs

## Project References

The bookmark format comes from [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks). Your bookmark repo should follow this format (folders like `toolbar`, `menu`, `other` with JSON files per bookmark).

This project was developed with [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) as reference – the browser extension for bidirectional bookmark sync.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2.0 or later)

## Setup

1. **Install Flutter** (if not already installed):
   ```bash
   # Arch Linux / CachyOS
   paru -S flutter
   # or: https://docs.flutter.dev/get-started/install
   ```

2. **Create platform folders** (required first time):
   ```bash
   cd GitSyncMarks-Android
   flutter create . --org com.gitsyncmarks
   ```

3. **Get dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run on device/emulator**:
   ```bash
   flutter run
   ```

   For Android:
   ```bash
   flutter run -d android
   ```

## Project Structure

```
lib/
  main.dart              # Entry point
  app.dart               # MaterialApp, theme, routes
  config/
  models/
  repositories/
  screens/
    bookmark_list_screen.dart   # Main screen
    settings_screen.dart        # Settings | About | Help (tabbed)
  services/
  utils/
```

## Releases

Releases are built automatically on tag push (`v*`). Example:

```bash
git tag v0.2.0-beta.1
git push origin v0.2.0-beta.1
```

The APK appears under [Releases](https://github.com/d0dg3r/GitSyncMarks-Android/releases).

## License

MIT – see [LICENSE](LICENSE).
