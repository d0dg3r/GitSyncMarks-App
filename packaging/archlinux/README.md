# Arch Linux / AUR

## GitHub Release (prebuilt pacman package)

[`.github/workflows/release.yml`](../../.github/workflows/release.yml) runs `flutter build linux --release`, then [`build_pkg.sh`](build_pkg.sh) in an **Arch Linux** Docker image to produce a **`*.pkg.tar.zst`**, which is included in the Linux release assets.

Install on Arch:

```bash
sudo pacman -U ./gitsyncmarks-app-0.3.7-1-x86_64.pkg.tar.zst
```

(Use the exact file name from the [Releases](https://github.com/d0dg3r/GitSyncMarks-App/releases) page; version matches the tag after `v`.)

**Requirements:** [Docker](https://docs.docker.com/get-docker/) for the script below.

## AUR from source (template)

[`PKGBUILD`](PKGBUILD) is a **template** for an AUR package (builds with `flutter` on the maintainer or user machine). Before publishing:

1. Set `pkgver` / `pkgrel` to match the release.
2. Set `sha256sums` for the source tarball (`updpkgsums` or `makepkg -g`).
3. `makepkg -f` and test.
4. Generate `.SRCINFO`: `makepkg --printsrcinfo > .SRCINFO`.
5. Push to the AUR Git (see [AUR submission guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)).

**Note:** Arch’s official `flutter` package may differ from the [version pinned in CI](../../.github/workflows/release.yml). If the build fails, use Flutter from [docs.flutter.dev (Linux)](https://docs.flutter.dev/get-started/install/linux).

## Internal prebuilt package (`PKGBUILD.prebuilt`)

Used by [`build_pkg.sh`](build_pkg.sh) (CI and local `flutter build linux` + Docker `makepkg`) and by [`../../scripts/build_install_linux_arch_pkg.sh`](../../scripts/build_install_linux_arch_pkg.sh) (local **Arch** host: `makepkg` + optional `sudo pacman -U` / remote install). **Not** intended for direct AUR upload.

## Local build and install (on Arch Linux, no Docker)

If you run **Arch** (or an environment with `makepkg`, `pacman`, `flutter`) and want the same prebuilt package without Docker:

```bash
./scripts/build_install_linux_arch_pkg.sh
```

Options: `--skip-build` (use existing bundle), `--no-install` (only write `dist/*.pkg.tar.zst`), `--install-z13` (copy to `Z13_HOST` and install over SSH; see script header for `Z13_*` variables). Same pattern as **NoSuckTV**’s `build_install_linux_arch_pkg.sh`.

## Local test (Docker)

```bash
flutter build linux --release
bash packaging/archlinux/build_pkg.sh
```

The output is `dist/gitsyncmarks-app-<ver>-1-x86_64.pkg.tar.zst`.

The image `archlinux:latest` is pulled automatically on first use.
