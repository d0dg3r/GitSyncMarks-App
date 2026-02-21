# Architecture Overview

## Application Structure

GitSyncMarks is a Flutter application following a clean architecture pattern with clear separation of concerns.

### Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Screens, Widgets, UI Logic)     │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         Business Logic Layer        │
│        (Services, Use Cases)        │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│          Data Layer                 │
│    (Models, Repositories, Cache)    │
└─────────────────────────────────────┘
```

## Directory Structure

### lib/models/
Contains data models that represent the domain entities.

- `bookmark_node.dart`: BookmarkNode, BookmarkFolder, Bookmark with JSON serialization
  - Represents both folders and link bookmarks
  - Supports nested hierarchical structure
  - GitSyncMarks per-file format
- `profile.dart`: Profile with credentials, sync settings, selected folders

### lib/services/
Contains business logic and external integrations.

- `github_api.dart`: GitHub Contents API client (GET, PUT, DELETE)
- `settings_sync_service.dart`: Encrypted settings push/pull (extension-compatible)
- `settings_crypto.dart`: PBKDF2 + AES-256-GCM (gitsyncmarks-enc:v1)
- `storage_service.dart`: flutter_secure_storage for credentials, profiles, settings sync password
- `bookmark_cache.dart`: Hive-based offline cache

### lib/repositories/
- `bookmark_repository.dart`: Fetches bookmarks, move, reorder, add; orchestrates GitHub API

### lib/screens/
- `bookmark_list_screen.dart`: Main screen with folder tabs, ReorderableListView, move-to-folder
- `settings_screen.dart`: Tabbed Settings (GitHub, Sync, Files, Help, About)

### lib/providers/
- `bookmark_provider.dart`: App state, sync, move, reorder; uses ChangeNotifier

### lib/main.dart
Application entry point.
- Initializes MaterialApp
- Sets up theme (Material Design 3)
- Defines app-level configuration

## Data Flow

### Fetching Bookmarks

```
User Action (Open App/Refresh)
         ↓
BookmarksScreen._loadBookmarks()
         ↓
BookmarkService.fetchBookmarks()
         ↓
┌────────────────────────────┐
│ Check Cache (if not force) │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│   Fetch from GitHub API    │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│     Parse JSON Data        │
└────────────────────────────┘
         ↓
┌────────────────────────────┐
│    Cache Locally           │
└────────────────────────────┘
         ↓
Return List<Bookmark>
         ↓
Update UI State
```

### Opening URLs

```
User Taps Bookmark
         ↓
BookmarkTile.onTap()
         ↓
BookmarksScreen._openUrl()
         ↓
url_launcher.launchUrl()
         ↓
External Browser Opens
```

## State Management

The app uses `provider` with `BookmarkProvider` (ChangeNotifier).

### State (BookmarkProvider)
- `_rootFolders`, `_credentials`, `_profiles`, `_activeProfileId`
- `_lastSyncTime`, `_isLoading`, `_error`
- `_searchQuery`, `_selectedRootFolders`
- Auto-sync timer, sync-on-start

## Caching Strategy

### Offline-First Approach
1. Check cache first (unless force refresh)
2. Attempt network fetch
3. On success: update cache and UI
4. On failure: fallback to cache if available

### Cache Implementation
- Uses Hive for bookmark cache (BookmarkCacheService)
- flutter_secure_storage for credentials, profiles, settings sync password
- Stores last sync timestamp

## Error Handling

### Network Errors
- Connection failures → user-friendly message
- Timeouts → retry suggestion
- 404 errors → file not found message

### Fallback Strategy
- Always attempt to load from cache on error
- Show cached data with error indicator
- Allow manual retry

## Platform Integration

### Android
- Minimum SDK: Configurable via gradle
- Target SDK: Latest stable
- Permissions: Internet access
- Deep linking support for URLs

### iOS
- Minimum iOS version: 11.0+
- URL scheme queries declared
- App Transport Security configured

## Dependencies

### Core Dependencies
- `flutter`: SDK framework
- `http`: Network requests
- `shared_preferences`: Local storage
- `url_launcher`: External browser integration

### Dev Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service method behavior
- Error handling logic

### Widget Tests
- UI component rendering
- User interaction handling
- Loading states

### Integration Tests
- (Future) End-to-end user flows

## Features (v0.3.0)

- Settings Sync to Git (extension-compatible, Global/Individual)
- Move bookmarks to folder (hierarchical picker)
- Reorder bookmarks (drag-and-drop, persisted)
- Share link as bookmark (receive_sharing_intent)
- Recursive folder display
- Search, Export settings, Export bookmarks
