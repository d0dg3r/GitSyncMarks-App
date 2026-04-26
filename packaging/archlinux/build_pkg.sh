#!/usr/bin/env bash
# Produces gitsyncmarks-app-<pkgver>-<pkgrel>-x86_64.pkg.tar.zst in dist/.
# Prerequisite: from repo root, run: flutter build linux --release
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

BUNDLE="$ROOT/build/linux/x64/release/bundle"
if [[ ! -x "$BUNDLE/gitsyncmarks_app" ]]; then
  echo "Missing Linux bundle. Run: flutter build linux --release" >&2
  exit 1
fi

VERSION="$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d+ -f1)"
# Arch pkgver must not contain hyphens (e.g. pre-release version suffixes).
PKGVER="${VERSION//-/.}"
PKGREL=1

mkdir -p "$ROOT/dist"

docker run --rm \
  -v "$ROOT:/repo" \
  -e "VER=$PKGVER" \
  -e "REL=$PKGREL" \
  archlinux:latest \
  bash -ceu '
set -o pipefail
pacman -Sy --noconfirm --needed \
  base-devel sudo archlinux-keyring \
  gtk3 libsecret zlib

useradd -m builduser

WORKDIR=/tmp/gitsyncmarks-app-arch-pkg
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cp /repo/packaging/archlinux/PKGBUILD.prebuilt "$WORKDIR/PKGBUILD"
cp /repo/packaging/archlinux/gitsyncmarks_app.desktop "$WORKDIR/"
cp /repo/assets/images/app_icon.png "$WORKDIR/"
sed -i "s/^pkgver=.*/pkgver=$VER/" "$WORKDIR/PKGBUILD"
sed -i "s/^pkgrel=.*/pkgrel=$REL/" "$WORKDIR/PKGBUILD"
tar czf "$WORKDIR/gitsyncmarks-app-bundle.tar.gz" -C /repo/build/linux/x64/release bundle
chown -R builduser:builduser "$WORKDIR"

sudo -u builduser bash -ceu "cd \"$WORKDIR\" && makepkg -f --noconfirm --skipchecksums"

shopt -s nullglob
pkgs=("$WORKDIR"/*.pkg.tar.zst)
if (( ${#pkgs[@]} == 0 )); then
  echo "makepkg produced no .pkg.tar.zst under $WORKDIR" >&2
  ls -la "$WORKDIR" >&2 || true
  exit 1
fi

mkdir -p /repo/dist
cp "${pkgs[@]}" /repo/dist/
chmod a+r /repo/dist/*.pkg.tar.zst
ls -la /repo/dist/*.pkg.tar.zst
'
