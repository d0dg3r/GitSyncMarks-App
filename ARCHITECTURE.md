# Architecture Overview

## Application Structure

GitSyncMarks is a Flutter application following a clean architecture pattern with clear separation of concerns.

### Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Screens, Widgets, UI Logic)     │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         Business Logic Layer        │
│        (Services, Use Cases)        │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│          Data Layer                 │
│    (Models, Repositories, Cache)    │
└─────────────────────────────────────┘
```

## Directory Structure

### lib/models/
Contains data models that represent the domain entities.

- `bookmark_node.dart`: BookmarkNode, BookmarkFolder, Bookmark with JSON serialization
  - Represents both folders and link bookmarks
  - Supports nested hierarchical structure
  - GitSyncMarks per-file format
- `profile.dart`: Profile with credentials, sync settings, selected folders

### lib/services/
Contains business logic and external integrations.

- `git_data_api.dart`: GitHub Git Data API (refs, commits, trees, blobs, `atomicCommit` with layered tree batching and inline content)
- `remote_fetch.dart`: Recursive tree → SHA map, batched blob fetch, diff filters (generated/settings paths)
- `bookmark_parser.dart`: `BookmarkNode` tree ↔ flat file map (extension-parity filenames)
- `sync_state.dart`: Hive sync base per profile (last commit SHA, file map, previous SHA for undo)
- `sync_diff.dart`: Three-way diff, `_order.json` merge, conflict detection
- `sync_engine.dart`: Orchestrates sync / force pull / force push
- `sync_history.dart`: Commit list, diff preview, restore, undo last sync
- `file_generators.dart`: README, Netscape HTML, RSS, Dashy YAML; `addGeneratedFiles` for commits
- `github_repos_service.dart`: `GET /user/repos` for virtual folder
- `linkwarden_api.dart` / `linkwarden_sync.dart`: Linkwarden REST client and virtual folder tree
- `bookmark_export.dart`: JSON + HTML / RSS / YAML / Markdown export helpers
- `debug_log.dart`: Ring-buffer diagnostic log
- `whats_new_service.dart`: Post-update highlights dialog
- `github_api.dart`: GitHub Contents API (test connection, simple operations where still used)
- `settings_sync_service.dart`: Encrypted settings push/pull (extension-compatible)
- `settings_crypto.dart`: PBKDF2 + AES-256-GCM (gitsyncmarks-enc:v1)
- `storage_service.dart`: flutter_secure_storage for credentials, profiles, settings sync password
- `bookmark_cache.dart`: Hive-based offline cache

### lib/repositories/
- `bookmark_repository.dart`: Fetch via Git Data API + remote map; writes via atomic commits; move/reorder/add/edit/folder ops

### lib/screens/
- `bookmark_list_screen.dart`: Main screen with folder tabs, ReorderableListView, move-to-folder
- `settings_screen.dart`: Tabbed Settings (GitHub, Sync, Files, Help, About)

### lib/providers/
- `bookmark_provider.dart`: App state, sync engine, conflicts, history, GitHub Repos / Linkwarden loaders
- `app_density_controller.dart`: S/M/L UI density (SharedPreferences)

### lib/main.dart
Application entry point.
- Initializes MaterialApp
- Sets up theme (Material Design 3)
- Defines app-level configuration

## Data Flow

### Fetching Bookmarks

```
User Action (Open App/Refresh)
         ↓
BookmarkListScreen via BookmarkProvider
         ↓
BookmarkRepository.fetchBookmarks()
         ↓
┌────────────────────────────┐
│ Check Cache (if not force) │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│   Fetch from GitHub API    │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│     Parse JSON Data        │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│    Cache Locally           │
└────────────────────────────┘
         ↓
Return List<Bookmark>
         ↓
Update UI State
```

### Opening URLs

```
User Taps Bookmark
         ↓
BookmarkTile.onTap()
         ↓
BookmarkListScreen._openUrl()
         ↓
url_launcher.launchUrl()
         ↓
