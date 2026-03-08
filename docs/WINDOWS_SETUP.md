# Windows Setup and Development Guide

This guide covers how to set up the development environment for GitSyncMarks on Windows and how to create the installer.

## Development Requirements

To build GitSyncMarks on Windows, you need:

1.  **Flutter SDK**: Installed and configured.
2.  **Visual Studio 2022**: With the **"Desktop development with C++"** (Desktopentwicklung mit C++) workload installed.
3.  **Windows Desktop Support**: Enable it in Flutter:
    ```bash
    flutter config --enable-windows-desktop
    ```

## Building the App

To build a release version:
```bash
flutter build windows --release
```
The output will be in `build\windows\x64\runner\Release`.

## Creating the Installer (Setup.exe)

We use **Inno Setup** to create a professional installer that handles dependencies like the Visual C++ Redistributable.

### Prerequisites for Installer Creation
1.  **Inno Setup**: Download and install [Inno Setup 6+](https://jrsoftware.org/isdl.php).
2.  **VC Redistributable**: Ensure `windows/redist/VC_redist.x64.exe` exists (already included in the repo).

### Steps to Generate Setup.exe
1.  Open `windows/gitsyncmarks.iss` in Inno Setup.
2.  Click **Build > Compile** (or press F9).
3.  The installer will be generated at `build\windows\installer\GitSyncMarks-Setup.exe`.

## Troubleshooting

### Missing MSVCP140.dll
If the app fails to start with a "DLL not found" error, it means the Microsoft Visual C++ Redistributable is missing. The installer should handle this automatically, but if you are running the `.exe` directly from the zip, you must install it manually:
[Download VC_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)

## Plugin Compatibility
- **receive_sharing_intent**: Currently NOT supported on Windows. Links cannot be shared directly to the app via the Windows system share menu.
