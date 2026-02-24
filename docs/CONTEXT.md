# Project Context – GitSyncMarks-Mobile

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
| **Scope** | Sync, display tree, open in browser; move/reorder/delete/add bookmarks; settings sync; encrypted export/import; configurable root folder; auto-lock edit mode; reset all data |
| **Storage** | GitHub repo (same format as extension); local cache for offline |
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
  - `toolbar/`, `other/`, `menu/`, `mobile/` – root folders
  - Each folder: `_order.json` (ordering) + `*.json` (one per bookmark)
  - Bookmark JSON: `{ "title": "...", "url": "https://..." }`

See [BOOKMARK-FORMAT.md](BOOKMARK-FORMAT.md) for full spec.

## GitHub API

**Contents API (simple):**
```
GET /repos/{owner}/{repo}/contents/{path}?ref={branch}
```
Returns directory listing; files have `content` (base64). Walk recursively.

**Git Data API (efficient for many files):**
```
GET /repos/{owner}/{repo}/git/trees/{treeSha}?recursive=1
GET /repos/{owner}/{repo}/git/blobs/{blobSha}
```

Token: GitHub PAT with `repo` scope.

## UI Decisions

- **Bookmark list:** Expandable tree (folders + bookmarks), ReorderableListView, move-to-folder (long-press), delete (long-press)
- **Folder picker:** Hierarchical picker for move; root folder tabs (toolbar, menu, other, mobile); configurable root folder
- **Settings:** Token, Owner, Repo, Branch, Base Path, Browser choice; 5 tabs (GitHub, Sync, Files, Help, About)
- **Edit mode:** Lock/unlock icon in AppBar; auto-locks after 60s inactivity; defaults to locked
- **Export/Import:** Password-protected (AES-256-GCM); desktop uses FilePicker, mobile uses Share
- **Empty state:** Import Settings button when no credentials configured

## Platforms

- **Android:** Stable; primary platform; F-Droid metadata in `fdroid/`
- **iOS, Windows, macOS, Linux:** Alpha; same codebase; Share-Intent only on mobile; desktop uses HomeScreen directly
- **Linux distribution:** Flatpak (recommended) + ZIP fallback; CI builds both on tag push

## Conversation Notes

- User wanted to start with a POC
- Flutter was not installed on dev machine; project structure created manually
- `flutter create .` done to generate android/ and ios/ folders
- Related idea (Tab-Profiles) documented in GitSyncMarks repo – separate feature
- Android is the primary platform; all others (iOS, Windows, macOS, Linux) are alpha
- Pre-release CI tags (`-beta`, `-rc`, `-test`) build all platforms but mark as pre-release
