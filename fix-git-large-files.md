# Fix Git Large Files Issue

## Problem
- `android/java_pid29444.hprof` (999.69 MB) - exceeds GitHub's 100 MB limit
- `assets/sounds/tavern.mp3` (88.54 MB) - exceeds GitHub's 50 MB recommendation

## Solution Steps

### Step 1: Remove heap dump file from git history
The `.hprof` file is a debug/profiling artifact and should NOT be in the repository.

```bash
# Remove from current working directory (already ignored)
# If file exists in git history, use one of these methods:

# Method 1: Using git filter-repo (recommended - install first: pip install git-filter-repo)
git filter-repo --path android/java_pid29444.hprof --invert-paths

# Method 2: Using BFG Repo-Cleaner (faster, download from https://rtyley.github.io/bfg-repo-cleaner/)
# java -jar bfg.jar --delete-files java_pid29444.hprof
# git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Method 3: Using git filter-branch (native but slower)
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch android/java_pid29444.hprof" --prune-empty --tag-name-filter cat -- --all
```

### Step 2: Handle large audio files
You have two options:

#### Option A: Use Git LFS (Large File Storage) - Recommended for large assets
```bash
# Install Git LFS first: https://git-lfs.github.com/
git lfs install

# Track large audio files
git lfs track "assets/sounds/*.mp3"
git lfs track "assets/animated_backgrounds/*.mp4"

# Add .gitattributes file
git add .gitattributes

# Re-add the files
git add assets/sounds/tavern.mp3
git commit -m "Add large files to Git LFS"
```

#### Option B: Remove large files from repo and document them
```bash
# Remove from git (keep local files)
git rm --cached assets/sounds/tavern.mp3
git rm --cached assets/animated_backgrounds/*.mp4

# Add note in README or create ASSETS.md
# Commit the removal
git commit -m "Remove large media files from git repository"
```

### Step 3: Force push (ONLY after fixing history)
```bash
# WARNING: This rewrites history. Only do this if you're sure!
git push origin main --force
```

## Recommended Approach

**Best solution**: Use Git LFS for large media files
1. Install Git LFS: https://git-lfs.github.com/
2. Track large files: `git lfs track "assets/**/*.{mp3,mp4}"`
3. Remove files from regular git and re-add them
4. Commit and push

## Quick Fix Commands

If you want a quick fix right now:

```bash
# 1. Delete the heap dump file (it's already ignored)
Remove-Item -Force android/java_pid29444.hprof -ErrorAction SilentlyContinue

# 2. Remove large audio files from git tracking
git rm --cached assets/sounds/tavern.mp3
git rm --cached "assets/animated_backgrounds/*.mp4"

# 3. Commit the .gitignore update
git add .gitignore
git commit -m "Update .gitignore to exclude heap dumps and large files"

# 4. Push (if no other large files in history)
git push origin main
```

## Alternative: Use External Storage

For very large assets, consider:
- Hosting audio/video files on a CDN (Cloudflare, AWS S3)
- Using Firebase Storage
- Including download instructions in README
- Using asset bundles that download on first run

