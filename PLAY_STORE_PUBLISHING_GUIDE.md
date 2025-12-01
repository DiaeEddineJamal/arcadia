# Google Play Store Publishing Guide

## ✅ You're Verified! Next Steps

Congratulations on getting verified on the Play Store console! Here's your step-by-step guide to publish Arcadia.

---

## Step 1: Create Your App in Play Console

1. **Go to Play Console**: https://play.google.com/console
2. **Click "Create app"**
3. **Fill in the details**:
   - **App name**: `Arcadia`
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
   - **Declarations**: Check all required boxes (Privacy Policy, Content Guidelines, etc.)

---

## Step 2: Build Your Release Bundle (AAB)

Google Play requires an **Android App Bundle (AAB)** for new apps. Here's how to build it:

### Option A: Build from Command Line (Recommended)

```bash
# Navigate to your project directory
cd C:\Users\PC\Desktop\arcadia

# Build the release AAB
flutter build appbundle --release
```

The AAB file will be located at:
```
build\app\outputs\bundle\release\app-release.aab
```

### Option B: Build APK (for testing only)

If you want to test first with an APK:
```bash
flutter build apk --release
```

**Note**: For production, you MUST use AAB format.

---

## Step 3: Complete Store Listing

In Play Console, go to **Store presence > Main store listing** and fill in:

### Required Information:

1. **App name**: `Arcadia`
2. **Short description** (80 characters max):
   ```
   Immersive ambient sound mixer for focus, relaxation, and sleep.
   ```

3. **Full description** (4000 characters max):
   ```
   Arcadia - Your Personal Ambient Soundscape Creator

   Create perfect ambient soundscapes for focus, sleep, and relaxation. Mix unlimited sounds together to craft your ideal environment.

   ✨ KEY FEATURES:
   • Mix unlimited ambient sounds simultaneously
   • Individual volume controls for each sound
   • Sleep timer with automatic fade-out
   • 15+ high-quality ambient sounds
   • Background playback support
   • Beautiful glassmorphism design
   • Dark and light themes
   • Completely offline - no internet required

   🌿 SOUND CATEGORIES:
   • Rain (Light, Heavy, Thunder)
   • Ocean Waves
   • Forest with wildlife
   • Wind
   • Fireplace
   • White/Pink/Brown Noise
   • Fantasy (Pirates, Tavern, Tavern Singing)

   ⏰ SLEEP TIMER:
   Set custom timer duration with automatic fade-out to help you fall asleep naturally.

   🎨 BEAUTIFUL DESIGN:
   Modern glassmorphism UI with animated video backgrounds. Smooth animations optimized for high refresh rate displays.

   ⚡ PERFORMANCE:
   Optimized audio mixing engine with low battery consumption. Efficient memory usage for smooth operation.

   Perfect for:
   • Focus & Productivity
   • Sleep & Relaxation
   • Meditation & Mindfulness
   • Studying
   • Tinnitus Relief
   • Work Environment Masking

   Start creating your perfect soundscape today!
   ```

4. **App icon**: Upload `assets/icon/APPICON.png` (512x512px required)
5. **Feature graphic**: Create a 1024x500px banner (optional but recommended)
6. **Screenshots**: 
   - Phone: At least 2 screenshots (recommended: 4-8)
   - Tablet: Optional but recommended
   - Minimum dimensions: 320px - 3840px
   - Recommended: 1080x1920px for phones

7. **Privacy Policy URL**: 
   - You'll need to host your privacy policy online
   - Options:
     - GitHub Pages (free)
     - Your own website
     - Google Sites
   - Upload `PRIVACY_POLICY.md` content to your chosen host

---

## Step 4: Set Up App Content

### Content Rating

1. Go to **Policy > App content**
2. Complete the **Content rating questionnaire**
3. Answer questions about your app (it's a sound/music app, no violence, etc.)

### Target Audience

1. Go to **Policy > Target audience and content**
2. Select appropriate age groups
3. Answer content questions

### Data Safety

1. Go to **Policy > Data safety**
2. Fill out the data safety form:
   - **Data collection**: Yes (for AdMob)
   - **Data types collected**:
     - Device ID
     - Advertising ID
     - App interactions
   - **Data sharing**: Yes (with Google AdMob)
   - **Data security**: Describe your security practices

---

## Step 5: Upload Your App Bundle

1. Go to **Production** (or **Testing > Internal testing** for testing first)
2. Click **Create new release**
3. **Upload your AAB file**: `build\app\outputs\bundle\release\app-release.aab`
4. **Release name**: `1.0.1 (1)` (matches your version in pubspec.yaml)
5. **Release notes** (for users):
   ```
   Version 1.0.1 - Initial Release
   
   ✨ Create custom ambient soundscapes
   🎵 Mix unlimited sounds simultaneously
   🌿 Rich collection of nature sounds
   ⏰ Sleep timer with fade-out
   🎨 Beautiful glassmorphism design
   ⚡ Optimized performance
   🌙 Background playback
   📱 Completely offline
   ```

---

## Step 6: Review and Submit

1. **Review all sections**:
   - ✅ Store listing complete
   - ✅ App bundle uploaded
   - ✅ Content rating done
   - ✅ Data safety form completed
   - ✅ Privacy policy URL added

2. **Click "Review release"**
3. **Fix any issues** if flagged
4. **Click "Start rollout to Production"** (or submit for review)

---

## Step 7: Testing (Recommended Before Production)

Before going to production, test your app:

1. **Create an Internal Testing track**:
   - Go to **Testing > Internal testing**
   - Create a release
   - Upload your AAB
   - Add testers (your email)
   - Share the testing link

2. **Test the app** on a real device
3. **Fix any issues** before production release

---

## Important Checklist

Before submitting, ensure:

- [ ] App builds successfully (`flutter build appbundle --release`)
- [ ] App runs without crashes
- [ ] Privacy policy is hosted and accessible online
- [ ] All required store listing fields are filled
- [ ] Screenshots are uploaded (at least 2)
- [ ] App icon is uploaded (512x512px)
- [ ] Content rating is completed
- [ ] Data safety form is completed
- [ ] Release notes are written
- [ ] Version number matches pubspec.yaml (1.0.1+1)
- [ ] Keystore is secure and backed up

---

## Common Issues & Solutions

### Issue: "App bundle is too large"
- **Solution**: Enable ProGuard/R8 minification in `android/app/build.gradle.kts`:
  ```kotlin
  release {
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
  }
  ```

### Issue: "Missing privacy policy"
- **Solution**: Host your privacy policy online and add the URL in store listing

### Issue: "Version code already used"
- **Solution**: Increment version in `pubspec.yaml`:
  ```yaml
  version: 1.0.2+2  # Increment both numbers
  ```

### Issue: "App signing key"
- **Solution**: Your keystore is already configured. Make sure `key.properties` is correct and keystore file exists at the specified path.

---

## Timeline Expectations

- **Review time**: Usually 1-7 days (can be longer for first submission)
- **Status updates**: Check Play Console regularly
- **Rejections**: Common for first-time submissions - address feedback and resubmit

---

## After Submission

1. **Monitor Play Console** for review status
2. **Respond to any feedback** quickly
3. **Check email** for notifications
4. **Once approved**: Your app will be live on Google Play!

---

## Next Steps After Going Live

1. Monitor crash reports in Play Console
2. Respond to user reviews
3. Plan future updates
4. Consider setting up analytics (Firebase Analytics, etc.)

---

## Need Help?

- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **Flutter Documentation**: https://docs.flutter.dev/deployment/android
- **Google Play Policies**: https://play.google.com/about/developer-content-policy/

---

Good luck with your launch! 🚀

