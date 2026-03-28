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
| [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md) | Mandatory release order, gates, and recovery commands |
| [skills/gitsyncmarks-app-release/SKILL.md](skills/gitsyncmarks-app-release/SKILL.md) | Stable release + F-Droid workflow (copy to Cursor skills if desired) |
| [ARCHITECTURE.md](../ARCHITECTURE.md) | Technical architecture, CI/Release |
| [CHANGELOG.md](../CHANGELOG.md) | Version history |
| [BETA_JOIN.md](../BETA_JOIN.md) | Beta testing signup (Google Play launch) |
| [AGENTS.md](../AGENTS.md) | AI agent guidance (Cursor rules, workflow) |

## Current Status (v0.3.5)

- **Sync:** Git Data API, atomic commits, three-way merge, conflicts (force push/pull), sync history (preview / restore / undo)
- Bookmark move, reorder, delete, add (share + FAB), **edit**, **create folder**
- Generated files (README / HTML / RSS / Dashy), multi-format **export** from the tree
- Optional **GitHub Repos** and **Linkwarden** virtual tabs; UI density, sync-on-resume, What’s New, debug log
- Settings Sync to Git (extension-compatible, Global/Individual, `profiles/<alias>/settings.enc`)
- Base path folder browser, `_index.json` handling, password-protected settings export/import
- Configurable root folder, auto-lock edit mode, Hive cache, profiles, 12 locales, themes
- **Platforms:** Android (stable), iOS, Windows, macOS, Linux (alpha)
- **Release:** Tag `v*` → artifacts; use `scripts/finish-release-fdroid-commit.sh` after the release commit so F-Droid `commit:` matches the tagged tree (see [skills/gitsyncmarks-app-release/SKILL.md](skills/gitsyncmarks-app-release/SKILL.md))
- **F-Droid:** Metadata + `en-US/changelogs/<versionCode>.txt` per release; `./fdroid/submit-to-gitlab.sh --validate-only` before submit

## Related Repos

- **GitSyncMarks** (mother project, browser extension): https://github.com/d0dg3r/GitSyncMarks  
  - Bookmark format reference; this app uses format like GitSyncMarks  
  - Syncs bookmarks to a GitHub repo; docs: `docs/DATA-FLOW.md`, `docs/IDEAS-FLUTTER-BOOKMARK-APP.md`
