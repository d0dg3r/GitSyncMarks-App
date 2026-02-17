# GitSyncMarks

A cross-platform (iOS + Android) Flutter app for syncing and viewing bookmarks from the GitSyncMarks GitHub repository.

## Features

- ✅ Syncs bookmarks from the GitSyncMarks GitHub repo (read-only)
- ✅ Displays the bookmark tree (toolbar, other, subfolders)
- ✅ Opens URLs in the user-selected browser on tap
- ✅ Caches bookmarks locally for offline use
- ✅ No tab saving – read-only sync and open only

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/d0dg3r/GitSyncMarks-Android.git
   cd GitSyncMarks-Android
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

- The app automatically syncs bookmarks from the GitSyncMarks repository on launch
- Tap the refresh icon to manually sync bookmarks
- Tap on a bookmark to open it in your default browser
- Folders can be expanded/collapsed to view nested bookmarks
- The last sync time is displayed in the app bar

## Architecture

- **Models**: Bookmark data models
- **Services**: Bookmark fetching and caching logic
- **Screens**: UI screens for displaying bookmarks
- **Local Storage**: SharedPreferences for offline caching

## Dependencies

- `http`: For fetching bookmarks from GitHub
- `path_provider`: For local file system access
- `shared_preferences`: For persistent local storage
- `url_launcher`: For opening URLs in external browsers
