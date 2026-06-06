# Project Context – GitSyncMarks-App

This document captures the context and decisions from when the project was created. Read this when resuming work in a new session.

---

## Origin

**Parent project:** [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) – a browser extension that syncs bookmarks with a GitHub repo. Each bookmark is stored as a JSON file; directory structure mirrors the bookmark tree.

**This app:** Cross-platform companion app (Android, iOS, Windows, macOS, Linux) for users who want to:
1. View their synced bookmarks on mobile
2. Open links in their preferred browser
3. Move, reorder, add bookmarks (synced to repo)
4. Sync settings encrypted (extension-compatible)

## Decisions Made

| Topic | Decision |
|-------|----------|
| **Platform** | Flutter (Android, iOS, Windows, macOS, Linux from one codebase) |
| **Scope** | Sync (multi-provider Git API, three-way merge, history), display tree, open in browser; move/reorder/delete/add/edit bookmarks; optional GitHub Repos / Linkwarden virtual folders; generated files; settings sync; encrypted export/import; configurable root folder; auto-lock edit mode; reset all data |
| **Storage** | Git repo on GitHub, GitLab, or Gitea-family host (same on-disk format as extension); local cache for offline |
| **Git providers (v0.4.0)** | GitHub (+ Enterprise), GitLab, Gitea, Forgejo, Codeberg, Gogs — aligned with extension 3.0 `PROVIDER_CAPS` |
| **Browser** | User selects preferred browser; URLs open via `url_launcher` |

## POC Scope (Completed)

- [x] Flutter project in this repo
- [x] Main screen: Bookmark list (empty state with "Configure in Settings")
- [x] Settings screen: Form with Token, Owner, Repo, Branch, Base Path
- [x] Navigation between screens
- [x] `flutter create . --org com.gitsyncmarks` (android/, ios/ generated)

## Tech Stack (Implemented)

- **HTTP:** `http`
- **Token storage:** `flutter_secure_storage`
- **Local cache:** `hive` (BookmarkCacheService)
- **URLs:** `url_launcher` with `LaunchMode.externalApplication`
- **State:** `provider` (BookmarkProvider)
- **Settings sync:** `pointycastle` (PBKDF2, AES-256-GCM, extension-compatible)

## Bookmark Format (from GitSyncMarks)

The repo contains:
- `bookmarks/` (or custom base path)
  - **Synced root folders (extension + app):** `toolbar/` and `other/` only.
  - Legacy or unused top-level roles `menu/`, `mobile/` may exist in old repos; the current browser extension does not sync them, and the app’s parser matches the extension (`syncRoles`).
  - Each folder: `_order.json` (ordering) + `*.json` (one per bookmark)
  - Bookmark JSON: `{ "title": "...", "url": "https://..." }`

**Extension compatibility:** Bookmark layout and diff-ignored files are kept aligned with **GitSyncMarks 3.0.x** (on-disk format unchanged in v3.0). See [BOOKMARK-FORMAT.md](BOOKMARK-FORMAT.md) and [EXTENSION-SYNC-VERIFY.md](EXTENSION-SYNC-VERIFY.md).

## Git provider API (v0.4.0)

**Factory:** `createGitProvider()` in `lib/services/git_provider.dart` — capability map in `lib/config/git_provider_caps.dart`.

| Strategy | Providers | Read | Write |
|----------|-----------|------|-------|
| `tree` | GitHub (+ GHE) | Git tree + blobs | Layered `POST /git/trees` atomic commit |
| `gitlab_commits` | GitLab | Paginated repository tree + raw blobs | `POST /repository/commits` with `actions[]` |
| `contents` | Gitea, Forgejo, Codeberg, Gogs | Contents API directory walk | Per-file Contents API (multiple commits per push) |

Profile fields: `gitProvider`, `serverUrl`, `owner`, `repo`, `branch`, `filePath` (extension-compatible).

## UI Decisions

- **Bookmark list:** Expandable tree (folders + bookmarks), ReorderableListView, move-to-folder (long-press), delete (long-press)
- **Folder picker:** Hierarchical picker for move; root folder tabs for **toolbar** and **other** (synced roots), plus virtual folders when enabled; configurable root folder
- **Settings:** Git provider, optional server URL, Token, Owner, Repo, Branch, Base Path, Browser choice; tabs (Git, Sync, Files, General, Help, About)
- **Edit mode:** Lock/unlock icon in AppBar; auto-locks after 60s inactivity; defaults to locked
- **Export/Import:** Password-protected (AES-256-GCM); desktop uses FilePicker, mobile uses Share
- **Empty state:** Import Settings button when no credentials configured

## Platforms

- **Android:** Beta; primary platform; **F-Droid:** metadata in `fdroid/` is kept for a future listing attempt — the previous fdroiddata MR was **closed**; there is **no** active F-Droid release at the moment (see [fdroid/README.md](../fdroid/README.md#listing-status-paused))
- **iOS, Windows, macOS, Linux:** Alpha; same codebase; Share-Intent only on mobile; desktop uses HomeScreen directly
- **Linux distribution:** Flatpak (recommended) + Arch `*.pkg.tar.zst` (pacman) + ZIP fallback; CI builds all on tag push

Before version 1.0, all platforms are considered beta/alpha; stability and features may change.

## Conversation Notes

- User wanted to start with a POC
- Flutter was not installed on dev machine; project structure created manually
- `flutter create .` done to generate android/ and ios/ folders
- Related idea (Tab-Profiles) documented in GitSyncMarks repo – separate feature
- Android is the primary platform; all others (iOS, Windows, macOS, Linux) are alpha
- Pre-release CI tags (`-beta`, `-rc`, `-test`) build all platforms but mark as pre-release
