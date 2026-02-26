# Roadmap

This document shows where GitSyncMarks-App stands and where it is headed. For implementation details, see [docs/PLAN.md](docs/PLAN.md). For version history, see [CHANGELOG.md](CHANGELOG.md).

---

## Completed

### v0.1.0 – Foundation
- Flutter project (iOS + Android)
- Bookmark list with expandable folder tree
- Settings: GitHub Token, Owner, Repo, Branch, Base Path
- Test Connection, folder selection, sync from GitHub
- Open URLs in external browser, favicons, pull-to-refresh
- Light/Dark mode, i18n, Help, About

### v0.2.0 – Polish & Cache
- Browser selection for opening bookmarks
- Local cache (Hive) – offline-capable
- i18n (DE, EN, ES, FR)
- Settings / About / Help as tabs
- F-Droid metadata
- Release workflow (APK on tag push)

### v0.3.0 – Edit & Sync
- Settings Sync to Git (extension-compatible, Global/Individual mode)
- Move bookmarks to folder (long-press, hierarchical picker)
- Reorder bookmarks (drag-and-drop)
- Share link as bookmark (mobile)
- Recursive folder display
- Flatpak build, CI improvements

### v0.3.0 (stable)
- All of the above plus: password-protected export/import, configurable root folder,
  auto-lock edit mode, delete bookmarks, post-import auto-sync, reset all data,
  import on empty state, golden_toolkit for screenshots, F-Droid screenshots/icon

---

## Current (v0.3.0)

- **Features:** Bookmark sync, move, reorder, delete, add via share; Settings Sync to Git; encrypted export/import; configurable root folder; auto-lock edit mode; reset all data; import on empty state
- **Platforms:** Android (stable), iOS, Windows, macOS, Linux (alpha)
- **Release:** Tag `v*` → APK, Flatpak + ZIP (Linux), ZIP (Windows, macOS); pre-release tags supported

---

## Near-term

- Minor UX improvements
- Stability fixes for alpha platforms
- Documentation updates

---

## Future / Vision

- **iOS:** TestFlight / IPA distribution
- **Flathub:** Flathub submission for Linux
- Further platform polish (Windows, macOS, Linux to stable)
