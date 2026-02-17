# GitSyncMarks Repository Setup

This document explains how to set up the GitSyncMarks repository that this app will sync from.

## Bookmark File Format

The app expects a JSON file at:
```
https://raw.githubusercontent.com/d0dg3r/GitSyncMarks/main/bookmarks.json
```

### Supported Format

The app supports Chrome/Firefox bookmark export format with the following structure:

```json
{
  "roots": {
    "bookmark_bar": {
      "id": "1",
      "name": "Bookmarks bar",
      "type": "folder",
      "children": [
        {
          "id": "2",
          "name": "Google",
          "type": "url",
          "url": "https://www.google.com"
        },
        {
          "id": "3",
          "name": "Development",
          "type": "folder",
          "children": [
            {
              "id": "4",
              "name": "GitHub",
              "type": "url",
              "url": "https://github.com"
            }
          ]
        }
      ]
    },
    "other": {
      "id": "5",
      "name": "Other bookmarks",
      "type": "folder",
      "children": []
    }
  }
}
```

### Field Descriptions

- `id`: Unique identifier for the bookmark (required)
- `name` or `title`: Display name of the bookmark (required)
- `type`: Either "folder" or "url" (required)
- `url` or `uri`: The URL to open (required for type "url")
- `children`: Array of child bookmarks (for folders)

### Alternative Formats

The app also supports simplified formats:

#### Simple Array
```json
[
  {
    "id": "1",
    "title": "Google",
    "type": "link",
    "url": "https://www.google.com"
  },
  {
    "id": "2",
    "title": "Development",
    "type": "folder",
    "children": []
  }
]
```

## Creating Your GitSyncMarks Repository

1. Create a new repository named `GitSyncMarks` on GitHub
2. Create a file named `bookmarks.json` in the root directory
3. Add your bookmarks in one of the supported formats above
4. Commit and push the file

## Exporting Bookmarks from Browsers

### Chrome/Chromium
1. Open Chrome
2. Press `Ctrl+Shift+O` (or `Cmd+Shift+O` on Mac) to open Bookmark Manager
3. Click the three dots menu and select "Export bookmarks"
4. Save the HTML file
5. Use an online converter or script to convert HTML to JSON format

### Firefox
1. Open Firefox
2. Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on Mac) to open Library
3. Click "Import and Backup" → "Export Bookmarks to HTML"
4. Convert the HTML file to JSON format

## Updating the Repository URL

If you want to use a different repository, update the URL in:
`lib/services/bookmark_service.dart`

```dart
static const String bookmarksUrl = 
    'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/bookmarks.json';
```

## Security Considerations

- The repository should be public for the app to access it without authentication
- Do not include sensitive information in bookmark URLs or names
- The app only performs read operations - it cannot modify your bookmarks
- All data is cached locally using SharedPreferences for offline access
