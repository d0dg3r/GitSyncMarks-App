# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Release types:** Tags without suffix (e.g. `v0.3.0`) create stable releases marked as "latest". Tags with suffix (e.g. `v0.3.0-beta.1`, `v0.3.0-rc.1`, `v0.3.0-test.1`) create pre-releases; all platforms are built in both cases.

## [Unreleased]

### Documentation

- **F-Droid:** Document that the app is not listed on F-Droid (fdroiddata MR was closed). Metadata in `fdroid/` is retained for a future resubmit. See [fdroid/README.md](fdroid/README.md#listing-status-paused).

## [0.3.7] - 2026-04-26

### Changed

- **GitSyncMarks extension interop (docs + in-app help):** [docs/BOOKMARK-FORMAT.md](docs/BOOKMARK-FORMAT.md) and [docs/CONTEXT.md](docs/CONTEXT.md) state that only **`toolbar` and `other`** are synced roots, with a legacy note for `menu`/`mobile`. New [docs/EXTENSION-SYNC-VERIFY.md](docs/EXTENSION-SYNC-VERIFY.md) checklist. All 14 locales updated.
- **Serialize parity with the extension:** [bookmark_parser.dart](lib/services/bookmark_parser.dart) merges sibling folders that share the same display title in `bookmarkTreeToFileMap`. “Add bookmark” default roots: `toolbar` and `other` only. [test/bookmark_parser_test.dart](test/bookmark_parser_test.dart)
- **Screenshot / golden tests:** [test/screenshot_test.dart](test/screenshot_test.dart) supplies `AppDensityController` and mocks `shared_preferences` and `package_info`. Regenerated [test/goldens/](test/goldens/), [flatpak/screenshots/](flatpak/screenshots/), and F-Droid `en-US/images/phoneScreenshots/`.

### Fixed

- **F-Droid / repro proof:** Parse `flutter-version` from `.github/workflows/release.yml` when the value uses double quotes (matches `release.yml`); F-Droid `prebuild` sed updated. **`./fdroid/submit-to-gitlab.sh`** matches the tag using a peeled ref (`vX.Y.Z^{commit}`) to `commit:` in metadata. [scripts/fdroid-repro-proof.sh](scripts/fdroid-repro-proof.sh) sets `git safe.directory` in the build container.

### Changed (CI / build)

- **Build & Release:** `workflow_dispatch` with `build_scope=android-only` runs only the Android job. `F-Droid Validate` no longer starts on raw metadata events alone; it runs automatically only after successful `Build & Release` (manual `workflow_dispatch` remains). Android job re-runs `flutter pub get` and `flutter gen-l10n` in the `/tmp/build` copy before `flutter build apk --no-pub`. 

## [0.3.6] - 2026-03-28

### Changed

- **Git Data API: layered tree uploads** — `atomicCommit` now embeds file content inline in `POST /git/trees` entries (GitHub creates blobs server-side) instead of issuing one `POST /git/blobs` per file. Large change sets are split into layered tree batches (~400 entries / ~28 MiB each), dramatically reducing API calls (e.g. 5 000 files → ~13 tree POSTs instead of 5 000 blob POSTs) and avoiding secondary rate limits on large first pushes. Aligned with browser extension optimization.

## [0.3.5] - 2026-03-28

### Added

- **Git Data API:** Atomic multi-file commits (blobs, trees, commits, refs) aligned with the browser extension; `GitDataApi`, `RemoteFetch`, and `bookmark_parser` for tree/file-map conversion
- **Three-way merge sync:** `SyncEngine`, `SyncDiff`, `SyncStateService` (Hive) for base/local/remote merge, conflict detection, force push / force pull
- **Sync history:** List commits, diff preview, restore from commit, undo last sync (`SyncHistoryService`, Settings → Files → History)
- **Bookmark editing & folders:** Edit title/URL, FAB add bookmark / create folder; repository uses atomic commits for writes
- **Generated files:** `file_generators.dart` — README.md, Netscape `bookmarks.html`, RSS `feed.xml`, `dashy-conf.yml` with Off / Manual / Auto and “Generate now” in Settings
- **UX:** UI density (S/M/L) via `AppDensityController`, sync on app resume (cooldown), What’s New dialog (`WhatsNewService`), debug log (About)
- **GitHub Repos:** Optional virtual tab listing authenticated user repositories (`github_repos_service.dart`, profile flag)
- **Linkwarden:** Optional API client, virtual collections folder, save-to-Linkwarden helper (`linkwarden_api.dart`, `linkwarden_sync.dart`, profile fields)
- **Export formats:** HTML, RSS, Dashy YAML, Markdown from the bookmark tree (`BookmarkExportService`)
- **Release tooling:** `scripts/finish-release-fdroid-commit.sh` and `scripts/patch-fdroid-metadata-commits.py` to align F-Droid `commit:` with the release source commit (submit file + latest dev build only); repeatable checklist in `docs/skills/gitsyncmarks-app-release/SKILL.md`

### Changed

- **Bookmark list:** Conflict banner when merge conflicts are detected; density-aware list tiles
- **Settings:** Linkwarden and GitHub Repos sections on Sync tab; expanded Export/Import with format buttons
- **Documentation:** `ARCHITECTURE.md`, `README.md`, `docs/CONTEXT.md`, `docs/README.md`, `ROADMAP.md` updated for the new stack

## [0.3.4] - 2026-03-02

### Changed

- **Android release signing policy:** `release` builds now require valid `android/key.properties` and no longer fall back to debug signing
- **Release workflow signing order:** CI now configures Android signing before building APK/AAB and verifies APK signer fingerprint against the configured keystore
- **Release workflow split for reproducibility:** Android build now runs in F-Droid `buildserver-trixie` container (`build-android`), while Linux desktop build runs separately in `build-linux`
- **F-Droid submit strategy:** Metadata now starts from current stable release only and uses upstream APK verification (`Builds.binary` + `AllowedAPKSigningKeys`) for channel-compatible updates
- **Release SOP:** Added mandatory release order and hard stop gates (version/code/tag/hash checks) across GitHub and F-Droid flows
- **F-Droid submit automation:** `submit-to-gitlab.sh` now supports `--validate-only` and writes proof logs under `fdroid/proofs/`
- **Android APK deterministic build parity:** GitHub container APK build now runs `flutter gen-l10n` and builds with `--no-pub` after explicit dependency resolution to mirror F-Droid build sequencing
- **F-Droid submit hard gate:** `fdroid/submit-to-gitlab.sh` now runs `scripts/fdroid-repro-proof.sh` before validation-only and submit flows to block MR updates on `libapp.so` mismatch
- **Reproducible Flutter build path alignment:** GitHub Android container build, F-Droid metadata build steps, and the local proof script now build from `/tmp/build` to avoid absolute-path drift embedded in `libapp.so`

### Fixed

- **F-Droid rewritemeta compliance:** Removed inline comments from app metadata build entries so F-Droid `rewritemeta` formatting check passes for `com.d0dg3r.gitsyncmarks`
- **F-Droid reproducibility preflight:** Added CI validation that checks deterministic submit metadata settings and verifies upstream APK signer fingerprints with uploaded verification logs
- **Release CI keystore path:** Build workflow now writes and verifies the Android upload keystore at `android/upload-keystore.jks` to match Gradle `storeFile` resolution
- **Release CI signer check:** Keystore SHA256 normalization now strips `:` so APK and keytool fingerprints are compared in the same format
- **F-Droid validate parser:** Reproducibility workflow now accepts variant `apksigner` SHA-256 output formats when extracting signer fingerprints
- **Release reproducibility env:** Tagged build jobs now export `SOURCE_DATE_EPOCH` from the tagged commit timestamp to improve deterministic Flutter/Android outputs across CI systems
- **F-Droid build reproducibility env:** Metadata build step now also exports `SOURCE_DATE_EPOCH` from the source commit timestamp so F-Droid and GitHub builds use the same deterministic epoch input
- **Containerized Android CI bootstrap:** Release workflow now installs `jq` in the F-Droid build container before running `subosito/flutter-action`
- **Containerized Flutter extraction prerequisites:** Release workflow now installs `xz-utils` (plus `zip`/`unzip`) so Flutter SDK `.tar.xz` extraction works in the F-Droid build container
- **Containerized Flutter git safety fix:** Android container job now normalizes ownership of `$FLUTTER_ROOT` after setup to avoid `git dubious ownership` failures during `flutter pub get`
- **Containerized Android SDK discovery:** Android container job now auto-detects SDK path (`ANDROID_HOME`/`ANDROID_SDK_ROOT`) in the F-Droid build image before APK build
- **Android container Gradle stability:** Disabled Gradle cache restore in the containerized Android release job to avoid corrupted file-access journal cache failures
- **Android container Gradle home isolation:** Android release job now isolates `GRADLE_USER_HOME` from host/global caches inside the container environment
- **Android container Gradle env pinning:** `GRADLE_USER_HOME` is now exported from `$GITHUB_WORKSPACE` at runtime and `GRADLE_OPTS` disables VFS file watching
- **Android container Gradle journal reset:** Release job now removes `journal-1` and `file-access.bin` artifacts before APK build to prevent bootstrap journal parse crashes
- **Android container Gradle tmp-home:** `GRADLE_USER_HOME` now points to `/tmp/gradle-user-home` to avoid workspace mount side effects on Gradle access-time journal parsing
- **Android container Gradle deep clean:** Release job now also clears project-level Gradle caches (`.gradle`, `android/.gradle`) and enables `org.gradle.daemon=false` for deterministic cold startup
- **Android release debug verbosity:** APK build step now runs with `--verbose` to capture full Gradle diagnostics during CI failure triage
- **Android container locale pinning:** Release job now exports `LANG/LC_ALL/LANGUAGE=en_US.UTF-8` to prevent empty Java `user.country` values that break Gradle file-access journal initialization
- **Android deterministic timestamp fix:** Container prerequisites now include `git`, and `SOURCE_DATE_EPOCH` export now fails fast unless a valid commit timestamp is resolved (prevents empty-value Gradle/Java 21 crashes)
- **Android container workspace ownership:** Release workflow now normalizes `$GITHUB_WORKSPACE` ownership immediately after checkout so git timestamp resolution works without `dubious ownership` failures
- **Split Android release outputs by environment:** APK stays in the F-Droid-compatible container job for reproducibility alignment, while Play Store AAB now builds in a separate Ubuntu job to avoid container symbol-stripping/toolchain incompatibilities
- **F-Droid libapp reproducibility gate in CI:** `F-Droid Validate` now executes `scripts/fdroid-repro-proof.sh` and uploads proof artifacts so `libapp.so` mismatches fail fast before submission
- **F-Droid metadata build env parity:** submit metadata now exports locale and Gradle determinism variables and uses `flutter build ... --no-pub` to reduce native output drift
- **libapp root-cause diagnostics:** Added explicit `diffoscope`-verified evidence of embedded build-path differences (`file:///.../.dart_tool/flutter_build/dart_plugin_registrant.dart`) and aligned workflows to a single deterministic build root

## [0.3.3] - 2026-03-01

### Added

- **Base path folder browser:** GitHub connection now includes a folder browser to select the repository base path instead of typing paths manually
- **Settings sync client name flow:** Individual mode now supports explicit client names and a “Create my client setting” action
- **Custom sync interval input:** Sync profile `Custom` now provides a minutes input (1-1440) with validation
- **Sync profile guidance:** Sync tab now explains what each profile interval means (real-time, frequent, normal, power save, custom)
- **Secret field visibility toggle:** Token and password inputs now include an eye button to show/hide sensitive values on demand
- **App language setting:** Added a new `General` settings tab with app language selection (`System`, `de`, `en`, `es`, `fr`)
- **App theme setting:** Added theme selection in `Settings > General` with `System`, `Light`, and `Dark`
- **Full 12-language localization:** All UI strings translated into all 12 supported languages (`en`, `de`, `fr`, `es`, `pt_BR`, `pt`, `it`, `ja`, `zh_CN`, `zh`, `ko`, `ru`, `tr`, `pl`); Traditional Chinese added as bonus locale

### Changed

- **Settings sync storage path:** Individual mode now writes to `profiles/<alias>/settings.enc` (extension-compatible); legacy `settings.enc` and `settings-*.enc` remain readable
- **Settings sync UX parity:** Import/load/create actions in individual mode are gated by client name and successful actions persist the password for future sync operations
- **Bookmark metadata handling:** Bookmark write operations now ensure `_index.json` exists with `{ "version": 2 }`
- **GitHub settings tabs:** Added dedicated `Folders` subtab under GitHub; root-folder selection and displayed-folder filters were moved out of `Connection`
- **Sync status metadata:** The bookmark status area now shows the short Git commit hash for the last successful sync
- **Settings sync mode migration:** Global mode is now disabled in-app; stored/global mode values are migrated to individual mode while legacy global files remain readable as fallback
- **Settings tab spacing:** Reduced horizontal spacing between tab labels in main and sub-tab menus for a denser layout
- **Settings tab alignment:** Main settings tab row now starts left with a small inset so `GitHub` does not touch the screen edge

### Fixed

- **Profiles folder hidden from bookmarks UI:** Internal settings-sync directory `profiles/` is no longer shown as a bookmark root folder in Test Connection and folder lists
- **Theme setting localization parity:** `Settings > General` theme labels (`System`, `Light`, `Dark`) are now translated in all supported app locales
- **F-Droid:** 0.3.2 build commit in submit metadata now matches v0.3.2 tag (`715e5e2`); was `cecdde3` (wrong commit)
- **F-Droid check apk:** Removed version 0.3.1 (versionCode 8) from build list – APK contained "Dependency metadata" signing block (fix only in 0.3.2); CI now passes

- **Pre-1.0 beta disclaimer:** Add status notice to README, store descriptions (F-Droid, Play Store), Flatpak metainfo, and docs; Android marked as Beta; all platforms best-effort before 1.0
- **Flatpak app ID:** GitSyncMarksMobile → GitSyncMarksApp (`io.github.d0dg3r.GitSyncMarksApp`); existing Flatpak users must uninstall the old app and install the new one
- **F-Droid submit script:** Branch-Update mit Merge (erhält Remote-Änderungen); `--force` für Force-Push; README-Pfad und Build 0.3.1 korrigiert
- **Release workflow:** Fix `secrets` context in `if` conditions (use run-step output instead)
- **F-Droid:** Release workflow documented in fdroid/README.md; metadata uses commit hashes (tags not fetched in F-Droid shallow clone); rewritemeta-compatible (no comments, chronological builds); UpdateCheckMode regex `^v[0-9.]+$` filters pre-releases

## [0.3.2] - 2026-02-26

### Fixed

- **F-Droid check apk:** `dependenciesInfo.includeInApk = false` – verhindert "extra signing block 'Dependency metadata'" im F-Droid CI

---

## [0.3.1] - 2026-02-26

### Added

- **Beta testing signup:** README banner and [BETA_JOIN.md](BETA_JOIN.md) for Google Play Store launch; Issue template for structured signups
- **Play Store preparation:** AAB build, upload key signing (`android/key.properties`), CI support via GitHub secrets; see [store/README.md](store/README.md)
- **Cursor MDC rules:** release-workflow, platform-gotchas; extended docs-sync, release-checklist, fdroid-maintenance, project-context
- **AGENTS.md:** Central AI agent guidance for Cursor sessions

### Changed

- **Repository rename:** GitSyncMarks-Mobile → GitSyncMarks-App (https://github.com/d0dg3r/GitSyncMarks-App)

---

## [0.3.0] - 2026-02-21

### Added

- **Settings Sync to Git** (extension-compatible): Encrypted settings sync (global/individual mode), Push/Pull, Import from other device
- **Move bookmarks to folder**: Long-press on bookmark → "In Ordner verschieben" with hierarchical folder picker (including subfolders)
- **Reorder bookmarks**: Drag-and-drop to reorder in root folders and subfolders; changes persisted to `_order.json`
- **Share link as bookmark**: Receive shared URLs (e.g. from Chrome) and add as bookmark
- **Recursive folder display**: Subfolders and nested bookmarks now displayed correctly
- **Password-protected export/import**: Settings export encrypted with AES-256-GCM; import prompts for password when encrypted file detected
- **Configurable root folder**: Select any folder as "root" for tab navigation; its subfolders become tabs
- **Auto-lock edit mode**: Edit mode (reorder/move) auto-locks after 60 seconds of inactivity; any edit action resets the timer
- **Delete bookmarks**: Long-press on any bookmark to delete (available even when edit mode is locked)
- **Post-import auto-sync**: After importing settings, bookmarks sync automatically if credentials are valid
- **Reset all data**: Button in About tab to clear all profiles, settings, and cached data
- **Import on empty state**: "Import Settings" button shown when no credentials are configured
- **Default profile creation**: Default profile is automatically created on first launch or when saving credentials
- **Pre-release CI tags**: Tags with `-beta`, `-rc`, `-test` etc. build all platforms but create pre-releases instead of latest releases
- **Workflow "Flatpak test":** Isolated Flatpak build via `workflow_dispatch` or tag `v*-flatpak-test*` (no full release)

### Changed

- **Flatpak icon:** Fallback to `flutter_assets/assets/images/app_icon.png` when standard path missing
- Settings Sync UI aligned with Chrome extension: main toggle, sync mode (Global/Individual), Save password, Import from other device
- Status (last sync, bookmark count) moved above search bar
- Removed redundant blue "Sync now" button (Sync icon in AppBar remains)
- Extension-compatible encryption (`gitsyncmarks-enc:v1`) for settings.enc
- Edit mode defaults to locked on every app launch
- Edit mode toggle moved to AppBar (lock/unlock icon)
- Desktop export uses `FilePicker.saveFile()` instead of `Share.shareXFiles()` (Linux/Windows/macOS)
- Golden tests with `golden_toolkit` for proper font rendering in screenshots
- F-Droid metadata with screenshots, icon, changelogs

### Fixed

- **Flatpak CI:** Prepare step finds Linux bundle tar.gz after download-artifact (path fix)
- **Flatpak build:** Tar extraction uses `--no-same-owner`; creation uses `--owner=root --group=root` to avoid ownership errors
- Folder picker for move: Unterordner des Quellordners werden angezeigt (vorher ausgefiltert)
- Infinite height layout error in ReorderableListView
- Debug instrumentation removed
- Profile dropdown overflow in AppBar (Flexible text with ellipsis)
- Infinite sync loop when importing settings (replaceProfiles with triggerSync guard)
- "Bad state: No element" crash when exporting with no profiles
- `allowMoveReorder` now always defaults to false (not persisted)

---

## [0.2.0] - 2026-02-18

### Added

- **Browser selection**: Choose your preferred browser for opening bookmarks
- **Local bookmark cache** (Hive): Bookmarks saved after sync, loaded on app start (offline-capable)
- **Multilingual support** (i18n): German, English, Spanish, French
- **Settings / About / Help** as tabs in one screen
- **F-Droid metadata**: Fastlane structure, build configuration for F-Droid submission
- Release workflow: Automatic APK build and GitHub release on tag push (v*)
- Full app flow with credential storage (flutter_secure_storage)

### Changed

- Flutter upgraded to 3.41.1 (Dart 3.8+)
- Compact layout with reduced spacing
- Improved GitHub error messages on 401 (API message shown)
- Android: `queries` for http/https so links open in external browser
- App icon generated from GitSyncMarks logo (flutter_launcher_icons)
- Android Gradle Plugin upgraded (8.1.0 → 8.9.1), Kotlin 2.1.0

### Fixed

- First start now shows Settings instead of white error screen
- Localization output directory and placeholder types for Flutter 3.29+
- Flutter 3.29 compatibility (CardThemeData, withOpacity deprecations)

---

## [0.1.0] - 2026-02

### Added

- Flutter project setup (iOS + Android)
- Bookmark list screen with expandable folder tree
- Settings screen: GitHub Token, Owner, Repo, Branch, Base Path
- Test Connection to validate credentials and discover root folders
- Base folder selection (multi-select: toolbar, menu, mobile, other, etc.)
- Sync bookmarks from GitHub via Contents API
- Open bookmark URLs in external browser (url_launcher)
- Favicons for bookmarks (DuckDuckGo API, cached)
- Pull-to-refresh
- Light and Dark mode (GitSyncMarks branding)
- Empty folders hidden from list
- About screen with links to bookmarks-sync and GitSyncMarks
- Help screen with setup instructions
- App icon (GitSyncMarks logo)

### Dependencies

- flutter, provider, http, url_launcher, flutter_secure_storage, cached_network_image
