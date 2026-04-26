# Roadmap

This document shows where GitSyncMarks-App stands and where it is headed. For implementation details, see [docs/PLAN.md](docs/PLAN.md). For version history, see [CHANGELOG.md](CHANGELOG.md).

**Pre-1.0:** All releases are beta; stability and features may change.

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

### v0.3.1

- Beta testing signup for Play Store; repository rename (GitSyncMarks-Mobile → GitSyncMarks-App); F-Droid metadata fixes (commit hashes, rewritemeta, pre-release filter)

### v0.3.3

- Settings sync alignment with extension profiles path: `profiles/<alias>/settings.enc`
- Client name flow for individual settings sync mode
- Folder browser for selecting repo base path in GitHub settings
- `_index.json` compatibility (`version: 2`) during bookmark write operations
- General settings tab with app language and theme selection
- Full localization across all supported app locales

### v0.3.4

- Android release signing, reproducible container builds, F-Droid submit gates, CI split for APK/AAB

### v0.3.5

- Extension-parity sync: Git Data API, three-way merge, sync history, conflict handling
- Edit / add / create folder, generated files, extra export formats
- GitHub Repos & Linkwarden (optional), UI density, debug log, What’s New, sync on resume

### v0.3.6–0.3.7

- **0.3.6:** Layered `POST /git/trees` uploads (large push efficiency; extension-aligned)
- **0.3.7:** Bookmarks format docs + all locales: only `toolbar` / `other` as synced roots; [EXTENSION-SYNC-VERIFY](docs/EXTENSION-SYNC-VERIFY.md); merge duplicate same-title folders on serialize; golden/screenshot test harness; F-Droid submit & repro tooling fixes

---

## Current (post-v0.3.7)

- **Features:** Git Data API / three-way merge as in v0.3.5+; v0.3.7 documentation and in-app text aligned with extension roots (`toolbar` / `other` only); see [docs/EXTENSION-SYNC-VERIFY.md](docs/EXTENSION-SYNC-VERIFY.md)
- **Platforms:** Android (beta), iOS, Windows, macOS, Linux (alpha)
- **Release:** Stable tags (`vX.Y.Z`); F-Droid metadata `commit:` must reference the release source commit (see `scripts/finish-release-fdroid-commit.sh`)

---

## Near-term (next cycle)

- Per-profile “sync on resume” toggle (global behavior exists today)
- Local notifications / sync snackbar modes (plan item)
- Stability fixes for alpha platforms

---

## Future / Vision

- **F-Droid:** New **fdroiddata** merge request when we retry listing (metadata and scripts already in `fdroid/`; previous MR was closed — see [fdroid/README.md](fdroid/README.md#listing-status-paused))
- **iOS:** TestFlight / IPA distribution
- **Flathub:** Flathub submission for Linux
- Further platform polish (Windows, macOS, Linux to stable)
