@echo off
echo ========================================
echo Git LFS Setup for Large Files
echo ========================================
echo.

echo Step 1: Installing Git LFS (if not already installed)...
git lfs version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git LFS is not installed!
    echo Please download and install from: https://git-lfs.github.com/
    echo After installation, run this script again.
    pause
    exit /b 1
)

echo Git LFS is installed.
echo.

echo Step 2: Initializing Git LFS...
git lfs install
echo.

echo Step 3: Tracking large media files...
git lfs track "assets/sounds/*.mp3"
git lfs track "assets/animated_backgrounds/*.mp4"
echo.

echo Step 4: Adding .gitattributes...
git add .gitattributes
echo.

echo Step 5: Re-adding large files to Git LFS...
git add assets/sounds/tavern.mp3
echo.

echo ========================================
echo Setup complete!
echo.
echo Next steps:
echo 1. Commit these changes: git commit -m "Setup Git LFS for large files"
echo 2. Push to remote: git push origin main
echo ========================================
pause

