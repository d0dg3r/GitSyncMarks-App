#!/usr/bin/env bash
# Submit GitSyncMarks-App to F-Droid via GitLab merge request
# Prerequisites: GitLab account, fdroiddata fork, SSH key configured
#
# Usage: ./submit-to-gitlab.sh [OPTIONS] [GITLAB_USER]
#   GITLAB_USER: your GitLab username (default: d0dg3r)
#   --force:         force-push (overwrites remote branch; use when MR has no review changes to keep)
#   --validate-only: run all release/metadata checks, write proof log, skip clone/push
#
# First submit: creates branch from master, pushes.
# Update:       fetches remote branch, rebases, updates metadata, pushes (preserves review feedback).
# Update --force: resets branch from master, force-pushes (discards remote changes).

set -euo pipefail

FORCE=false
VALIDATE_ONLY=false
GITLAB_USER="d0dg3r"
for arg in "$@"; do
  if [[ "$arg" == "--force" ]]; then
    FORCE=true
  elif [[ "$arg" == "--validate-only" ]]; then
    VALIDATE_ONLY=true
  elif [[ "$arg" != --* ]]; then
    GITLAB_USER="$arg"
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/gitsyncmarks-fdroiddata"
REPO_URL="git@gitlab.com:${GITLAB_USER}/fdroiddata.git"
PROOF_DIR="$PROJECT_DIR/fdroid/proofs"
mkdir -p "$PROOF_DIR"
PROOF_FILE="$PROOF_DIR/submit-$(date +%Y%m%d-%H%M%S).log"

echo "F-Droid submission for GitSyncMarks-App"
echo "GitLab user: $GITLAB_USER"
[[ "$FORCE" == "true" ]] && echo "Mode: --force (will overwrite remote branch)"
[[ "$VALIDATE_ONLY" == "true" ]] && echo "Mode: --validate-only (no clone/push)"
echo ""

# Step 1: Fork reminder
echo "1. Fork fdroiddata (if not done yet):"
echo "   https://gitlab.com/fdroid/fdroiddata/-/forks/new"
echo ""

write_proof() {
  {
    echo "date=$(date -Iseconds)"
    echo "submit_file=$SUBMIT_FILE"
    echo "tag=$TAG_NAME"
    echo "tag_commit=$TAG_COMMIT"
    echo "metadata_commit=$METADATA_COMMIT"
    echo "current_version=$CURRENT_VERSION"
    echo "current_version_code=$CURRENT_VERSION_CODE"
    echo "pubspec_version=$PUBSPEC_VERSION"
    echo "pubspec_version_code=$PUBSPEC_VERSION_CODE"
    echo "branch=$BRANCH"
    echo "gitlab_user=$GITLAB_USER"
    echo "validate_only=$VALIDATE_ONLY"
  } > "$PROOF_FILE"
  echo ""
  echo "Proof saved: $PROOF_FILE"
}

# Step 4: Validate submit metadata and release gates
SUBMIT_FILE="$PROJECT_DIR/fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml"
PUBSPEC_FILE="$PROJECT_DIR/pubspec.yaml"
CHANGELOG_BASE="$PROJECT_DIR/fdroid/metadata/com.d0dg3r.gitsyncmarks/en-US/changelogs"
CURRENT_VERSION=$(sed -n 's/^CurrentVersion:[[:space:]]*//p' "$SUBMIT_FILE" | head -1 | tr -d '\r')
CURRENT_VERSION_CODE=$(sed -n 's/^CurrentVersionCode:[[:space:]]*//p' "$SUBMIT_FILE" | head -1 | tr -d '\r')
METADATA_COMMIT=$(sed -n 's/^[[:space:]]*commit:[[:space:]]*//p' "$SUBMIT_FILE" | head -1 | tr -d '\r')
PUBSPEC_VERSION=$(sed -n -E 's/^version:[[:space:]]*([0-9A-Za-z.\-]+)\+([0-9]+).*/\1/p' "$PUBSPEC_FILE" | head -1 | tr -d '\r')
PUBSPEC_VERSION_CODE=$(sed -n -E 's/^version:[[:space:]]*([0-9A-Za-z.\-]+)\+([0-9]+).*/\2/p' "$PUBSPEC_FILE" | head -1 | tr -d '\r')
TAG_NAME="v${CURRENT_VERSION}"

echo "2. Validating submit metadata + release gates..."
if grep -q 'COMMIT_PLACEHOLDER' "$SUBMIT_FILE" 2>/dev/null; then
  echo "   ERROR: Replace COMMIT_PLACEHOLDER with actual commit hash (git rev-parse v0.3.2) before submit."
  exit 1
fi
if grep -E '(CurrentVersion|versionName:).*-(beta|alpha|rc|test|dev)[.-]' "$SUBMIT_FILE" >/dev/null 2>&1; then
  echo "   ERROR: Submit metadata contains pre-release versions (-beta, -alpha, -rc, etc.)."
  echo "   F-Droid accepts only stable releases. Fix $SUBMIT_FILE and try again."
  exit 1
fi
if [[ -z "$CURRENT_VERSION" || -z "$CURRENT_VERSION_CODE" || -z "$METADATA_COMMIT" ]]; then
  echo "   ERROR: Missing CurrentVersion, CurrentVersionCode, or commit in $SUBMIT_FILE."
  exit 1
fi
if ! grep -q '^AllowedAPKSigningKeys:[[:space:]]\+[0-9a-f]\{64\}$' "$SUBMIT_FILE"; then
  echo "   ERROR: AllowedAPKSigningKeys missing or invalid (must be 64-char lowercase SHA256 hex)."
  exit 1
