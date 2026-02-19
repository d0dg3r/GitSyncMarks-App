<p align="center">
  <img src="https://raw.githubusercontent.com/d0dg3r/GitSyncMarks/main/icons/icon128.png" alt="GitSyncMarks Logo" width="128" height="128">
</p>

<h1 align="center">GitSyncMarks-Mobile</h1>

<p align="center">
  <a href="https://github.com/d0dg3r/GitSyncMarks-Mobile/releases"><img src="https://img.shields.io/github/v/release/d0dg3r/GitSyncMarks-Mobile" alt="Release"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-Mobile/releases?q=pre"><img src="https://img.shields.io/github/v/release/d0dg3r/GitSyncMarks-Mobile?include_prereleases&label=pre-release&logo=github&style=flat-square" alt="Pre-release"></a>
</p>

<p align="center">
  Mobile app (iOS + Android) that syncs bookmarks from your GitHub repo and opens URLs in your preferred browser.<br>
  Read-only companion to the <a href="https://github.com/d0dg3r/GitSyncMarks">GitSyncMarks</a> browser extension.
</p>

<p align="center">
  <a href="https://f-droid.org/packages/com.d0dg3r.gitsyncmarks"><img src="assets/badges/badge_fdroid.png" alt="Get it on F-Droid" height="50"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-Mobile/releases"><img src="assets/badges/badge_github.png" alt="Get it on GitHub" height="50"></a>
  <a href="http://apps.obtainium.imranr.dev/redirect.html?r=obtainium://add/https://github.com/d0dg3r/GitSyncMarks-Mobile/releases"><img src="assets/badges/badge_obtainium.png" alt="Get it on Obtainium" height="50"></a>
</p>

<p align="center">
  <strong>Why GitSyncMarks-Mobile?</strong> View your <a href="https://github.com/d0dg3r/GitSyncMarks">GitSyncMarks</a> bookmarks on mobile. Uses the same per-file format — bookmarks live in <em>your</em> Git repo. Sync once, browse offline. Works with the browser extension's bookmark structure (toolbar, menu, other, mobile).
</p>

<p align="center">
  <img src="metadata/en-US/images/combinedScreenshots/1_bookmarks_combined.png" alt="Bookmark list – Light &amp; Dark" width="240">
  <img src="metadata/en-US/images/combinedScreenshots/2_empty_state_combined.png" alt="Empty state – Light &amp; Dark" width="240">
  <img src="metadata/en-US/images/combinedScreenshots/3_settings_combined.png" alt="Settings – Light &amp; Dark" width="240">
</p>

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## Features

- **Sync from GitHub**: Bookmarks from your GitSyncMarks-compatible repository via Contents API
- **Local cache**: Bookmarks saved after sync, loaded from cache on app start (offline-capable)
- **GitHub Personal Access Token**: Secure authentication with `repo` scope
- **Folder selection**: Choose which root folders to display (toolbar, menu, mobile, other)
- **Favicons**: Via DuckDuckGo API
- **Pull-to-refresh**: Manual sync when you need it
- **Light and Dark mode**: Follows system theme (GitSyncMarks branding)
- **i18n**: German, English, Spanish, French
- **Settings | About | Help**: All in one tabbed screen

## Installation

1. Go to the [Releases page](https://github.com/d0dg3r/GitSyncMarks-Mobile/releases)
2. Download `GitSyncMarks-Mobile-X.X.X.apk` (or a pre-release build for testing)
3. Open the file on your Android device (allow from unknown sources if prompted)
4. Install the app

### Configure the app

1. Open the app and go to **Settings** (first tab)
2. Enter your **Personal Access Token** (create one at [GitHub Settings > Tokens](https://github.com/settings/tokens/new?scopes=repo&description=GitSyncMarks+Sync) with `repo` scope)
3. Enter **Repository Owner** and **Repository Name** (your bookmark repo)
4. Set **Branch** (usually `main`) and **Base Path** (default `bookmarks` — must match your [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) extension config)
5. Select which folders to display (toolbar, menu, other, mobile)
6. Click **Test Connection** to verify, then **Save**
7. Use **Sync Bookmarks** to fetch your bookmarks

## Project References

The bookmark format comes from [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks). Your repo should use folders like `toolbar`, `menu`, `other`, `mobile` with JSON files per bookmark. This app is read-only — for bidirectional sync, use the [browser extension](https://github.com/d0dg3r/GitSyncMarks).

## Prerequisites (Development)

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2.0 or later)

## Setup (Development)

1. **Install Flutter**:
   ```bash
   # Arch Linux / CachyOS
   paru -S flutter
   # or: https://docs.flutter.dev/get-started/install
   ```

2. **Get dependencies**:
   ```bash
   cd GitSyncMarks-Mobile
   flutter pub get
   ```

3. **Run on device/emulator**:
   ```bash
   flutter run -d android
   ```

4. **Regenerate screenshots** (optional):
   ```bash
   flutter test --update-goldens test/screenshot_test.dart
   ```

## Releases

Releases are built automatically on tag push (`v*`). Example:

```bash
git tag v0.2.0-beta.5
git push origin v0.2.0-beta.5
```

The APK appears under [Releases](https://github.com/d0dg3r/GitSyncMarks-Mobile/releases).

## Roadmap

- [ ] iOS app (planned for a future release)

## Documentation

- **[docs/README.md](docs/README.md)** — Project context and continuation guide
- **[docs/PLAN.md](docs/PLAN.md)** — Implementation phases
- **[docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md)** — Bookmark JSON structure
- **[store/README.md](store/README.md)** — App store submission (descriptions, screenshots)
- **[CHANGELOG.md](CHANGELOG.md)** — Version history

## License

[MIT](LICENSE)
