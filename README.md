![GitSyncMarks](store/banner_logo.png)

<p align="center">
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases/latest"><img src="https://img.shields.io/github/v/release/d0dg3r/GitSyncMarks-App?style=flat-square&label=Stable&color=blue" alt="Stable Release"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases"><img src="https://img.shields.io/github/v/release/d0dg3r/GitSyncMarks-App?include_prereleases&sort=semver&style=flat-square&label=Beta&color=orange" alt="Beta Release"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases"><img src="https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Android"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases"><img src="https://img.shields.io/badge/Windows-0078D4?style=flat-square&logo=windows&logoColor=white" alt="Windows"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases"><img src="https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS"></a>
  <a href="https://github.com/d0dg3r/GitSyncMarks-App/releases"><img src="https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black" alt="Linux"></a>
  <a href="https://github.com/sponsors/d0dg3r"><img src="https://img.shields.io/badge/Sponsor-EA4AAA?style=flat-square&logo=githubsponsors&logoColor=white" alt="Sponsor"></a>
</p>

**Status:** In active development. Before version 1.0, the app is considered beta; all platforms are maintained on a best-effort basis.

Cross-platform app (Android, iOS, Windows, macOS, Linux) that syncs bookmarks from your GitHub repo and opens URLs in your preferred browser.  
Companion to the [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) browser extension. Uses the **GitHub Git Data API** for atomic commits (aligned with the extension), three-way merge sync, optional GitHub Repos / Linkwarden virtual folders, move, reorder, add, edit, and encrypted settings sync.



**Why GitSyncMarks-App?** View your [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) bookmarks on mobile. Uses the same per-file format — bookmarks live in *your* Git repo. Sync once, browse offline. Works with the browser extension's bookmark structure (toolbar, menu, other, mobile).



See [CHANGELOG.md](CHANGELOG.md) for version history and [ROADMAP.md](ROADMAP.md) for milestones and future plans.

## Features

- **Sync from GitHub**: GitSyncMarks-compatible repo via **Git Data API** (atomic commits), with three-way merge, conflict resolution (force push / pull), and sync history (preview, restore, undo)
- **Settings Sync to Git**: Encrypted sync (extension-compatible), individual mode with client-name based `profiles/<alias>/settings.enc`, import from other device
- **Move bookmarks**: Long-press to move bookmarks to any folder (including subfolders)
- **Reorder bookmarks**: Drag-and-drop to reorder; changes persisted to repo
- **Delete bookmarks**: Long-press to delete (available even when edit mode is locked)
- **Share link as bookmark** (Android/iOS): Add shared URLs from browser or other apps as bookmarks; FAB / dialog to add bookmarks and create folders on all platforms
- **Edit bookmarks**: Long-press → edit title and URL (atomic commit to repo)
- **Generated files**: Optional README.md, Netscape HTML, RSS, Dashy YAML (Off / Manual / Auto) committed with “Generate now”
- **GitHub Repos / Linkwarden** (optional): Virtual tabs from your GitHub account or Linkwarden collections (profile toggles in Sync settings)
- **Export**: JSON plus HTML, RSS, Dashy YAML, Markdown from the current tree (Settings → Files)
- **UI density & diagnostics**: S/M/L list density, sync on resume, What’s New after updates, debug log (About)
- **Password-protected export/import**: Export settings with AES-256-GCM encryption; import detects encrypted files and prompts for password
- **Configurable root folder**: Select any folder as "root" for tab navigation
- **Auto-lock edit mode**: Edit mode auto-locks after 60 seconds of inactivity
- **Reset all data**: Clear all profiles, settings, and cached data from the About tab
- **Local cache**: Bookmarks saved after sync, loaded from cache on app start (offline-capable)
- **GitHub Personal Access Token**: Secure authentication with `repo` scope
- **Folder selection**: Choose which root folders to display (toolbar, menu, mobile, other)
- **Base path folder browser**: Browse repository folders when selecting the Git sync path
- **Favicons**: Via DuckDuckGo API
- **Pull-to-refresh**: Manual sync when you need it
- **Theme mode**: Select `System`, `Light`, or `Dark` in `Settings > General` (GitSyncMarks branding)
- **i18n**: 12 extension-parity languages (`en`, `de`, `fr`, `es`, `pt_BR`, `it`, `ja`, `zh_CN`, `ko`, `ru`, `tr`, `pl`) with `System` or manual selection in Settings > General
- **Settings | About | Help**: All in one tabbed screen

