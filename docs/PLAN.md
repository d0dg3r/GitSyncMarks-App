# Implementation Plan

## Phases Overview

| Phase | Status | Duration |
|-------|--------|----------|
| 1 – Scaffold | Done | 1 week |
| 2 – GitHub API | Done | 1 week |
| 3 – Local Cache | Done | 3–4 days |
| 4 – Bookmark UI | Done | 1 week |
| 5 – Browser Selection | Pending | 2–3 days |
| 6 – Polish | Done | 3–5 days |

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

## Phase 5: Browser Selection

- [ ] Android: detect installed browsers
- [ ] Settings: pick preferred browser
- [ ] Use `url_launcher` with `LaunchMode.externalApplication`

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

## Next Steps (Immediate)

1. Install Flutter (if not done): `paru -S flutter` or https://docs.flutter.dev/get-started/install
2. Run: `flutter create . --org com.gitsyncmarks` (if android/ and ios/ missing)
3. Run: `flutter pub get` and `flutter run`
4. Phase 3: Add `hive` or `sqflite` for local cache (when ready)
