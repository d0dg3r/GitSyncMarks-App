# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-beta.1] - 2026-02

### Added

- Local bookmark cache (Hive): Bookmarks saved after sync, loaded from cache on app start
- Multilingual support (i18n): German, English, Spanish, French
- Settings/About/Help as tabs in one screen
- Release workflow: Automatic APK build and GitHub release on tag push (v*)

### Changed

- Compact layout: Bookmark list, Settings, About, Help with reduced spacing
- Improved GitHub error messages on 401 (API message shown)
- Android: `queries` for http/https so links open in external browser
- App icon generated from GitSyncMarks logo (flutter_launcher_icons)

### Dependencies

- hive, hive_flutter, path_provider for local cache
- flutter_localizations (already included)

---

## [0.1.0] - 2026-02

### Added

- Flutter project setup (iOS + Android)
- Bookmark list screen with expandable folder tree
- Settings screen: GitHub Token, Owner, Repo, Branch, Base Path
- Test Connection to validate credentials and discover root folders
- Base folder selection (multi-select: toolbar, menu, mobile, other, etc.)
- Sync bookmarks from GitHub via Contents API
- Open bookmark URLs in external browser (url_launcher)
- Favicons for bookmarks (DuckDuckGo API, cached)
- Pull-to-refresh
- Light and Dark mode (GitSyncMarks branding)
- Empty folders hidden from list
- About screen with links to bookmarks-sync and GitSyncMarks
- Help screen with setup instructions
- App icon (GitSyncMarks logo)

### Dependencies

- flutter, provider, http, url_launcher, flutter_secure_storage, cached_network_image
