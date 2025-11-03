# Quick Fix for Git Large Files Error

## Immediate Solution

The following commands will fix the push error:

### Step 1: Remove problematic files from git tracking

```powershell
# Remove heap dump (should never be committed)
git rm --cached android/java_pid29444.hprof

# Remove large audio file (88MB - exceeds GitHub recommendation)
git rm --cached assets/sounds/tavern.mp3

# Commit the .gitignore update
git add .gitignore
git commit -m "Remove large files from repository and update .gitignore"
```

### Step 2: Push to GitHub

```powershell
git push origin main
```

## What Happened?

- ✅ **Heap dump removed**: `.hprof` files are now ignored (debug artifacts)
- ⚠️ **Audio file removed from git**: `tavern.mp3` is too large for GitHub

## Next Steps: Handle Large Audio Files

You have 3 options for the `tavern.mp3` file:

### Option 1: Use Git LFS (Recommended)
```powershell
# Install Git LFS: https://git-lfs.github.com/
git lfs install
git lfs track "assets/sounds/*.mp3"
git add .gitattributes
git add assets/sounds/tavern.mp3
git commit -m "Add large files to Git LFS"
git push origin main
```

### Option 2: Host Separately
- Upload to Firebase Storage, AWS S3, or CDN
- Download on first app launch
- Update code to download from URL

### Option 3: Compress Audio
- Compress `tavern.mp3` to reduce file size
- Use tools like Audacity or FFmpeg
- Target: < 50MB

## Important Notes

⚠️ **If files are already in git history**, you'll need to rewrite history:
```powershell
# Use git filter-branch (SLOW but works)
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch android/java_pid29444.hprof assets/sounds/tavern.mp3" --prune-empty --tag-name-filter cat -- --all

# Force push (ONLY if you're the only one working on the repo)
git push origin main --force
```

**WARNING**: Force push rewrites history. Only do this if:
- You're the only contributor, OR
- You've coordinated with your team

