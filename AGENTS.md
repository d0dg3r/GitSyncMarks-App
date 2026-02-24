# AGENTS.md

## Cursor Cloud specific instructions

### Overview

GitSyncMarks-Mobile is a Flutter mobile/desktop app that syncs bookmarks from a GitHub repo. No backend server, no database — pure client-side app. See `README.md` for full details.

### Prerequisites (already installed in snapshot)

- Flutter SDK at `/opt/flutter` (added to PATH via `~/.bashrc`)
- Linux desktop build deps: `ninja-build`, `libgtk-3-dev`, `g++-14`, `xdg-user-dirs`
- `libstdc++.so` symlink at `/usr/lib/x86_64-linux-gnu/libstdc++.so` (required for clang linker)

### Key commands

Standard dev commands per `CONTRIBUTING.md`:

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint | `flutter analyze` |
| Format | `dart format .` |
| Test | `flutter test` |
| Build (Linux debug) | `flutter build linux --debug` |
| Run (Linux) | `build/linux/x64/debug/bundle/gitsyncmarks_app` |
| Run (Chrome) | `flutter run -d chrome` |
| Golden screenshots | `flutter test --update-goldens test/screenshot_test.dart` |

### Non-obvious caveats

- **Linux desktop build requires `g++-14`**: Clang (the default compiler) selects GCC 14 include paths. Without `libstdc++-14-dev` / `g++-14` installed, the build fails with `'type_traits' file not found`.
- **`libstdc++.so` symlink**: The linker needs `/usr/lib/x86_64-linux-gnu/libstdc++.so` pointing to `libstdc++.so.6`. Without it, CMake fails with `cannot find -lstdc++`.
- **XDG user dirs required**: The app uses `path_provider` which needs XDG directories. Run `xdg-user-dirs-update` once if you see `MissingPlatformDirectoryException`.
- **DISPLAY=:1**: Set `DISPLAY=:1` when launching the Linux desktop app in the VM.
- **2 pre-existing test failures**: `bookmark_service_test.dart` has 2 tests that fail due to missing `WidgetsFlutterBinding.ensureInitialized()` — this is a known issue in the test code, not an environment problem.
- **No Android emulator in cloud VM**: Use Linux desktop (`flutter build linux --debug`) or Chrome (`flutter run -d chrome`) as the target platform for testing.
