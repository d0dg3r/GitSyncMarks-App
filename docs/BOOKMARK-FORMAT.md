# GitSyncMarks Bookmark Format

This document describes the bookmark structure in the GitHub repo. The [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) browser extension and this app use the same on-disk format. For behaviour details, the extension’s [docs/DATA-FLOW.md](https://github.com/d0dg3r/GitSyncMarks/blob/main/docs/DATA-FLOW.md) is authoritative.

**Interoperability:** The on-disk format is aligned with the extension **3.0.x** (no format change in v3.0 — transport layer only). The app reads and writes the same file layout and merge-ignored paths as the extension. Git hosts: GitHub, GitLab, Gitea, Forgejo, Codeberg, Gogs (see [ARCHITECTURE.md](../ARCHITECTURE.md)).

## Repository Structure

The active bookmark tree under the base path uses **two** synced root role folders, `toolbar` and `other`. Repositories may still contain `menu/` or `mobile/` directories from older tooling; current extension releases do not sync those roots, and **this app only loads and edits `toolbar` and `other`**, matching the extension’s `SYNC_ROLES`.

```
bookmarks/                    # Base path (configurable, default "bookmarks")
  _index.json                 # Metadata: { "version": 2 }
  README.md                   # Optional / auto-generated, ignored in bookmark diffs
  toolbar/                    # Bookmarks Bar (Chrome) / Bookmarks Toolbar (Firefox)
    _order.json
    github_a1b2.json
    stackoverflow_c3d4.json
    dev-tools/                # Subfolder
      _order.json
      mdn-web-docs_e5f6.json
  other/                      # Other Bookmarks (see mapping below)
    _order.json
    ...
  profiles/                   # Settings sync (encrypted); not a bookmark root
    <alias>/
      settings.enc
```

Legacy: `menu/` and `mobile/` as top-level role folders are **not** used by the current extension sync. Do not add new bookmarks there if you rely on extension + app interop; prefer `toolbar` and `other` only.

## Root folder mapping (browser)

| Role | Chrome | Firefox |
|------|--------|---------|
| **toolbar** | Bookmarks Bar | Bookmarks Toolbar |
| **other** | Other Bookmarks | Bookmarks Menu (`menu________`) |

`menu` and `mobile` browser roots are not synced by the current extension; see the extension’s DATA-FLOW for details.

## Bookmark file

Each bookmark is a JSON file:

```json
{
  "title": "GitHub",
  "url": "https://github.com"
}
```

Filename format: `{slug-from-title}_{4-char-hash-from-url}.json` (e.g. `github_a1b2.json`).

## _order.json

Each folder has `_order.json` defining child order:

```json
[
  "github_a1b2.json",
  "stackoverflow_c3d4.json",
  {"dir": "dev-tools", "title": "Dev Tools"}
]
```

- **String:** Bookmark filename
- **Object:** Subfolder with `dir` (folder name) and `title` (display name)

## GitHub Contents API (read)

```
GET /repos/{owner}/{repo}/contents/{path}?ref={branch}
```

Response for directory:

```json
[
  {"name": "_order.json", "type": "file", "content": "base64...", "encoding": "base64"},
  {"name": "github_a1b2.json", "type": "file", "content": "base64...", "encoding": "base64"},
  {"name": "dev-tools", "type": "dir"}
]
```

For `type: "file"`: decode `content` from base64 to get the file body.

## Parsing (conceptual)

1. Fetch the tree or directory listing under `{basePath}/`.
2. Process **only** the `toolbar` and `other` role folders (ignore `menu`/`mobile` for bookmark display in this app).
3. In each folder: read `_order.json`, then resolve bookmark files and subfolders. Orphan subfolders and orphan `.json` files (not in `_order.json`) are included, matching the extension.
4. Skip `profiles/` and generated files for the bookmark tree (see `filterForDiff` in the app and `DIFF_IGNORE_SUFFIXES` in the extension).

## Settings sync files

Settings files are encrypted (`gitsyncmarks-enc:v1`) and extension-compatible.

- Current individual mode path: `profiles/<alias>/settings.enc`
- Global legacy path: `settings.enc`
- Individual legacy path: `settings-<id>.enc`

When both old and new paths exist, prefer `profiles/<alias>/settings.enc`.

`profiles/` is an internal settings-sync directory and must not be treated as a bookmark root folder in the app UI.
