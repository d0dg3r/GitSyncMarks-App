# Verifying extension ↔ app sync (manual checklist)

Use this after GitSyncMarks (browser extension) or GitSyncMarks-App changes that touch repo layout, merge rules, or Git provider API behaviour. **Target: extension 3.0.x** and the app version in `pubspec.yaml` on `develop/3.0` / `main`.

## Verification log

| Date | App | Extension | Automated | Manual bidirectional |
|------|-----|-----------|-----------|----------------------|
| 2026-06-29 | `develop/3.0` (pre-0.4.0) | 3.0.4 | `test/extension_interop_test.dart` — provider caps, diff ignores, settings.enc pattern, port normalization, repo prefixes | Pending user run on live repos |

Run automated parity: `flutter test test/extension_interop_test.dart`

## Prerequisites

- A disposable Git repo on your chosen provider (GitHub, GitLab, Codeberg, etc.), or a copy you can reset.
- [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) **v3.0+** installed in a browser (Chromium or Firefox, matching your usual setup).
- GitSyncMarks-App with a profile using the **same** `gitProvider`, `serverUrl` (if any), owner, repo, branch, and base path as the extension profile.

## Bidirectional interop

1. **Extension → app**
   - In the extension: add a few bookmarks and at least one subfolder under both **toolbar** and **other**; run sync to the remote.
   - In the app: sync (pull). Confirm the tree, titles, and URLs match. Open a few links.
2. **App → extension**
   - In the app: add a bookmark, move an item, or create a subfolder; sync to the remote.
   - In the extension: pull / sync. Confirm the changes appear in the expected browser folders (toolbar / other per platform mapping).
3. **Conflicts (optional)**
   - With two clients offline, change different files, then sync both. Confirm the three-way merge or conflict path matches expectations (no silent loss of `toolbar` / `other` data).

## Generated and settings files

- `README.md`, `bookmarks.html`, `feed.xml`, `dashy-conf.yml`, `_index.json` are **ignored in bookmark diffs** in both projects; they should not cause spurious merge conflicts.
- `profiles/<alias>/settings.enc` and legacy `settings*.enc` are ignored for **bookmark** merge; use the dedicated settings sync or import flow to validate encrypted settings, not the main bookmark tree.

## Multi-provider (v0.4.0)

Repeat bidirectional interop for at least:

- **GitHub** (default profile, no `serverUrl`)
- **GitLab** subgroup path if used (`owner` = `group/subgroup`)
- **Codeberg** or self-hosted **Gitea** — git tree + blob reads with Contents API fallback; git-data atomic commit with Contents fallback on write; custom port; repo-scoped token

## If something diverges

- Compare app `PROVIDER_CAPS` in `lib/config/git_provider_caps.dart` with extension `lib/git-provider-common.js`.
- Compare app `diffIgnoreSuffixes` / `settingsEncPattern` in `lib/services/remote_fetch.dart` with extension `DIFF_IGNORE_SUFFIXES` and `SETTINGS_ENC_PATTERN` in `lib/sync-settings.js`.
- Compare root roles: extension `SYNC_ROLES` in `lib/bookmark-serializer.js` and app `syncRoles` in `lib/services/bookmark_parser.dart` (expected: `toolbar`, `other` only).