fi
if ! grep -q '^[[:space:]]\+binary:' "$SUBMIT_FILE"; then
  echo "   ERROR: Builds.binary missing in submit metadata."
  exit 1
fi
if ! grep -Fxq 'UpdateCheckMode: Tags ^v[0-9.]+$' "$SUBMIT_FILE"; then
  echo "   ERROR: UpdateCheckMode must be: Tags ^v[0-9.]+$"
  exit 1
fi
if [[ "$CURRENT_VERSION" != "$PUBSPEC_VERSION" ]]; then
  echo "   ERROR: CurrentVersion ($CURRENT_VERSION) != pubspec version ($PUBSPEC_VERSION)."
  exit 1
fi
if [[ "$CURRENT_VERSION_CODE" != "$PUBSPEC_VERSION_CODE" ]]; then
  echo "   ERROR: CurrentVersionCode ($CURRENT_VERSION_CODE) != pubspec versionCode ($PUBSPEC_VERSION_CODE)."
  exit 1
fi
if [[ ! -f "$CHANGELOG_BASE/${CURRENT_VERSION_CODE}.txt" ]]; then
  echo "   ERROR: Missing F-Droid changelog file: $CHANGELOG_BASE/${CURRENT_VERSION_CODE}.txt"
  exit 1
fi
git -C "$PROJECT_DIR" fetch --tags --quiet
if ! git -C "$PROJECT_DIR" rev-parse "$TAG_NAME" >/dev/null 2>&1; then
  echo "   ERROR: Missing release tag $TAG_NAME in app repository."
  exit 1
fi
TAG_COMMIT=$(git -C "$PROJECT_DIR" rev-parse "${TAG_NAME}^{commit}" 2>/dev/null \
  || git -C "$PROJECT_DIR" rev-parse "$TAG_NAME")
if [[ "$TAG_COMMIT" != "$METADATA_COMMIT" ]]; then
  echo "   ERROR: Tag commit mismatch: $TAG_NAME -> $TAG_COMMIT, metadata commit -> $METADATA_COMMIT"
  exit 1
fi
echo "   OK: Only stable versions in submit metadata."
echo "   OK: Version/code/tag/hash gates passed."

echo "3. Running libapp.so reproducibility proof..."
bash "$PROJECT_DIR/scripts/fdroid-repro-proof.sh"
echo "   OK: libapp.so reproducibility proof passed."

if [[ "$VALIDATE_ONLY" == "true" ]]; then
  BRANCH="com.d0dg3r.gitsyncmarks"
  write_proof
  echo "Validation complete (no clone/push executed)."
  exit 0
fi

# Step 2: Clone or update
if [[ -d "$BUILD_DIR/.git" ]]; then
  echo "3. Updating existing clone..."
  cd "$BUILD_DIR"
  git fetch origin
  git checkout master 2>/dev/null || git checkout main 2>/dev/null || true
  git pull origin master 2>/dev/null || git pull origin main 2>/dev/null || true
else
  echo "3. Cloning your fdroiddata fork..."
  mkdir -p "$(dirname "$BUILD_DIR")"
  git clone --depth=1 "$REPO_URL" "$BUILD_DIR"
  cd "$BUILD_DIR"
fi

# Step 3: Create or checkout branch
BRANCH="com.d0dg3r.gitsyncmarks"
REMOTE_HAS_BRANCH=$(git ls-remote origin "refs/heads/$BRANCH" 2>/dev/null | head -1)

if [[ "$FORCE" == "true" ]]; then
  echo "4. Resetting branch $BRANCH from master (--force)..."
  git checkout -B "$BRANCH"
elif [[ -n "$REMOTE_HAS_BRANCH" ]]; then
  echo "4. Updating existing branch $BRANCH from remote..."
  git fetch origin "$BRANCH"
  git checkout -B "$BRANCH" FETCH_HEAD
else
  echo "4. Creating new branch $BRANCH..."
  git checkout -B "$BRANCH"
fi

# Step 5: Copy metadata (submit file → fdroiddata expects com.d0dg3r.gitsyncmarks.yml)
echo "5. Copying metadata..."
cp "$SUBMIT_FILE" metadata/com.d0dg3r.gitsyncmarks.yml

# Step 5b: Remove localized metadata dir if present (CI check requires summary.txt/description.txt
# instead of short_description.txt/full_description.txt; metadata comes from app repo via Repo:)
if [[ -d metadata/com.d0dg3r.gitsyncmarks ]]; then
  echo "5b. Removing metadata/com.d0dg3r.gitsyncmarks/ (metadata from app repo)"
  rm -rf metadata/com.d0dg3r.gitsyncmarks
fi

# Step 6: Commit
echo "6. Committing..."
git add metadata/com.d0dg3r.gitsyncmarks.yml metadata/
if git diff --cached --quiet; then
  echo "   No changes (file may already be committed)"
else
  git commit -m "Update: com.d0dg3r.gitsyncmarks"
fi

# Step 7: Push
echo "7. Pushing to GitLab..."
if [[ "$FORCE" == "true" ]]; then
  git push --force-with-lease -u origin "$BRANCH"
else
  git push -u origin "$BRANCH"
fi

echo ""
echo "Done. Create merge request:"
echo "   https://gitlab.com/${GITLAB_USER}/fdroiddata/-/merge_requests/new?merge_request%5Bsource_branch%5D=$BRANCH"
echo ""
echo "Or open: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new"
echo "and select branch '$BRANCH' from your fork."
write_proof
