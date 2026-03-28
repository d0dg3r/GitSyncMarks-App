# Release Checklist (GitHub + F-Droid)

Use this checklist for every stable release.

## Stable release flow

1. Finalize release content on `main`
   - `pubspec.yaml` version is final (e.g. `0.3.5+12`)
   - `CHANGELOG.md` has matching release entry (`0.3.5`)
   - F-Droid changelog file exists: `fdroid/metadata/com.d0dg3r.gitsyncmarks/en-US/changelogs/<versionCode>.txt`
   - After the **release commit**, run `./scripts/finish-release-fdroid-commit.sh` (optional `--tag`) so F-Droid `commit:` fields match the **release** commit (see `docs/skills/gitsyncmarks-app-release/SKILL.md`)
   - Runtime version propagation is verified:
     - `android/app/build.gradle` uses `flutter.versionCode` / `flutter.versionName`
     - platform plist files use `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`

### Mandatory version/tag sync gate (do not skip)

Run this gate before creating any release tag:

```bash
rg "^version:" pubspec.yaml
rg "versionCode = flutter.versionCode|versionName = flutter.versionName" android/app/build.gradle
rg "^\\s*- versionName:|^\\s*versionCode:|^CurrentVersion:|^CurrentVersionCode:|^\\s*commit:\\s" fdroid/metadata/com.d0dg3r.gitsyncmarks*.yml
```

All values must point to the same target release (`X.Y.Z` / build number) and the same target source commit.

### Pre-tag validation gate (same commit)

1. Run `Build & Release` manually with `build_scope=android-only`.
1. Confirm run is green and note `headSha`:

```bash
gh run view <run_id> --json status,conclusion,headSha,jobs
```

1. Download `release-android` artifact and compare `libapp.so` hash with local container build output:

```bash
gh run download <run_id> -n release-android -D /tmp/gh-android-proof
bash scripts/fdroid-repro-proof.sh || true
unzip -p build/fdroid-proof/local-app-release.apk lib/arm64-v8a/libapp.so | sha256sum
unzip -p /tmp/gh-android-proof/GitSyncMarks-App-main.apk lib/arm64-v8a/libapp.so | sha256sum
```

The hashes must match before tagging. (`fdroid-repro-proof.sh` may fail with 404 pre-tag because GitHub release binary does not exist yet; use the local APK it produced for the hash compare.)

1. Verify F-Droid submit metadata
   - `CurrentVersion` and `CurrentVersionCode` match `pubspec.yaml`
   - `AllowedAPKSigningKeys` is set
   - current build block contains `binary:`
   - `UpdateCheckMode: Tags ^v[0-9.]+$`
   - `Builds[0].commit` equals `git rev-parse vX.Y.Z`
   - `binary:` URL resolves to the APK from `vX.Y.Z`

2. Tag final merge commit

```bash
git checkout main
git pull
git tag vX.Y.Z
git push origin vX.Y.Z
```

- Verify tag hash vs submit metadata commit

```bash
git rev-parse vX.Y.Z
rg "^\\s*commit:\\s" fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml
```

Both hashes must be identical before submitting to F-Droid.

- Wait for GitHub `Build & Release` workflow to pass
  - includes Android signing checks and APK signer fingerprint verification
  - this run must complete first; `F-Droid Validate` is chained after successful release completion

- Wait for GitHub `F-Droid Validate` workflow to pass
  - auto-triggered after successful `Build & Release` completion
  - fails fast if the upstream release APK URL is not reachable yet
  - manual fallback remains available via `workflow_dispatch`

- Submit to F-Droid via script

```bash
./fdroid/submit-to-gitlab.sh YOUR_GITLAB_USER
```

The script enforces release gates and writes a proof file to `fdroid/proofs/`.

## Recovery flow for wrong release target

If you detect a wrong target after preparation:

```bash
git checkout main
git pull
git rev-parse HEAD
```

Do not recycle an existing release tag. Create a new version tag (for example `vX.Y.(Z+1)`), then update submit metadata `commit:` and `binary:` to that new immutable tag and re-run:

```bash
./fdroid/submit-to-gitlab.sh --validate-only
./fdroid/submit-to-gitlab.sh YOUR_GITLAB_USER
```
