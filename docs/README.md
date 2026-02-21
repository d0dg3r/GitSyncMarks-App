# GitSyncMarks-Mobile Documentation

**Start here when resuming work** – especially in a new IDE session or new Cursor window.

When opening this project fresh: read CONTEXT.md and PLAN.md first so you have full project history and next steps.

## Quick Links

| Document | Purpose |
|----------|---------|
| [CONTEXT.md](CONTEXT.md) | Full project context, decisions, origin – read first |
| [PLAN.md](PLAN.md) | Implementation plan, phases, next steps |
| [BOOKMARK-FORMAT.md](BOOKMARK-FORMAT.md) | GitSyncMarks repo structure (JSON format, API) |

## Current Status (v0.3.0)

- Bookmark sync, move, reorder, add via share
- Settings Sync to Git (extension-compatible, Global/Individual mode)
- Local cache (Hive), Profiles, multi-root-folder selection
- i18n (DE/EN/ES/FR), Dark Mode, Favicons
- Release workflow: APK build on tag push (v*)
- Android + iOS

## Related Repos

- **GitSyncMarks** (mother project, browser extension): https://github.com/d0dg3r/GitSyncMarks  
  - Bookmark format reference; this app uses format like GitSyncMarks  
  - Syncs bookmarks to a GitHub repo; docs: `docs/DATA-FLOW.md`, `docs/IDEAS-FLUTTER-BOOKMARK-APP.md`
