// Port of lib/services/storage_service.dart + lib/models/app_settings.dart (settings persistence).
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface AppSettings {
  isDarkMode: boolean;
  masterVolume: number;
  enableBackgroundPlay: boolean;
  enableNotifications: boolean;
  defaultSleepTimer: number; // minutes
  enableFadeInOut: boolean;
  fadeInDuration: number; // seconds
  fadeOutDuration: number; // seconds
  enableGrainOverlay: boolean;
  grainIntensity: number;
  accentColor: string;
  isOnboardingCompleted: boolean;
  /** Liquid Glass rendering quality: full optics, frosted (no lens), or solid materials. */
  glassQuality: 'liquid' | 'frosted' | 'solid';
}

export const DEFAULT_SETTINGS: AppSettings = {
  isDarkMode: true,
  masterVolume: 0.8,
  enableBackgroundPlay: true,
  enableNotifications: true,
  defaultSleepTimer: 30,
  enableFadeInOut: false,
  fadeInDuration: 3,
  fadeOutDuration: 5,
  enableGrainOverlay: true,
  grainIntensity: 0.3,
  accentColor: 'moss',
  isOnboardingCompleted: false,
  glassQuality: 'liquid',
};

const SETTINGS_KEY = 'arcadia.app_settings';

/**
 * Loads persisted settings. Returns null when nothing has been stored yet (first launch of the
 * React Native build), so the caller can apply the Flutter-upgrade rule.
 */
export async function loadSettings(): Promise<AppSettings | null> {
  try {
    const raw = await AsyncStorage.getItem(SETTINGS_KEY);
    if (!raw) return null;
    return { ...DEFAULT_SETTINGS, ...JSON.parse(raw) };
  } catch (e) {
    console.warn('Error loading settings', e);
    return null;
  }
}

export async function saveSettings(settings: AppSettings): Promise<void> {
  try {
    await AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
  } catch (e) {
    console.warn('Error saving settings', e);
  }
}

export async function clearAllData(): Promise<void> {
  await AsyncStorage.clear();
  await saveSettings(DEFAULT_SETTINGS);
}
