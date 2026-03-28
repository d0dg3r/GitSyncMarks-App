# PR: Release v0.3.5 (+12)

## Summary

Stable release aligning the companion app with the GitSyncMarks browser extension sync model: **GitHub Git Data API** (atomic commits), **three-way merge**, **sync history** (preview / restore / undo), conflict handling, edit/add/create-folder flows, **generated files**, **multi-format export**, optional **GitHub Repos** and **Linkwarden** virtual tabs, UI density, debug log, What’s New, and sync-on-resume.

## Checklist (maintainer)

- [x] `pubspec.yaml` `0.3.5+12`
- [x] `CHANGELOG.md` entry `0.3.5`
- [x] F-Droid `en-US/changelogs/12.txt`
- [x] F-Droid metadata version fields + dev `Builds` entry for 0.3.5
- [ ] After this PR’s **release commit** merges: on `main`, run `./scripts/finish-release-fdroid-commit.sh --tag`, push branch + tag
- [ ] Wait for **Build & Release** green; `./fdroid/submit-to-gitlab.sh --validate-only`; then submit to GitLab if desired

## F-Droid / tag note

`./fdroid/submit-to-gitlab.sh` requires `git rev-parse v0.3.5` to equal the `commit:` line in `com.d0dg3r.gitsyncmarks-fdroid-submit.yml`. Use `finish-release-fdroid-commit.sh` so that hash targets the **release source** commit (see `docs/skills/gitsyncmarks-app-release/SKILL.md`).

## Docs / skill

- Updated: `README`, `ARCHITECTURE`, `docs/*`, `ROADMAP`, `IMPLEMENTATION_SUMMARY`, `fdroid/README.md`, `docs/RELEASE-CHECKLIST.md`
- **Skill (repeatable workflow):** `docs/skills/gitsyncmarks-app-release/SKILL.md`
