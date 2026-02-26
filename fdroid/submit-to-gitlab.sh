#!/usr/bin/env bash
# Submit GitSyncMarks-App to F-Droid via GitLab merge request
# Prerequisites: GitLab account, fdroiddata fork, SSH key configured
#
# Usage: ./submit-to-gitlab.sh [GITLAB_USER]
#   GITLAB_USER: your GitLab username (default: d0dg3r)

set -e

GITLAB_USER="${1:-d0dg3r}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/gitsyncmarks-fdroiddata"
REPO_URL="git@gitlab.com:${GITLAB_USER}/fdroiddata.git"

echo "F-Droid submission for GitSyncMarks-App"
echo "GitLab user: $GITLAB_USER"
echo ""

# Step 1: Fork reminder
echo "1. Fork fdroiddata (if not done yet):"
echo "   https://gitlab.com/fdroid/fdroiddata/-/forks/new"
echo ""

# Step 2: Clone or update
if [[ -d "$BUILD_DIR/.git" ]]; then
  echo "2. Updating existing clone..."
  cd "$BUILD_DIR"
  git fetch origin
  git checkout master 2>/dev/null || git checkout main 2>/dev/null || true
  git pull origin master 2>/dev/null || git pull origin main 2>/dev/null || true
else
  echo "2. Cloning your fdroiddata fork..."
  mkdir -p "$(dirname "$BUILD_DIR")"
  git clone --depth=1 "$REPO_URL" "$BUILD_DIR"
  cd "$BUILD_DIR"
fi

# Step 3: Create or checkout branch
echo "3. Creating branch com.d0dg3r.gitsyncmarks..."
git checkout -B com.d0dg3r.gitsyncmarks

# Step 4: Validate submit metadata (no pre-releases)
SUBMIT_FILE="$PROJECT_DIR/fdroid/metadata/com.d0dg3r.gitsyncmarks-fdroid-submit.yml"
echo "4. Validating submit metadata (no pre-releases allowed)..."
if grep -E '(CurrentVersion|versionName:).*-(beta|alpha|rc|test|dev)[.-]' "$SUBMIT_FILE" >/dev/null 2>&1; then
  echo "   ERROR: Submit metadata contains pre-release versions (-beta, -alpha, -rc, etc.)."
  echo "   F-Droid accepts only stable releases. Fix $SUBMIT_FILE and try again."
  exit 1
fi
echo "   OK: Only stable versions in submit metadata."

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
  git commit -m "New App: com.d0dg3r.gitsyncmarks"
fi

# Step 7: Push
echo "7. Pushing to GitLab..."
git push -u origin com.d0dg3r.gitsyncmarks

echo ""
echo "Done. Create merge request:"
echo "   https://gitlab.com/${GITLAB_USER}/fdroiddata/-/merge_requests/new?merge_request%5Bsource_branch%5D=com.d0dg3r.gitsyncmarks"
echo ""
echo "Or open: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new"
echo "and select branch 'com.d0dg3r.gitsyncmarks' from your fork."
