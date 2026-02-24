# GitSyncMarks Repository Setup

This document explains how to set up the GitSyncMarks repository that this app syncs from.

## Bookmark Format

The app uses the **GitSyncMarks per-file format**: each bookmark is a JSON file; folders contain `_order.json` for child order. Root folders are `toolbar`, `menu`, `other`, `mobile` (Chrome/Firefox equivalents).

See **[docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md)** for the full specification (structure, bookmark JSON, `_order.json`, filename format).

## Configuring the App

Repository access is configured in **Settings** (first tab):

- **Personal Access Token** – GitHub PAT with `repo` scope
- **Owner** – GitHub username or org
- **Repository Name** – your bookmark repo
- **Branch** – usually `main`
- **Base Path** – default `bookmarks` (must match your [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) extension config)

No code changes required. Use **Test Connection** to verify access, then **Save**.

## Creating Your Bookmark Repository

1. Create a repository on GitHub (e.g. `my-bookmarks`)
2. Create the base path folder (e.g. `bookmarks/`)
3. Add root folders: `toolbar/`, `menu/`, `other/`, `mobile/`
4. Add `_order.json` in each folder
5. Add bookmark JSON files per [BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md)

For bidirectional sync and browser integration, use the [GitSyncMarks browser extension](https://github.com/d0dg3r/GitSyncMarks) to export/manage bookmarks.

## Settings Sync

The app can sync settings (profiles, credentials) to your GitHub repo, encrypted and compatible with the GitSyncMarks browser extension:

1. Go to **Settings → Sync** tab
2. Enable **Sync Settings to Git**
3. Set a **Sync Password** (used for AES-256-GCM encryption)
4. Choose **Sync Mode**: Global (one config for all devices) or Individual (per-device)
5. Click **Save** — settings are pushed to `gitsyncmarks-settings/` in your repo

## Export / Import Settings

Settings can be exported and imported as files, optionally password-protected:

- **Export**: Settings → Files tab → Export Settings. You can set a password for encryption (AES-256-GCM).
- **Import**: Settings → Files tab → Import Settings. If the file is encrypted, you'll be prompted for the password.
- On first launch with no credentials, an **Import Settings** button is shown on the main screen.
- After import, the app automatically syncs bookmarks if valid credentials are found.

## Reset All Data

To start fresh: Settings → About tab → **Reset all data**. This clears all profiles, settings, and cached bookmarks.

## Security Considerations

- Use a GitHub PAT with minimal scope (`repo` for private repos)
- Do not include sensitive information in bookmark URLs or titles
- Credentials are stored via `flutter_secure_storage`
- Settings sync uses AES-256-GCM encryption (`gitsyncmarks-enc:v1` format, compatible with browser extension)
- Bookmarks are cached locally (Hive) for offline access
