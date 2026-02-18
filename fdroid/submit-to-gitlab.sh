#!/usr/bin/env bash
# Submit GitSyncMarks-Mobile to F-Droid via GitLab merge request
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

echo "F-Droid submission for GitSyncMarks-Mobile"
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

# Step 3: Create branch
echo "3. Creating branch com.d0dg3r.gitsyncmarks..."
git checkout -B com.d0dg3r.gitsyncmarks 2>/dev/null || git checkout com.d0dg3r.gitsyncmarks

# Step 4: Copy metadata
echo "4. Copying metadata..."
cp "$PROJECT_DIR/fdroid/metadata/com.d0dg3r.gitsyncmarks.yml" metadata/

# Step 5: Commit
echo "5. Committing..."
git add metadata/com.d0dg3r.gitsyncmarks.yml
if git diff --cached --quiet; then
  echo "   No changes (file may already be committed)"
else
  git commit -m "New App: com.d0dg3r.gitsyncmarks"
fi

# Step 6: Push
echo "6. Pushing to GitLab..."
git push -u origin com.d0dg3r.gitsyncmarks

echo ""
echo "Done. Create merge request:"
echo "   https://gitlab.com/${GITLAB_USER}/fdroiddata/-/merge_requests/new?merge_request%5Bsource_branch%5D=com.d0dg3r.gitsyncmarks"
echo ""
echo "Or open: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new"
echo "and select branch 'com.d0dg3r.gitsyncmarks' from your fork."
