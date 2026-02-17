# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-16

### Added
- Initial release of GitSyncMarks Flutter app
- Cross-platform support for iOS and Android
- Read-only bookmark syncing from GitSyncMarks GitHub repository
- Bookmark tree display with expandable folders
- URL launching in external browser
- Local caching with SharedPreferences for offline access
- Manual refresh functionality
- Last sync time display
- User-friendly error messages
- Unit tests for models and services
- Widget tests for UI components
- Comprehensive documentation (README, SETUP, CONTRIBUTING)

### Features
- Syncs bookmarks from GitHub repository
- Displays hierarchical bookmark structure
- Supports folders and subfolders
- Opens URLs in user's default browser
- Caches data locally for offline use
- Graceful error handling with fallback to cache
- Material Design 3 UI

### Technical Details
- Built with Flutter 3.0+
- Uses http package for network requests
- Uses shared_preferences for local storage
- Uses url_launcher for opening URLs
- Supports Chrome/Firefox bookmark format
- Parses JSON bookmark data
