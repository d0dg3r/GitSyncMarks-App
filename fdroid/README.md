# F-Droid Submission

This folder contains metadata for submitting GitSyncMarks-Mobile to [F-Droid](https://f-droid.org/).

## One-command submission (GitLab + SSH)

1. Fork [fdroiddata](https://gitlab.com/fdroid/fdroiddata) on GitLab (once)
2. Run from the project root:

   ```bash
   chmod +x fdroid/submit-to-gitlab.sh
   ./fdroid/submit-to-gitlab.sh YOUR_GITLAB_USER
   ```

   Replace `YOUR_GITLAB_USER` with your GitLab username (e.g. `d0dg3r`).

3. Open the MR link printed at the end, or go to [New Merge Request](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new) and select branch `com.d0dg3r.gitsyncmarks` from your fork.

## Manual submission

1. Fork [fdroiddata](https://gitlab.com/fdroid/fdroiddata) on GitLab
2. Clone your fork, create branch:
   ```bash
   git clone --depth=1 git@gitlab.com:YOUR_USER/fdroiddata ~/fdroiddata
   cd ~/fdroiddata
   git checkout -b com.d0dg3r.gitsyncmarks
   ```
3. Copy metadata: `cp /path/to/GitSyncMarks-Mobile/fdroid/metadata/com.d0dg3r.gitsyncmarks.yml metadata/`
4. Commit and push: `git add metadata/com.d0dg3r.gitsyncmarks.yml && git commit -m "New App: com.d0dg3r.gitsyncmarks" && git push -u origin com.d0dg3r.gitsyncmarks`
5. Open a [Merge Request](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new)

## Upstream metadata

The app repository already includes F-Droid-compatible metadata:

- `metadata/en-US/short_description.txt`
- `metadata/en-US/full_description.txt`
- `metadata/en-US/images/icon.png` (512x512)
- `metadata/en-US/images/phoneScreenshots/*.png`
- `metadata/en-US/changelogs/{versionCode}.txt`

F-Droid will automatically use these when building.
