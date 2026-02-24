# Implementation Plan

## Phases Overview

| Phase | Status | Duration |
|-------|--------|----------|
| 1 – Scaffold | Done | 1 week |
| 2 – GitHub API | Done | 1 week |
| 3 – Local Cache | Done | 3–4 days |
| 4 – Bookmark UI | Done | 1 week |
| 5 – Browser Selection | Done | 2–3 days |
| 6 – Polish | Done | 3–5 days |
| 7 – Flatpak/CI | Done | 1 week |
| 8 – Edit Features | Done | 1 week |
| 9 – Export/Import & UX | Done | 3–4 days |

---

## Phase 1: Scaffold – Done

- [x] Flutter project structure
- [x] Navigation (Settings, Bookmark List)
- [x] Settings UI: Token, Owner, Repo, Branch, Base Path
- [x] Run `flutter create . --org com.gitsyncmarks` (adds android/, ios/)
- [x] Add `flutter_secure_storage` for token

---

## Phase 2: GitHub Integration – Done

- [x] `lib/services/github_api.dart`: Contents API client
- [x] Recursive walk: fetch folder contents, decode base64 for files
- [x] `lib/models/bookmark_node.dart`: BookmarkNode, BookmarkFolder, Bookmark
- [x] Parse `_order.json` and bookmark JSON
- [x] `lib/repositories/bookmark_repository.dart`: orchestrate sync
- [x] Wire Settings form → save credentials (secure storage)
- [x] "Test Connection" button → validate token + repo access

---

## Phase 3: Local Cache

- [x] Add `hive` or `sqflite`
- [x] Persist bookmark tree after sync
- [x] Load from cache on app start (offline)
- [x] Pull-to-refresh on Bookmark List screen

---

## Phase 4: Bookmark UI

- [x] Expandable tree widget (folders + bookmarks)
- [x] `BookmarkTile`: tap opens URL via `url_launcher`
- [x] Empty state, loading state, error state

---

## Phase 5: Browser Selection – Done

- [x] Android: detect installed browsers
- [x] Settings: pick preferred browser
- [x] Use `url_launcher` with `LaunchMode.externalApplication`

---

## Phase 6: Polish

- [x] Error handling (401, 403, network)
- [x] Loading indicators
- [x] Dark mode (follows system)
- [x] i18n (DE, EN, ES, FR)

---

## Project Structure

```
lib/
  main.dart
  app.dart
  config/
    github_credentials.dart
  models/
    bookmark_node.dart
    profile.dart
  services/
    github_api.dart
    storage_service.dart
    bookmark_cache.dart
    bookmark_export.dart
    settings_sync_service.dart
    settings_crypto.dart
    settings_import_export.dart
  repositories/
    bookmark_repository.dart
  providers/
    bookmark_provider.dart
  screens/
    home_screen.dart
    bookmark_list_screen.dart
    settings_screen.dart
  utils/
    favicon_url.dart
    filename_helper.dart
  widgets/
    add_bookmark_dialog.dart
  l10n/
    app_en.arb, app_de.arb, app_fr.arb, app_es.arb
```

---

## Desktop Support (Done)

- [x] Windows, macOS, Linux builds from same codebase
- [x] `app.dart`: Share-Intent only on Android/iOS; desktop uses `HomeScreen` directly
- [x] Builds: `flutter build linux`, `flutter build windows` (Windows host), `flutter build macos` (macOS host)

---

## Phase 7: Flatpak/CI – Done

- [x] Linux bundle as tar.gz + separate artifact in release workflow
- [x] Flatpak manifest (io.github.d0dg3r.GitSyncMarksMobile)
- [x] `flatpak/build-flatpak.sh`: build script with tar `--no-same-owner`, icon fallback, error handling
- [x] CI job `build-flatpak` in release workflow
- [x] Release job: APK, Flatpak, ZIP (Linux, Windows, macOS) on tag push `v*`
- [x] Workflow "Flatpak test": `workflow_dispatch` or tag `v*-flatpak-test*` for isolated Flatpak build

---

## Phase 8: Edit Features – Done

- [x] Configurable root folder: select any folder as "root" for tab navigation
- [x] Auto-lock edit mode: 60-second inactivity timer, reset on edit action
- [x] Delete bookmarks: long-press to delete (available even in locked mode)
- [x] Default profile creation on first launch
- [x] Pre-release CI tags: `-beta`, `-rc`, `-test` etc. build all platforms, marked as pre-release

---

## Phase 9: Export/Import & UX – Done

- [x] Password-protected settings export (AES-256-GCM)
- [x] Import detects encrypted files and prompts for password
- [x] Post-import auto-sync (sync triggered after successful import)
- [x] Import button on empty state (no credentials configured)
- [x] Reset all data button (About tab, confirmation dialog)
- [x] Desktop export via `FilePicker.saveFile()` (Linux/Windows/macOS)
- [x] CI screenshot generation via golden tests (`matchesGoldenFile`)
- [x] Flatpak metainfo with auto-generated screenshots

---

## Future Work

- [ ] iOS build & distribution (TestFlight / IPA)
- [ ] Flathub submission
- [ ] F-Droid store: keep metadata and changelogs in sync with each release (see `fdroid/`)

## Development Quick Start

1. Install Flutter (3.41+): `paru -S flutter` or https://docs.flutter.dev/get-started/install
2. Run: `flutter pub get && flutter run`
3. Generate screenshots: `flutter test test/screenshot_test.dart --update-goldens`
