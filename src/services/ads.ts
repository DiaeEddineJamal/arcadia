// Port of lib/services/ad_service.dart + lib/utils/ad_helper.dart
import { Platform } from 'react-native';
import mobileAds, { AdEventType, InterstitialAd, TestIds } from 'react-native-google-mobile-ads';

/**
 * Ads are switched off for now (requested during the redesign). Flip to true to restore the
 * home/settings banners and the Sounds interstitial exactly as they were configured.
 */
export const ADS_ENABLED = false;

const INTERSTITIAL_COOLDOWN_MS = 2 * 60 * 1000;

// Same ad unit IDs as the Flutter app. iOS still uses Google's test units there (TODO in
// ad_helper.dart), so this does too. Debug builds use test units so development traffic never
// hits the real AdMob account.
const UNITS = {
  homeBanner: Platform.select({
    android: 'ca-app-pub-6329609540816457/3905620831',
    default: 'ca-app-pub-3940256099942544/2934735716',
  })!,
  settingsBanner: Platform.select({
    android: 'ca-app-pub-6329609540816457/1648258626',
    default: 'ca-app-pub-3940256099942544/2934735716',
  })!,
  libraryInterstitial: Platform.select({
    android: 'ca-app-pub-6329609540816457/8798854867',
    default: 'ca-app-pub-3940256099942544/4411468910',
  })!,
};

export const AdUnits = {
  homeBanner: __DEV__ ? TestIds.BANNER : UNITS.homeBanner,
  settingsBanner: __DEV__ ? TestIds.BANNER : UNITS.settingsBanner,
  libraryInterstitial: __DEV__ ? TestIds.INTERSTITIAL : UNITS.libraryInterstitial,
};

let initialized = false;
let interstitial: InterstitialAd | null = null;
let interstitialLoaded = false;
let lastInterstitialShownAt = 0;
let retryTimer: ReturnType<typeof setTimeout> | null = null;

function preloadLibraryInterstitial() {
  if (!initialized) return;
  interstitialLoaded = false;
  const ad = InterstitialAd.createForAdRequest(AdUnits.libraryInterstitial);
  ad.addAdEventListener(AdEventType.LOADED, () => {
    interstitialLoaded = true;
  });
  ad.addAdEventListener(AdEventType.ERROR, () => {
    interstitialLoaded = false;
    interstitial = null;
    if (retryTimer) clearTimeout(retryTimer);
    retryTimer = setTimeout(preloadLibraryInterstitial, 30_000);
  });
  ad.addAdEventListener(AdEventType.CLOSED, () => {
    lastInterstitialShownAt = Date.now();
    interstitial = null;
    preloadLibraryInterstitial();
  });
  interstitial = ad;
  ad.load();
}

export async function initializeAds(): Promise<void> {
  if (!ADS_ENABLED || initialized) return;
  try {
    await mobileAds().initialize();
    initialized = true;
    preloadLibraryInterstitial();
  } catch (e) {
    console.warn('Mobile Ads initialization failed', e);
  }
}

/** Shown when the user opens the Library tab, at most once every 2 minutes. */
export function maybeShowLibraryInterstitial(): void {
  if (!ADS_ENABLED) return;
  if (!interstitial || !interstitialLoaded) return;
  if (lastInterstitialShownAt && Date.now() - lastInterstitialShownAt < INTERSTITIAL_COOLDOWN_MS) {
    return;
  }
  const ad = interstitial;
  interstitialLoaded = false;
  ad.show().catch(() => {
    interstitial = null;
    preloadLibraryInterstitial();
  });
}
