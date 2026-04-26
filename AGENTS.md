# AI Agent Guidance – GitSyncMarks-App

Kurze Anleitung für AI-Agenten (Cursor, etc.) bei der Arbeit an diesem Projekt.

## Projekt

- **Flutter-App** (Android, iOS, Windows, macOS, Linux) – Sync von Bookmarks aus GitHub-Repo (GitSyncMarks-Format)
- **Android:** Stable | **andere Plattformen:** Alpha
- **Parent:** [GitSyncMarks](https://github.com/d0dg3r/GitSyncMarks) (Browser-Extension)

## Wichtige Regeln

1. **`.cursor/rules/`** lesen – alle MDC-Regeln beachten
2. **Docs, Tests, Architektur, Store-Assets** immer mitsynchronisieren (siehe docs-sync rule)
3. **Keine Co-authored-by** in Commits
4. **Commit nur nach Freigabe** – vorher fragen

## Release

- Ablauf Schritt für Schritt: [docs/skills/gitsyncmarks-app-release/SKILL.md](docs/skills/gitsyncmarks-app-release/SKILL.md) (nach Merge: `./scripts/finish-release-fdroid-commit.sh --tag` falls noch nicht gelaufen)
- Tag auf den **Release-Quell-Commit** (gleicher SHA wie `commit:` in `com.d0dg3r.gitsyncmarks-fdroid-submit.yml`)
- Siehe [.cursor/rules/release-workflow.mdc](.cursor/rules/release-workflow.mdc)
- **F-Droid (Stand):** Kein aktives Listing — früheres fdroiddata-MR gelöscht; Metadaten bleiben für später; Details: [fdroid/README.md](fdroid/README.md#listing-status-paused)

## Dokumentation

- [docs/CONTEXT.md](docs/CONTEXT.md) – Origin, Entscheidungen, Scope
- [docs/PLAN.md](docs/PLAN.md) – Phasen, nächste Schritte
- [docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md) – Bookmark-JSON, GitHub API
