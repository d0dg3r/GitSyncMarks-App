#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROOF_DIR="$PROJECT_DIR/fdroid/proofs"
METADATA_FILE="$PROJECT_DIR/fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml"
CONTAINER_IMAGE="registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-}"

if [[ -z "$CONTAINER_ENGINE" ]]; then
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
  elif command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
  else
    echo "ERROR: No container engine available. Install Docker or Podman."
    exit 1
  fi
fi

mkdir -p "$PROOF_DIR" "$PROJECT_DIR/build/fdroid-proof"

CURRENT_VERSION="$(sed -n 's/^CurrentVersion:[[:space:]]*//p' "$METADATA_FILE" | head -1 | tr -d '\r')"
METADATA_COMMIT="$(sed -n 's/^[[:space:]]*commit:[[:space:]]*//p' "$METADATA_FILE" | head -1 | tr -d '\r')"
BINARY_TEMPLATE="$(awk '/^[[:space:]]+binary:[[:space:]]*$/ {getline; gsub(/^[[:space:]]+/, "", $0); print; exit}' "$METADATA_FILE")"

if [[ -z "$CURRENT_VERSION" || -z "$METADATA_COMMIT" || -z "$BINARY_TEMPLATE" ]]; then
  echo "ERROR: Failed to read CurrentVersion/commit/binary from $METADATA_FILE"
  exit 1
fi

UPSTREAM_URL="${BINARY_TEMPLATE//%v/$CURRENT_VERSION}"
LOCAL_APK="$PROJECT_DIR/build/fdroid-proof/local-app-release.apk"
UPSTREAM_APK="$PROJECT_DIR/build/fdroid-proof/upstream-app-release.apk"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$PROOF_DIR/repro-libapp-$TIMESTAMP.log"

echo "Running reproducibility proof for version $CURRENT_VERSION"
echo "Build commit: $METADATA_COMMIT"
echo "Upstream URL: $UPSTREAM_URL"

git -C "$PROJECT_DIR" fetch --tags --quiet

"$CONTAINER_ENGINE" run --rm \
  -v "$PROJECT_DIR:/repo" \
  -w /repo \
  "$CONTAINER_IMAGE" \
  bash -lc '
    set -euo pipefail

    apt-get update -y
    apt-get install -y git curl xz-utils unzip zip jq ca-certificates locales
    sed -i "s/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen || true
    locale-gen en_US.UTF-8 || true

    # Diagnostics for repo mount ownership/trust issues on CI runners.
    echo "Git/container diagnostics:"
    id
    ls -ld /repo /repo/.git || true
    git config --global --add safe.directory /repo
    git config --global --add safe.directory /repo/.git
    echo "Configured safe.directory entries:"
    git config --global --get-all safe.directory || true

    for candidate in /opt/android-sdk /usr/lib/android-sdk /home/vagrant/android-sdk /sdk; do
      if [ -d "$candidate" ]; then
        export ANDROID_HOME="$candidate"
        export ANDROID_SDK_ROOT="$candidate"
        export PATH="$candidate/platform-tools:$candidate/cmdline-tools/latest/bin:$PATH"
        break
      fi
    done

    if [ -z "${ANDROID_HOME:-}" ]; then
      echo "ERROR: No Android SDK found in container."
      exit 1
    fi

    rm -rf /tmp/build
    git clone --no-local file:///repo /tmp/build
    cd /tmp/build
    git checkout -f "'"$METADATA_COMMIT"'"

    FLUTTER_VERSION=$(
      python3 <<PY
import pathlib
import re
text = pathlib.Path("/tmp/build/.github/workflows/release.yml").read_text(encoding="utf-8")
q = chr(39)
part = "[^" + q + "]+"
pat = "flutter-version:\\s*(?:\"([^\\\"]+)\"|" + q + part + q + ")"
match = re.search(pat, text)
ver = (match.group(1) or match.group(2)) if match else ""
print(ver)
PY
    )
    if [ -z "$FLUTTER_VERSION" ]; then
      echo "ERROR: Failed to resolve flutter-version from release workflow."
      exit 1
    fi

    curl -fsSL -o /tmp/flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    rm -rf /opt/flutter
    mkdir -p /opt/flutter
    tar -xf /tmp/flutter.tar.xz -C /opt/flutter --strip-components=1
    chown -R "$(id -u):$(id -g)" /opt/flutter

    export PATH="/opt/flutter/bin:$PATH"
    export PUB_CACHE=/tmp/build/.pub-cache
    export GRADLE_USER_HOME=/tmp/build/.gradle-home
    export GRADLE_OPTS="-Dorg.gradle.vfs.watch=false -Dorg.gradle.daemon=false"
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANGUAGE=en_US:en

    mkdir -p "$PUB_CACHE" "$GRADLE_USER_HOME"
    rm -rf .gradle android/.gradle "$GRADLE_USER_HOME"/*
    export SOURCE_DATE_EPOCH="$(git log -1 --pretty=%ct)"

    flutter config --no-analytics
    flutter --version
    flutter pub get
    flutter gen-l10n

    if [ -f /repo/android/key.properties ] && [ -f /repo/android/upload-keystore.jks ]; then
      cp /repo/android/key.properties /tmp/build/android/key.properties
      cp /repo/android/upload-keystore.jks /tmp/build/android/upload-keystore.jks
    else
      keytool -genkeypair -v \
        -keystore /tmp/build/android/upload-keystore.jks \
        -storepass android \
        -keypass android \
        -alias upload \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=GitSyncMarks Repro, OU=CI, O=GitSyncMarks, L=Berlin, ST=Berlin, C=DE"
      cat > /tmp/build/android/key.properties <<EOF
storePassword=android
keyPassword=android
keyAlias=upload
storeFile=../upload-keystore.jks
EOF
    fi

    flutter build apk --release --target-platform android-arm64 --no-pub

    cp build/app/outputs/flutter-apk/app-release.apk /repo/build/fdroid-proof/local-app-release.apk
  '

curl -fsSL -o "$UPSTREAM_APK" "$UPSTREAM_URL"

LOCAL_HASH="$(unzip -p "$LOCAL_APK" lib/arm64-v8a/libapp.so | sha256sum | awk "{print \$1}")"
UPSTREAM_HASH="$(unzip -p "$UPSTREAM_APK" lib/arm64-v8a/libapp.so | sha256sum | awk "{print \$1}")"

{
  echo "date=$(date -Iseconds)"
  echo "version=$CURRENT_VERSION"
  echo "metadata_commit=$METADATA_COMMIT"
  echo "metadata_file=$METADATA_FILE"
  echo "container_image=$CONTAINER_IMAGE"
  echo "container_engine=$CONTAINER_ENGINE"
  echo "upstream_url=$UPSTREAM_URL"
  echo "local_apk=$LOCAL_APK"
  echo "upstream_apk=$UPSTREAM_APK"
  echo "local_libapp_sha256=$LOCAL_HASH"
  echo "upstream_libapp_sha256=$UPSTREAM_HASH"
} > "$LOG_FILE"

echo "Proof log: $LOG_FILE"
echo "Local    libapp.so SHA256: $LOCAL_HASH"
echo "Upstream libapp.so SHA256: $UPSTREAM_HASH"

if [[ "$LOCAL_HASH" != "$UPSTREAM_HASH" ]]; then
  echo "ERROR: libapp.so hash mismatch."
  exit 1
fi

echo "OK: libapp.so hash matches."
