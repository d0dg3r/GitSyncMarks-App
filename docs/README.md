# GitSyncMarks-App Documentation

**Start here when resuming work** – especially in a new IDE session or new Cursor window.

When opening this project fresh: read CONTEXT.md and PLAN.md first so you have full project history and next steps.

## Quick Links

| Document | Purpose |
|----------|---------|
| [CONTEXT.md](CONTEXT.md) | Full project context, decisions, origin – read first |
| [PLAN.md](PLAN.md) | Implementation plan, phases, next steps |
| [ROADMAP.md](../ROADMAP.md) | Milestones, current status, future vision |
| [BOOKMARK-FORMAT.md](BOOKMARK-FORMAT.md) | GitSyncMarks repo structure (JSON format, API) |
| [ARCHITECTURE.md](../ARCHITECTURE.md) | Technical architecture, CI/Release |
| [CHANGELOG.md](../CHANGELOG.md) | Version history |
| [BETA_JOIN.md](../BETA_JOIN.md) | Beta testing signup (Google Play launch) |
| [AGENTS.md](../AGENTS.md) | AI agent guidance (Cursor rules, workflow) |

## Current Status (v0.3.0)

- Bookmark sync, move, reorder, delete, add via share
- Settings Sync to Git (extension-compatible, Global/Individual mode)
- Password-protected export/import of settings
- Configurable root folder for tab-based navigation
- Auto-lock edit mode (60s inactivity timer)
- Post-import auto-sync, reset all data
- Local cache (Hive), Profiles, multi-root-folder selection
- i18n (DE/EN/ES/FR), Dark Mode, Favicons
- **Platforms:** Android (stable), iOS, Windows, macOS, Linux (all alpha)
- **Release workflow:** Tag `v*` → APK, Flatpak + ZIP (Linux), ZIP (Windows, macOS); pre-release tags supported
- **Flatpak test workflow:** `workflow_dispatch` or tag `v*-flatpak-test*` for isolated Flatpak build
- **CI screenshots:** Golden tests auto-generate screenshots; `flatpak/screenshots/` is source of truth
- **F-Droid:** Metadata in `fdroid/`; update changelogs and metadata with each release

## Related Repos

- **GitSyncMarks** (mother project, browser extension): https://github.com/d0dg3r/GitSyncMarks  
  - Bookmark format reference; this app uses format like GitSyncMarks  
  - Syncs bookmarks to a GitHub repo; docs: `docs/DATA-FLOW.md`, `docs/IDEAS-FLUTTER-BOOKMARK-APP.md`
