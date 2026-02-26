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

- Tag auf finalen Merge-Commit setzen
- F-Droid `commit:` = Tag-Commit
- Siehe [.cursor/rules/release-workflow.mdc](.cursor/rules/release-workflow.mdc)

## Dokumentation

- [docs/CONTEXT.md](docs/CONTEXT.md) – Origin, Entscheidungen, Scope
- [docs/PLAN.md](docs/PLAN.md) – Phasen, nächste Schritte
- [docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md) – Bookmark-JSON, GitHub API