## Beta testing (Google Play)

We're looking for beta testers before the public Google Play Store launch.



## Installation

### Android

1. Go to the [Releases page](https://github.com/d0dg3r/GitSyncMarks-App/releases)
2. Download `GitSyncMarks-App-X.X.X.apk` (or a pre-release build for testing)
3. Open the file on your Android device (allow from unknown sources if prompted)
4. Install the app

#### Android update compatibility (important)

- Android updates without uninstall require the **same app ID and same signing certificate**.
- This project uses a single release signing identity for GitHub release APKs and Play upload artifacts.
- F-Droid cross-channel updates are configured via upstream-signed APK verification (`AllowedAPKSigningKeys` + `Builds.binary` in F-Droid metadata).
- Local `debug` builds are signed with a different key by design, so `debug` -> `release` upgrades can fail and require uninstall.

### Linux (Flatpak, recommended)

1. Download `GitSyncMarks-App-vX.X.X.flatpak` from [Releases](https://github.com/d0dg3r/GitSyncMarks-App/releases)
2. Install:
  ```bash
   flatpak install --user ./GitSyncMarks-App-vX.X.X.flatpak
  ```
3. Run:
  ```bash
   flatpak run io.github.d0dg3r.GitSyncMarksApp
  ```

### Linux (ZIP fallback)

1. Download `GitSyncMarks-App-X.X.X-linux-x64.zip` from [Releases](https://github.com/d0dg3r/GitSyncMarks-App/releases)
2. Extract and run:
  ```bash
   unzip GitSyncMarks-App-X.X.X-linux-x64.zip -d GitSyncMarks-App
   cd GitSyncMarks-App
   ./gitsyncmarks_app
  ```

### Windows / macOS

Download the respective `.zip` from [Releases](https://github.com/d0dg3r/GitSyncMarks-App/releases), extract, and run the executable.

### Configure the app

1. Open the app and go to **Settings** (first tab)
2. Enter your **Personal Access Token** (create one at [GitHub Settings > Tokens](https://github.com/settings/tokens/new?scopes=repo&description=GitSyncMarks+Sync) with `repo` scope)
3. Enter **Repository Owner** and **Repository Name** (your bookmark repo)
4. Set **Branch** (usually `main`) and **Base Path** (default `bookmarks` — must match your [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) extension config). Use the folder button to browse repo directories.
5. In **GitHub > Folders**, select root/display folders to show (toolbar, menu, other, mobile)
6. In **Sync**, choose a sync profile. If you select **Custom**, set your own interval in minutes.
7. Click **Test Connection** to verify, then **Save**
8. Use **Sync Bookmarks** to fetch your bookmarks (the status line also shows the synced commit hash)

## Project References

The bookmark format comes from [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks). Your repo should use folders like `toolbar`, `menu`, `other`, `mobile` with JSON files per bookmark. The app supports moving, reordering, and adding bookmarks. Settings can be synced encrypted (extension-compatible). For full bidirectional sync, use the [browser extension](https://github.com/d0dg3r/GitSyncMarks).

## Prerequisites (Development)

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41.0 or later)

## Setup (Development)

1. **Install Flutter**:
  ```bash
   # Arch Linux / CachyOS
   paru -S flutter
   # or: https://docs.flutter.dev/get-started/install
  ```
2. **Get dependencies**:
  ```bash
   cd GitSyncMarks-App
   flutter pub get
  ```
3. **Run on device/emulator**:
  ```bash
   flutter run -d android
   flutter run -d linux      # Linux desktop
   flutter run -d windows    # Windows (on Windows host)
   flutter run -d macos     # macOS (on macOS host)
  ```
4. **Build standalone executable** (no Flutter runtime needed):
  ```bash
   flutter build linux      # → build/linux/x64/release/bundle/
   flutter build windows    # → build/windows/x64/runner/Release/ (Windows host only)
   flutter build macos     # → build/macos/Build/Products/Release/ (macOS host only)
  ```
5. **Regenerate screenshots** (optional, vor Release):
  ```bash
   ./scripts/generate-screenshots.sh
  ```

## Releases

Releases are built automatically on tag push (`v*`). All tags trigger builds for all platforms.

Use the mandatory release runbook and gate checks in [docs/RELEASE-CHECKLIST.md](docs/RELEASE-CHECKLIST.md) for stable releases and tag recovery.

```bash
# Stable release (marked as "latest")
git tag v0.3.0 && git push origin v0.3.0

# Pre-release (visible under Releases, but not marked as "latest")
git tag v0.3.0-beta.1 && git push origin v0.3.0-beta.1
```

**Tag convention:**

- `v1.2.3` — stable release, marked as "latest"
- `v1.2.3-beta.1`, `v1.2.3-rc.1`, `v1.2.3-test.1` — pre-release (any tag with `-` suffix)

Artifacts appear under [Releases](https://github.com/d0dg3r/GitSyncMarks-App/releases): APK (Android), Flatpak + ZIP (Linux), ZIP (Windows, macOS).

Release safety checks now enforce Android signing consistency:

- Tagged releases fail early if Android signing secrets are missing
- APK and AAB are built after signing setup from the same key configuration
- CI verifies the APK certificate fingerprint against the configured keystore

### Flatpak-only test

To test the Flatpak build without running the full release workflow (Windows, macOS, release job):

- **Manual**: Go to Actions → "Flatpak test" → Run workflow
- **Tag**: Push `v0.3.0-flatpak-test.1` (or any `v*-flatpak-test`* tag)

This runs only `build-android-linux` and `build-flatpak`. The `.flatpak` artifact can be downloaded from the workflow run.

## Platform Status


| Platform | Status     | Notes                                                             |
| -------- | ---------- | ----------------------------------------------------------------- |
| Android  | **Beta**   | Primary platform, actively developed                              |
| Windows  | Alpha      | Built from same codebase, developed as time permits               |
| Linux    | Alpha      | Flatpak + ZIP; developed as time permits                          |
| macOS    | Alpha      | Built from same codebase, developed as time permits               |
| iOS      | Alpha      | Built from same codebase; no CI build yet (requires macOS runner) |


Android is the main focus. All other platforms share the same Flutter codebase and are maintained on a best-effort basis -- contributions welcome!

## Documentation

- **[docs/README.md](docs/README.md)** — Project context and continuation guide
- **[docs/PLAN.md](docs/PLAN.md)** — Implementation phases
- **[docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md)** — Bookmark JSON structure
- **[docs/RELEASE-CHECKLIST.md](docs/RELEASE-CHECKLIST.md)** — Stable release sequence, verification gates, and recovery flow
- **[store/README.md](store/README.md)** — App store submission (descriptions, screenshots)
- **[CHANGELOG.md](CHANGELOG.md)** — Version history
- **[ROADMAP.md](ROADMAP.md)** — Milestones and future plans

## License

[MIT](LICENSE)

---

## Support the Project

If you find **GitSyncMarks-App** helpful, consider supporting its development:

- **[Sponsor on GitHub](https://github.com/sponsors/d0dg3r)**: Directly support the developer.
- **Star the Repository**: Help others discover the project.
- **[Contribute](CONTRIBUTING.md)**: Submit bug reports, feature ideas, or pull requests.