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

---

## Phase 1: Scaffold – Done

- [x] Flutter project structure
- [x] Navigation (Settings, Bookmark List)
- [x] Settings UI: Token, Owner, Repo, Branch, Base Path
- [ ] Run `flutter create . --org com.gitsyncmarks` (adds android/, ios/)
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

## Project Structure (Target)

```
lib/
  main.dart
  app.dart
  config/
  models/
    bookmark_node.dart
  services/
    github_api.dart
    sync_service.dart
    storage_service.dart
  repositories/
    bookmark_repository.dart
  screens/
    bookmark_list_screen.dart
    settings_screen.dart
  widgets/
    bookmark_tile.dart
    folder_tile.dart
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

## Future Work

- [ ] **CI Screenshot Automation**: Dedicated workflow step using `Xvfb` + `flutter screenshot --type=device` to auto-generate Flatpak/store screenshots on each release. Removes manual screenshot capture step.
- [ ] iOS build & distribution (TestFlight / IPA)
- [ ] Flathub submission

## Development Quick Start

1. Install Flutter: `paru -S flutter` or https://docs.flutter.dev/get-started/install
2. Run: `flutter pub get && flutter run`
