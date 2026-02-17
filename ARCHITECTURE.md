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

- `bookmark.dart`: Bookmark model with JSON serialization
  - Represents both folders and link bookmarks
  - Supports nested hierarchical structure
  - Handles multiple JSON formats

### lib/services/
Contains business logic and external integrations.

- `bookmark_service.dart`: Main service for bookmark operations
  - Fetches bookmarks from GitHub
  - Handles local caching with SharedPreferences
  - Parses multiple bookmark formats
  - Implements offline-first strategy

### lib/screens/
Contains full-screen UI components.

- `bookmarks_screen.dart`: Main screen displaying bookmark tree
  - Manages app state (loading, error, success)
  - Handles user interactions
  - Displays last sync time
  - Provides refresh functionality

### lib/widgets/
Contains reusable UI components.

- Currently contains `BookmarkTile` (inline in bookmarks_screen.dart)
  - Recursive widget for displaying bookmarks
  - Handles both folders and links
  - Uses ExpansionTile for folders
  - Uses ListTile for links

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

The app uses Flutter's built-in `StatefulWidget` for state management.

### State Variables
- `_bookmarks`: List of root bookmarks
- `_isLoading`: Loading state indicator
- `_error`: Error message (if any)
- `_lastSync`: Timestamp of last successful sync

### State Updates
- Initial load on app start
- Manual refresh via button
- Error states with fallback to cache

## Caching Strategy

### Offline-First Approach
1. Check cache first (unless force refresh)
2. Attempt network fetch
3. On success: update cache and UI
4. On failure: fallback to cache if available

### Cache Implementation
- Uses SharedPreferences for persistent storage
- Stores JSON-serialized bookmark data
- Stores last sync timestamp
- No expiration (manual refresh required)

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

## Future Enhancements

Potential improvements while maintaining read-only nature:
- Search functionality
- Bookmark sorting options
- Multiple repository support
- Sync scheduling
- Export bookmarks
- Statistics and analytics
- Dark mode
- Accessibility improvements