External Browser Opens
```

## State Management

The app uses `provider` with `BookmarkProvider` (ChangeNotifier).

### State (BookmarkProvider)
- `_rootFolders`, `_credentials`, `_profiles`, `_activeProfileId`
- `_lastSyncTime`, `_isLoading`, `_error`
- `_searchQuery`, `_selectedRootFolders`
- `_viewRootFolder` — configurable root folder for tab navigation
- `allowMoveReorder` — edit mode toggle (defaults to false, not persisted)
- Auto-sync timer, sync-on-start, auto-lock timer (60s inactivity)

## Caching Strategy

### Offline-First Approach
1. Check cache first (unless force refresh)
2. Attempt network fetch
3. On success: update cache and UI
4. On failure: fallback to cache if available

### Cache Implementation
- Uses Hive for bookmark cache (BookmarkCacheService)
- flutter_secure_storage for credentials, profiles, settings sync password
- Stores last sync timestamp

## Error Handling

### Network Errors
- Connection failures → user-friendly message
- Timeouts → retry suggestion
- 404 errors → file not found message

### Fallback Strategy
- Always attempt to load from cache on error
- Show cached data with error indicator
- Allow manual retry

## Platform Integration

### Android
- Minimum SDK: Configurable via gradle
- Target SDK: Latest stable
- Permissions: Internet access
- Deep linking support for URLs

### iOS
- Minimum iOS version: 11.0+
- URL scheme queries declared
- App Transport Security configured

## Dependencies

### Core Dependencies
- `flutter`: SDK framework
- `http`: Network requests
- `hive` / `hive_flutter`: Bookmark cache (offline)
- `flutter_secure_storage`: Credentials, profiles, settings sync password
- `provider`: State management (BookmarkProvider)
- `url_launcher`: External browser integration
- `pointycastle`: Settings sync encryption (PBKDF2, AES-256-GCM)
- `receive_sharing_intent`: Share link as bookmark (Android/iOS)
- `file_picker`: Desktop export (save file dialog) and import
- `share_plus`: Mobile export (share sheet)
- `uuid`: Device ID generation for individual settings sync
- `cached_network_image`: Favicon caching
- `package_info_plus`: App version info

### Dev Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## CI / Release

### Release Workflow (`.github/workflows/release.yml`)
- **Trigger:** Tag push `v*` (all tags build; `-beta`/`-rc`/`-test` → pre-release; clean versions → latest)
- **Jobs:** `build-android`, `build-linux`, `build-windows`, `build-macos`, `build-flatpak`, `release` (Screenshots lokal, CI deaktiviert)
- **Artifacts:** APK (Android), AAB (Play Store, when signing secrets set), Flatpak, ZIP, Arch `*.pkg.tar.zst` (Linux), ZIP (Windows, macOS)
- **Android signing:** `android/key.properties` + upload keystore for release builds; CI uses `ANDROID_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` when configured
- **Android reproducibility parity:** `build-android` runs in `registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie` to align toolchain output with F-Droid build infrastructure
- **Linux bundle:** Flutter Linux build packed as tar.gz with `--owner=root --group=root`; [packaging/archlinux/build_pkg.sh](packaging/archlinux/build_pkg.sh) runs in Docker (`archlinux:latest`, `makepkg`) and adds `gitsyncmarks-app-*-x86_64.pkg.tar.zst` to `build/release/`
- **Arch local (developer):** [scripts/build_install_linux_arch_pkg.sh](scripts/build_install_linux_arch_pkg.sh) on an Arch host — `makepkg` from the same `PKGBUILD.prebuilt`, optional `pacman -U` / `--install-z13` (mirrors NoSuckTV)
- **Screenshots:** Lokal mit `flutter test test/screenshot_test.dart --update-goldens`, dann `flatpak/screenshots/` committen

### Flatpak Test Workflow (`.github/workflows/flatpak-test.yml`)
- **Trigger:** `workflow_dispatch` or tag `v*-flatpak-test*`
- **Jobs:** `build-android-linux` → `build-flatpak` only (no Windows, macOS, release job)
- **Purpose:** Test Flatpak build without full release

### Flatpak Build Script (`flatpak/build-flatpak.sh`)
- Tar extraction with `--no-same-owner` (avoids uid/gid errors in build container)
- Icon path fallback: `flutter_assets/assets/images/app_icon.png`
- Error handling when tar.gz is missing

## Testing Strategy

### Widget Tests
- `test/widget_test.dart`: Basic app smoke test
- `test/screenshot_test.dart`: Golden screenshots for Flatpak metainfo (`test/goldens/` → `flatpak/screenshots/`)

### Unit Tests
- (Future) Model serialization, service behavior, error handling

### Integration Tests
- (Future) End-to-end user flows

## Features (v0.3.7 snapshot)

- Git Data API atomic sync, three-way merge, conflict banner, sync history (restore / undo)
- Edit bookmark, FAB add / create folder, generated companion files, multi-format export
- Optional GitHub Repos and Linkwarden virtual tabs; UI density, debug log, What’s New
- Settings Sync to Git (extension-compatible, Global/Individual)
- Move / reorder / delete bookmarks; share intent; search; password-protected settings export/import
- Configurable root folder; auto-lock edit mode; local Hive cache; golden / Flatpak screenshots
