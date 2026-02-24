#!/usr/bin/env bash
# Generate light/dark screenshots for README, Flatpak metainfo, F-Droid.
# Run from project root: ./scripts/generate-screenshots.sh
set -e

cd "$(dirname "$0")/.."

echo "Generating golden screenshots (light + dark)..."
flutter test test/screenshot_test.dart --update-goldens

echo "Copying to flatpak/screenshots/..."
mkdir -p flatpak/screenshots
cp test/goldens/*.png flatpak/screenshots/

echo "Done. Screenshots: flatpak/screenshots/"
ls -la flatpak/screenshots/
