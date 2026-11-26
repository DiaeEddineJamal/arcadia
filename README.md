# Arcadia — React Native

React Native (0.88, bare CLI, TypeScript) app. It replaces the earlier Flutter app (removed from
this repo; it's in the git history before the `react-native-migration` branch) on Google Play:
same name, same package / bundle id (`com.Luziv.arcadia`), same AdMob IDs, same upload key.
The privacy and data-transfer documents at the root (`PRIVACY_POLICY.md` and others) still apply.

> **Design:** redesigned (Portal-inspired, with a native Liquid Glass renderer). See
> [LIQUID_GLASS.md](LIQUID_GLASS.md) for the rendering engine, [ASSETS_NEEDED.md](ASSETS_NEEDED.md)
> for the imagery and icon that are still missing, and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
> **Ads are switched off** (`ADS_ENABLED = false` in `src/services/ads.ts`).

## Layout

| Path | What |
| --- | --- |
| `App.tsx` | Root: onboarding vs main navigation |
| `src/glass/` | Liquid Glass JS API (`<GlassBackdrop>`, `<Glass>`, materials, quality) |
| `src/design/` | Tokens (colour, type, spacing, motion) and primitives (text, icons, slider, toggle) |
| `src/state/AppContext.tsx` | Settings (persisted) + mixer state + actions (replaces the Provider tree) |
| `src/services/mixer.ts` | JS bridge to the native mixer |
| `src/services/storage.ts` | Persisted `AppSettings` (AsyncStorage) |
| `src/services/ads.ts` | AdMob init, ad unit IDs, library interstitial with 2-min cooldown |
| `src/data/sounds.ts` | Sound catalogue, categories, icons, colours |
| `src/screens/*` | Onboarding, Listen (the scene), Sounds, Settings, MainNavigation (shell) |
| `src/components/*` | Scene, tab bar, transport, mini player, mixer and timer sheets, dialog, toast |
| `android/app/src/main/java/com/Luziv/arcadia/glass/` | Native Liquid Glass renderer (RenderNode + AGSL) |
| `android/app/src/main/java/com/Luziv/arcadia/mixer/` | Native ambient mixer (Kotlin, Media3) |
| `android/app/src/main/java/com/Luziv/arcadia/MainActivity.kt` | High refresh rate |
| `assets/native/{sounds,fonts}` | Packed as Android assets (sounds are played natively) |
| `assets/videos`, `assets/images`, `assets/icon` | Bundled through Metro (`*.mp3` / `*.mp4` via Git LFS) |
| `assets/videos/pinterest-unlicensed/`, `src/data/sceneVideos.local.ts` | Placeholder Listen clips, **gitignored** (unlicensed; the repo is public). Without them each place shows its photograph |
| `patches/` | patch-package fixes for dependencies (react-native-video TextureView) |

## Run (Android)

Requirements: Node ≥ 22.11, JDK 17, Android SDK (compileSdk 37), a device or emulator.

```powershell
npm install                       # also re-applies patches/ (patch-package)
npx react-native run-android      # builds the debug APK, installs it and starts Metro
```

Debug builds use Google's **test** ad units so development traffic never hits the real AdMob
account; release builds use the real units.

Debug APK only: `cd android; .\gradlew.bat assembleDebug` → `android/app/build/outputs/apk/debug/app-debug.apk`.

## Release build (Google Play)

Version: **1.0.2 / versionCode 2** (the Flutter build on Play is 1.0.1+1). Bump `versionCode` /
`versionName` in `android/app/build.gradle` for every upload (iOS: `MARKETING_VERSION` /
`CURRENT_PROJECT_VERSION` in the Xcode project).

Signing reuses the existing upload keystore (the one the Flutter build used) through `key.properties` (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`). The build looks for it, in order, at:

1. `-ParcadiaKeyProperties=<path>` or the `ARCADIA_KEY_PROPERTIES` environment variable
2. `android/key.properties`

A relative `storeFile` is resolved next to `key.properties`, then inside its `app/` folder (the
Flutter convention); an absolute path is used as-is. Release tasks **fail with a clear message**
if no `key.properties` is found, so an AAB signed with the wrong key can't be produced by accident.
`key.properties`, `*.jks` and `*.keystore` are git-ignored.

```powershell
cd android
.\gradlew.bat bundleRelease
# → android/app/build/outputs/bundle/release/app-release.aab  (upload to the existing Play listing)
```

## How the Flutter features map

| Flutter | React Native |
| --- | --- |
| `audioplayers` + `AudioPlayerService` (one looping player per sound, per-sound × master volume, fades, pause/resume all, sleep timer) | Native `MixerEngine` (Kotlin): one Media3 `ExoPlayer` per sound with `REPEAT_MODE_ONE`, same volume/fade/pause-all/sleep-timer rules. The sleep timer and its fade-out run natively, so they still work with the app in the background |
| `audio_service` + `AppAudioHandler` (notification / lock-screen controls) | `MixerPlaybackService` (Media3 `MediaSessionService`, channel "Arcadia Audio") with a facade player: play/pause all + Stop button; swiping the app away stops playback (`stopWithTask`) |
| Hive (`StorageService`) | AsyncStorage (`src/services/storage.ts`) |
| `AppSettingsProvider` | `AppContext` |
| `video_player` backgrounds | `react-native-video` (muted, looping, paused in background); falls back to `static_main.jpg` with a retry button if the video fails |
| `flutter_displaymode` | `MainActivity.preferHighestRefreshRate()` (highest refresh-rate mode at the current resolution, re-applied on resume) |
| `google_mobile_ads` | `react-native-google-mobile-ads` — home banner, settings banner (LARGE_BANNER, slot hidden until loaded), library interstitial (2-min cooldown, 30 s retry) |
| `google_fonts` Modern Antiqua (downloaded at runtime) | Bundled `ModernAntiqua-Regular.ttf` (works offline) |
| `permission_handler` (notifications) | `PermissionsAndroid` POST_NOTIFICATIONS at the end of onboarding |
| `package_info_plus` | Native `getAppInfo()` |
| Material icons | Lucide (`@react-native-vector-icons/lucide`), one consistent stroke family |

## Not carried over one-to-one

- **User data from the Flutter build isn't migrated.** Hive files aren't readable from JS. On the
  first launch after the update, the app detects the old Flutter data (`app_flutter/*.hive`) and
  **skips onboarding**, but the accent colour, volume and other settings go back to their defaults.
- **Saved mixes**: the Flutter app had a Hive "mixes" box but no UI to create mixes, so nothing was ported.
- **Removed in the redesign**: the "coming soon" rows (export/import, privacy, terms, rate), the "Premium"/"Spécial" badges (nothing to buy), the grain overlay, and the light theme (it had no toggle in Flutter either).
- **Renamed**: "Pirates of the Caribbean" is shown as "Pirate Ship" (a film title); see ASSETS_NEEDED.md about that recording's licence.
- **Background-playback toggle off**: the mix pauses when the app goes to the background and resumes when it comes back.
- **Notification**: Media3's default media notification (play/pause + Stop) instead of `audio_service`'s. Pausing from the notification keeps it visible so playback can be resumed.
- **Permissions**: `SCHEDULE_EXACT_ALARM` and `FOREGROUND_SERVICE_SPECIAL_USE` were dropped because nothing used them (the sleep timer runs inside the media service). If the Play Console declarations still list them, they can be removed there.
- **Data → Export/Import, Privacy Policy, Terms, Rate**: still "Coming soon" dialogs, as in Flutter.
- **iOS**: the Xcode project has the bundle id, versions, app icons, AdMob app id and the `audio` background mode, but the
  native mixer is **Android-only for now**. On iOS the JS bridge is a no-op, so there's no audio. Before an
  iOS release this needs a Swift `ArcadiaMixer` module (AVAudioPlayer per sound + `MPRemoteCommandCenter`),
  plus the sounds/fonts added to the Xcode bundle resources. It
  couldn't be built or tested on this Windows machine.

## Windows notes

If a native (CMake) step fails on a long path, map the repo to a drive letter and build from
there: `subst R: "<repo>"`.

## Verified on 2026-11-25 (Windows, Samsung test phone)

- `assembleDebug` succeeded; the debug APK was installed and run on the phone. Checked: onboarding (videos,
  font, notification permission), Home, Library (category filter, sound cards, interstitial on first
  open), Settings (accent persisted across a force-stop), banner ads (test units).
- Mixer: two sounds played together alongside another app's music; playback continued with the app in the
  background; the foreground media service (`mediaPlayback`, channel `arcadia_audio`) showed the
  notification; system play/pause/stop media commands worked.
- `bundleRelease` without `key.properties` fails with the intended message. With a throwaway test
  keystore passed via `-ParcadiaKeyProperties`, it produced a signed AAB (`jarsigner` verified) with
  `package=com.Luziv.arcadia`, `versionCode=2`, `versionName=1.0.2`, the real AdMob app id and all 15
  sounds. That test AAB was deleted. **No build has been signed with the real upload key yet**, because
  `key.properties` isn't on this machine.
- Not tested: sleep-timer expiry, fade in/out by ear, light mode (there's no toggle in the UI, same as Flutter), iOS.

## Redesign checks (2026-11-25, Galaxy S25 Ultra, Android 16 / API 37)

- `tsc` clean, `eslint` 0 errors (3 inline-style warnings), `jest` 1/1 passing (the App smoke test, with native modules mocked in `jest.setup.js`).
- Debug build (arm64) installed and checked on the phone: onboarding, Listen, Sounds, Settings, mixer and timer sheets, reset dialog, timer countdown and chip.
- Liquid Glass verified on-device: page content passing under the tab bar, the mini player and the sheets shows through refracted and blurred, with rim lighting, and the pill moves with the selected tab.
- Not checked: the Frosted and Solid tiers on a device, an Android 12 or older phone, TalkBack end to end, a release build of the redesign.

## Patched dependency: react-native-video

react-native-video 6.19.3 always renders video on a SurfaceView on Android (`viewType` is
ignored), which breaks the scene's fades, clipping and Liquid Glass. Two edits in
`node_modules/react-native-video/android/src/main/`:

- new `res/layout/rnv_texture_player_view.xml`: a `androidx.media3.ui.PlayerView` with
  `app:surface_type="texture_view"`;
- `java/com/brentvatne/exoplayer/ExoPlayerView.kt`: `playerView` is inflated from that layout
  instead of `PlayerView(context)`.

The edits are kept in `patches/react-native-video+6.19.3.patch` and re-applied by
patch-package on every `npm install` (`"postinstall": "patch-package"`). After upgrading
react-native-video, check whether it now honours `viewType` and drop the patch if so.

On Windows with Node 24, `npx patch-package <name>` (creating a patch) fails because it can't
spawn npm; applying patches works. To regenerate the patch, diff a pristine copy
(`npm pack react-native-video@<version>`) against `node_modules` with `git diff --no-index`.
