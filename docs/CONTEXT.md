# Project Context – GitSyncMarks-Mobile

This document captures the context and decisions from when the project was created. Read this when resuming work in a new session.

---

## Origin

**Parent project:** [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) – a browser extension that syncs bookmarks with a GitHub repo. Each bookmark is stored as a JSON file; directory structure mirrors the bookmark tree.

**This app:** Companion mobile app (iOS + Android) for users who want to:
1. View their synced bookmarks on mobile
2. Open links in their preferred browser
3. Move, reorder, add bookmarks (synced to repo)
4. Sync settings encrypted (extension-compatible)

## Decisions Made

| Topic | Decision |
|-------|----------|
| **Platform** | Flutter (iOS + Android from one codebase) |
| **Scope** | Sync, display tree, open in browser; move/reorder/add bookmarks; settings sync |
| **Storage** | GitHub repo (same format as extension); local cache for offline |
| **Browser** | User selects preferred browser; URLs open via `url_launcher` |

## POC Scope (Completed)

- Flutter project in this repo
- Main screen: Bookmark list (empty state with "Configure in Settings")
- Settings screen: Form with Token, Owner, Repo, Branch, Base Path
- Navigation between screens
- No persistence yet, no API calls

## Tech Stack (Planned)

- **HTTP:** `http` or `dio`
- **Token storage:** `flutter_secure_storage`
- **Local cache:** `hive` or `sqflite`
- **URLs:** `url_launcher` with `LaunchMode.externalApplication`
- **State:** `provider` or `riverpod`

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

- **Bookmark list:** Expandable tree (folders + bookmarks)
- **Folder picker:** N/A (we read from repo; no folder selection)
- **Settings:** Token, Owner, Repo, Branch, Base Path, Browser choice (Phase 5)

## Conversation Notes

- User wanted to start with a POC
- Flutter was not installed on dev machine; project structure created manually
- `flutter create .` still needed to generate android/ and ios/ folders
- Related idea (Tab-Profiles) documented in GitSyncMarks repo – separate feature
