---
name: gitsyncmarks-app-release
description: >-
  Stable release workflow for GitSyncMarks-App — version bump, CHANGELOG, F-Droid
  metadata, tagging, GitHub CI, F-Droid submit. Use when preparing vX.Y.Z,
  opening a release PR, or submitting to F-Droid.
---

# GitSyncMarks-App — Stable release workflow

## When to use

- User asks for a **release**, **tag**, **F-Droid update**, or **release PR**
- After a feature freeze for `vX.Y.Z`

## Versioning

- **`pubspec.yaml`:** `version: X.Y.Z+NN` — `NN` is **versionCode** (Android / F-Droid). Increment both for every store release.
- **Git tag:** `vX.Y.Z` (no suffix for stable latest; `-beta` / `-rc` for pre-releases).

## Files to touch (every stable release)

| Area | Files |
|------|--------|
| Version | `pubspec.yaml` |
| User-facing history | `CHANGELOG.md` — add `## [X.Y.Z] - YYYY-MM-DD`, trim `[Unreleased]` to future-only items |
| F-Droid short notes | `fdroid/metadata/com.d0dg3r.gitsyncmarks/en-US/changelogs/{versionCode}.txt` (one line or short paragraph) |
| F-Droid metadata | `fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml` — `versionName`, `versionCode`, `CurrentVersion`, `CurrentVersionCode`, `commit` (see below) |
| F-Droid dev metadata | `fdroid/metadata/com.d0dg3r.gitsyncmarks.yml` — append new **Builds** entry (older builds first), bump `CurrentVersion*` |
| Docs | `README.md`, `ARCHITECTURE.md`, `docs/CONTEXT.md`, `docs/README.md`, `ROADMAP.md`, `IMPLEMENTATION_SUMMARY.md` when behavior or structure changed |
| What’s New | `lib/services/whats_new_service.dart` — add a `WhatsNewEntry` for `version: 'X.Y.Z'` if you show highlights after upgrade |

## Critical: F-Droid `commit:` vs tag

`./fdroid/submit-to-gitlab.sh` requires:

- `CurrentVersion` / `CurrentVersionCode` match `pubspec.yaml`
- Changelog file `en-US/changelogs/{versionCode}.txt` exists
- Tag `vX.Y.Z` exists
- **`git rev-parse vX.Y.Z^{commit}`** (or a **lightweight** tag) **equals the `commit:` line** in `com.d0dg3r.gitsyncmarks-fdroid-submit.yml` — `./fdroid/submit-to-gitlab.sh` peels annotated tags automatically

The **release source tree** must live at that commit. A follow-up commit may only adjust metadata; the **tag should point at the commit that contains `pubspec` + code for X.Y.Z**, while `commit:` in YAML matches that same hash.

### Automated fix (recommended)

From repo root, **after** the main release commit:

```bash
./scripts/finish-release-fdroid-commit.sh        # second commit: patch F-Droid `commit:` fields
./scripts/finish-release-fdroid-commit.sh --tag  # also: git tag vX.Y.Z on the release commit
git push origin main   # or your branch
git push origin vX.Y.Z
```

- The script records `C1 = HEAD` at run time (the **release** commit), then runs `scripts/patch-fdroid-metadata-commits.py`: submit YAML gets its single `commit:` set to `C1`; dev YAML gets **only the last** `commit:` updated (older build blocks keep historical SHAs).
- With `--tag`, it creates an **annotated** tag `v{version from pubspec}` on `C1` (not on the metadata-only follow-up). Submit validation uses the peeled commit, so this matches `commit:`; alternatively use a **lightweight** tag if you prefer `git rev-parse vX.Y.Z` to print the commit hash directly.

If you add more commits **after** the first metadata patch (e.g. Flatpak metainfo), run `./scripts/finish-release-fdroid-commit.sh` again so `commit:` matches the new tip that should be built.

## Order of operations (checklist)

1. **Branch:** e.g. `release/v0.3.5` or work on `main` per team rules.
2. **Edit:** `pubspec`, `CHANGELOG`, F-Droid version fields + changelog file, docs, `whats_new_service.dart` if needed.
3. **Commit:** `chore(release): GitSyncMarks-App vX.Y.Z` (one logical release commit).
4. **Run:** `./scripts/finish-release-fdroid-commit.sh --tag`
5. **Push** branch → open **PR** (if using a branch). The **tag** must target the **same commit** as `commit:` in the submit YAML (the release source commit from step 3 — **before** any extra doc-only commits, unless you re-run the patch script).
6. **CI:** Wait for **Build & Release** green; confirm GitHub Release APK URL exists.
7. **Local proof:** `bash scripts/fdroid-repro-proof.sh`
8. **Validate:** `./fdroid/submit-to-gitlab.sh --validate-only`
9. **F-Droid MR:** `./fdroid/submit-to-gitlab.sh YOUR_GITLAB_USER`

Also read: `docs/RELEASE-CHECKLIST.md`, `fdroid/README.md`, `.cursor/rules/release-workflow.mdc`, `.cursor/rules/fdroid-maintenance.mdc`.

## PR description template

Title: `chore(release): vX.Y.Z`

Body (adapt):

```markdown
## Release vX.Y.Z (+N)

### Summary
- …

### Checklist
- [ ] `pubspec.yaml` / `CHANGELOG.md` / F-Droid changelog `N.txt`
- [ ] `./scripts/finish-release-fdroid-commit.sh` run after release commit; tag on release commit
- [ ] Docs updated (README, ARCHITECTURE, docs/*)
- [ ] After merge: push tag, wait for Build & Release, run `submit-to-gitlab.sh --validate-only`

### F-Droid
Submit metadata `commit:` must equal the tag’s release commit: `git rev-parse vX.Y.Z^{commit}` or a lightweight tag (enforced by submit script).
```

## Screenshots (if UI changed)

Per project rules: run `./scripts/generate-screenshots.sh` (or project’s golden/Flatpak flow) and commit assets **before** tagging if the UI materially changed.

## Do not

- Put pre-release suffixes in `com.d0dg3r.gitsyncmarks-fdroid-submit.yml` (CI fails).
- Add inline YAML comments in F-Droid metadata (rewritemeta).
- Tag before `commit:` in submit YAML matches `git rev-parse vX.Y.Z^{commit}` (or use a lightweight tag).

## Cursor (optional)

To load this as a project skill in Cursor, symlink or copy this file under `.cursor/skills/gitsyncmarks-app-release/SKILL.md` (that path is gitignored here; the canonical doc is this file).
