# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Release types:** Tags without suffix (e.g. `v0.3.0`) create stable releases marked as "latest". Tags with suffix (e.g. `v0.3.0-beta.1`, `v0.3.0-rc.1`, `v0.3.0-test.1`) create pre-releases; all platforms are built in both cases.

## [Unreleased]

### Added

- **Beta testing signup:** README banner and [BETA_JOIN.md](BETA_JOIN.md) for Google Play Store launch; Issue template for structured signups
- **Play Store preparation:** AAB build, upload key signing (`android/key.properties`), CI support via GitHub secrets; see [store/README.md](store/README.md)
- **Cursor MDC rules:** release-workflow, platform-gotchas; extended docs-sync, release-checklist, fdroid-maintenance, project-context
- **AGENTS.md:** Central AI agent guidance for Cursor sessions

### Changed

- **Repository rename:** GitSyncMarks-Mobile → GitSyncMarks-App (https://github.com/d0dg3r/GitSyncMarks-App)

---

## [0.3.0] - 2026-02-21

### Added

- **Settings Sync to Git** (extension-compatible): Encrypted settings sync (global/individual mode), Push/Pull, Import from other device
- **Move bookmarks to folder**: Long-press on bookmark → "In Ordner verschieben" with hierarchical folder picker (including subfolders)
- **Reorder bookmarks**: Drag-and-drop to reorder in root folders and subfolders; changes persisted to `_order.json`
- **Share link as bookmark**: Receive shared URLs (e.g. from Chrome) and add as bookmark
- **Recursive folder display**: Subfolders and nested bookmarks now displayed correctly
- **Password-protected export/import**: Settings export encrypted with AES-256-GCM; import prompts for password when encrypted file detected
- **Configurable root folder**: Select any folder as "root" for tab navigation; its subfolders become tabs
- **Auto-lock edit mode**: Edit mode (reorder/move) auto-locks after 60 seconds of inactivity; any edit action resets the timer
- **Delete bookmarks**: Long-press on any bookmark to delete (available even when edit mode is locked)
- **Post-import auto-sync**: After importing settings, bookmarks sync automatically if credentials are valid
- **Reset all data**: Button in About tab to clear all profiles, settings, and cached data
- **Import on empty state**: "Import Settings" button shown when no credentials are configured
- **Default profile creation**: Default profile is automatically created on first launch or when saving credentials
- **Pre-release CI tags**: Tags with `-beta`, `-rc`, `-test` etc. build all platforms but create pre-releases instead of latest releases
- **Workflow "Flatpak test":** Isolated Flatpak build via `workflow_dispatch` or tag `v*-flatpak-test*` (no full release)

### Changed

- **Flatpak icon:** Fallback to `flutter_assets/assets/images/app_icon.png` when standard path missing
- Settings Sync UI aligned with Chrome extension: main toggle, sync mode (Global/Individual), Save password, Import from other device
- Status (last sync, bookmark count) moved above search bar
- Removed redundant blue "Sync now" button (Sync icon in AppBar remains)
- Extension-compatible encryption (`gitsyncmarks-enc:v1`) for settings.enc
- Edit mode defaults to locked on every app launch
- Edit mode toggle moved to AppBar (lock/unlock icon)
- Desktop export uses `FilePicker.saveFile()` instead of `Share.shareXFiles()` (Linux/Windows/macOS)
- Golden tests with `golden_toolkit` for proper font rendering in screenshots
- F-Droid metadata with screenshots, icon, changelogs

### Fixed

- **Flatpak CI:** Prepare step finds Linux bundle tar.gz after download-artifact (path fix)
- **Flatpak build:** Tar extraction uses `--no-same-owner`; creation uses `--owner=root --group=root` to avoid ownership errors
- Folder picker for move: Unterordner des Quellordners werden angezeigt (vorher ausgefiltert)
- Infinite height layout error in ReorderableListView
- Debug instrumentation removed
- Profile dropdown overflow in AppBar (Flexible text with ellipsis)
- Infinite sync loop when importing settings (replaceProfiles with triggerSync guard)
- "Bad state: No element" crash when exporting with no profiles
- `allowMoveReorder` now always defaults to false (not persisted)

---

## [0.2.0] - 2026-02-18

### Added

- **Browser selection**: Choose your preferred browser for opening bookmarks
- **Local bookmark cache** (Hive): Bookmarks saved after sync, loaded on app start (offline-capable)
- **Multilingual support** (i18n): German, English, Spanish, French
- **Settings / About / Help** as tabs in one screen
- **F-Droid metadata**: Fastlane structure, build configuration for F-Droid submission
- Release workflow: Automatic APK build and GitHub release on tag push (v*)
- Full app flow with credential storage (flutter_secure_storage)

### Changed

- Flutter upgraded to 3.41.1 (Dart 3.8+)
- Compact layout with reduced spacing
- Improved GitHub error messages on 401 (API message shown)
- Android: `queries` for http/https so links open in external browser
- App icon generated from GitSyncMarks logo (flutter_launcher_icons)
- Android Gradle Plugin upgraded (8.1.0 → 8.9.1), Kotlin 2.1.0

### Fixed

- First start now shows Settings instead of white error screen
- Localization output directory and placeholder types for Flutter 3.29+
- Flutter 3.29 compatibility (CardThemeData, withOpacity deprecations)

---

## [0.1.0] - 2026-02

### Added

- Flutter project setup (iOS + Android)
- Bookmark list screen with expandable folder tree
- Settings screen: GitHub Token, Owner, Repo, Branch, Base Path
- Test Connection to validate credentials and discover root folders
- Base folder selection (multi-select: toolbar, menu, mobile, other, etc.)
- Sync bookmarks from GitHub via Contents API
- Open bookmark URLs in external browser (url_launcher)
- Favicons for bookmarks (DuckDuckGo API, cached)
- Pull-to-refresh
- Light and Dark mode (GitSyncMarks branding)
- Empty folders hidden from list
- About screen with links to bookmarks-sync and GitSyncMarks
- Help screen with setup instructions
- App icon (GitSyncMarks logo)

### Dependencies

- flutter, provider, http, url_launcher, flutter_secure_storage, cached_network_image
