#!/usr/bin/env bash
# Baut das Flutter-Linux-Release-Bundle, erzeugt daraus ein Arch-Linux-Paket
# und installiert es lokal mit pacman (laufendes System muss **Arch** sein, mit
# makepkg; siehe build_pkg.sh für Docker-basiertes makepkg).
#
# Umgebung:
#   PKGREL   — Arch pkgrel (Standard: 1)
#   Z13_HOST — SSH-Host für Remote-Install (Standard: z13)
#   Z13_USER — SSH-User (Standard: $USER)
#   Z13_DIR  — Remote-Tmp-Verzeichnis (Standard: /tmp)
#
# Aufruf:
#   ./scripts/build_install_linux_arch_pkg.sh
#   ./scripts/build_install_linux_arch_pkg.sh --skip-build   # vorhandenes Linux-Bundle packen
#   ./scripts/build_install_linux_arch_pkg.sh --no-install  # nur Paket unter dist/ erzeugen
#   ./scripts/build_install_linux_arch_pkg.sh --install-z13  # zusätzlich auf z13 installieren

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
WORKDIR="${TMPDIR:-/tmp}/gitsyncmarks-app-arch-pkg-local"
PKGREL="${PKGREL:-1}"
Z13_HOST="${Z13_HOST:-z13}"
Z13_USER="${Z13_USER:-${USER:-}}"
Z13_DIR="${Z13_DIR:-/tmp}"
SKIP_BUILD=0
INSTALL_PKG=1
INSTALL_Z13=0

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --skip-build|--no-build) SKIP_BUILD=1 ;;
    --no-install|--package-only) INSTALL_PKG=0 ;;
    --install-z13|--z13) INSTALL_Z13=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unbekanntes Argument: $arg" >&2
      echo "Erlaubt: --skip-build, --no-install, --install-z13, --help" >&2
      exit 1
      ;;
  esac
done

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Fehlendes Kommando: $cmd" >&2
    exit 1
  fi
}

require_command flutter
require_command makepkg
require_command pacman
require_command ssh
require_command scp

cd "$ROOT"

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  echo "=== flutter build linux --release ==="
  flutter build linux --release
fi

if [[ ! -x "$BUNDLE/gitsyncmarks_app" ]]; then
  echo "Linux-Bundle fehlt: $BUNDLE/gitsyncmarks_app" >&2
  echo "Tipp: ohne --skip-build erneut ausführen." >&2
  exit 1
fi

VERSION="$(awk '/^version:/ {print $2; exit}' "$ROOT/pubspec.yaml" | cut -d+ -f1)"
if [[ -z "$VERSION" ]]; then
  echo "Konnte version: in pubspec.yaml nicht lesen." >&2
  exit 1
fi

# Arch pkgver darf keine Bindestriche enthalten.
PKGVER="${VERSION//-/.}"

echo "=== Arch-Paket bauen: gitsyncmarks-app $PKGVER-$PKGREL ==="
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR" "$ROOT/dist"

cp "$ROOT/packaging/archlinux/PKGBUILD.prebuilt" "$WORKDIR/PKGBUILD"
cp "$ROOT/packaging/archlinux/gitsyncmarks_app.desktop" "$WORKDIR/"
cp "$ROOT/assets/images/app_icon.png" "$WORKDIR/"
sed -i "s/^pkgver=.*/pkgver=$PKGVER/" "$WORKDIR/PKGBUILD"
sed -i "s/^pkgrel=.*/pkgrel=$PKGREL/" "$WORKDIR/PKGBUILD"
tar czf "$WORKDIR/gitsyncmarks-app-bundle.tar.gz" -C "$ROOT/build/linux/x64/release" bundle

(cd "$WORKDIR" && makepkg -f --noconfirm --skipchecksums)

shopt -s nullglob
packages=("$WORKDIR"/gitsyncmarks-app-"$PKGVER"-"$PKGREL"-*.pkg.tar.zst)
if (( ${#packages[@]} == 0 )); then
  echo "makepkg hat kein passendes .pkg.tar.zst erzeugt." >&2
  exit 1
fi

cp "${packages[@]}" "$ROOT/dist/"
PACKAGE="$ROOT/dist/$(basename "${packages[0]}")"

echo ""
echo "Paket: $PACKAGE"
pacman -Qip "$PACKAGE"

if [[ "$INSTALL_PKG" -eq 1 ]]; then
  echo ""
  echo "=== sudo pacman -U ==="
  sudo pacman -U "$PACKAGE"
else
  echo ""
  echo "Installation übersprungen (--no-install)."
fi

if [[ "$INSTALL_Z13" -eq 1 ]]; then
  if [[ -z "$Z13_USER" ]]; then
    echo "Z13_USER ist leer (konnte USER nicht lesen)." >&2
    exit 1
  fi
  echo ""
  echo "=== Installiere zusätzlich auf ${Z13_USER}@${Z13_HOST} ==="
  remote_pkg="${Z13_DIR%/}/$(basename "$PACKAGE")"
  scp "$PACKAGE" "${Z13_USER}@${Z13_HOST}:$remote_pkg"
  ssh "${Z13_USER}@${Z13_HOST}" "sudo pacman -U --noconfirm \"$remote_pkg\" && rm -f \"$remote_pkg\""
fi

echo ""
echo "Fertig."
