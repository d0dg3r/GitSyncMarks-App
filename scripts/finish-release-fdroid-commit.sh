#!/usr/bin/env bash
# After the main release commit (version bump, changelog, code), run this to:
# 1. Set every F-Droid `commit:` field to that release commit (the tree F-Droid must build).
# 2. Create a small follow-up commit with only the metadata change.
# 3. Optionally create tag vX.Y.Z on the *first* (release) commit so tag matches metadata.
#
# Usage (from repo root, AFTER `git commit` for the release):
#   ./scripts/finish-release-fdroid-commit.sh
#   ./scripts/finish-release-fdroid-commit.sh --tag   # also: git tag v$(sed ...) $C1
#
# Then: git push && git push origin v0.3.5
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TAG=false
for arg in "$@"; do
  [[ "$arg" == "--tag" ]] && TAG=true
done

C1="$(git rev-parse HEAD)"
if git diff-index --quiet HEAD -- 2>/dev/null; then
  :
else
  echo "ERROR: Working tree is not clean. Commit or stash before running."
  exit 1
fi

SUBMIT="$ROOT/fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml"
DEV="$ROOT/fdroid/metadata/com.d0dg3r.gitsyncmarks.yml"
for f in "$SUBMIT" "$DEV"; do
  [[ -f "$f" ]] || { echo "ERROR: Missing $f"; exit 1; }
done

python3 "$ROOT/scripts/patch-fdroid-metadata-commits.py" "$C1" "$SUBMIT" "$DEV"

git add "$SUBMIT" "$DEV"

if git diff --cached --quiet; then
  echo "No metadata changes (commit lines already $C1?). Nothing to do."
  exit 0
fi

git commit -m "chore(fdroid): record build commit $C1"

if [[ "$TAG" == true ]]; then
  VER="$(sed -n -E 's/^version:[[:space:]]*([0-9.]+)\+.*/\1/p' "$ROOT/pubspec.yaml" | head -1)"
  if [[ -z "$VER" ]]; then
    echo "ERROR: Could not read version from pubspec.yaml"
    exit 1
  fi
  git tag -a "v$VER" -m "v$VER" "$C1"
  echo "Created annotated tag v$VER -> $C1 (release tree)."
  echo "Tip: If the tag already exists, delete it first: git tag -d v$VER && git push origin :refs/tags/v$VER"
fi

echo "Done. F-Droid metadata now points to build commit: $C1"
echo "Next: merge to main if needed, push branch, push tag, wait for CI, run ./fdroid/submit-to-gitlab.sh --validate-only"
