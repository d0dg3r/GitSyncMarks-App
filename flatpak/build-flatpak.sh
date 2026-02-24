#!/bin/bash
# Convert the Flutter Linux bundle to a Flatpak.

set -e
set -x

projectName=GitSyncMarksMobile
projectId=io.github.d0dg3r.GitSyncMarksMobile
executableName=gitsyncmarks_app

# Extract portable Flutter build
mkdir -p "$projectName"
tar -xf GitSyncMarks-Mobile-Linux-Portable.tar.gz -C "$projectName" --no-same-owner

# Copy the portable app to the Flatpak location
cp -r "$projectName" /app/
chmod +x "/app/$projectName/$executableName"
mkdir -p /app/bin
ln -s "/app/$projectName/$executableName" /app/bin/$executableName

# Install the icon (128x128)
iconDir=/app/share/icons/hicolor/128x128/apps
mkdir -p "$iconDir"
for icon in app_icon.png assets/images/app_icon.png ../assets/images/app_icon.png "$projectName/data/flutter_assets/assets/images/app_icon.png"; do
  if [ -f "$icon" ]; then
    cp "$icon" "$iconDir/$projectId.png"
    break
  fi
done

# Install the desktop file
desktopFileDir=/app/share/applications
mkdir -p "$desktopFileDir"
cp io.github.d0dg3r.GitSyncMarksMobile.desktop "$desktopFileDir/"

# Install the AppStream metadata file
metadataDir=/app/share/metainfo
mkdir -p "$metadataDir"
cp io.github.d0dg3r.GitSyncMarksMobile.metainfo.xml "$metadataDir/"
