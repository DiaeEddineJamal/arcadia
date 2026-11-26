// Port of lib/providers/app_settings_provider.dart and the Provider wiring in lib/main.dart.
import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { AppState } from 'react-native';
import { Sound } from '../data/sounds';
import { AppInfo, EMPTY_MIXER_STATE, Mixer, MixerState } from '../services/mixer';
import {
  AppSettings,
  clearAllData,
  DEFAULT_SETTINGS,
  loadSettings,
  saveSettings,
} from '../services/storage';
import { accentFor, normalizeAccentKey } from '../design/tokens';

interface AppContextValue {
  ready: boolean;
  settings: AppSettings;
  /** Current accent colour value. */
  accent: string;
  mixer: MixerState;
  appInfo: AppInfo;
  updateSettings: (patch: Partial<AppSettings>) => void;
  resetAllData: () => Promise<void>;
  // Mixer actions
  ensureLoaded: (sound: Sound) => void;
  toggleSound: (sound: Sound) => void;
  playSound: (sound: Sound, volume?: number) => void;
  removeSound: (id: string) => void;
  setSoundVolume: (id: string, volume: number) => void;
  setMasterVolume: (volume: number) => void;
  pauseAll: () => void;
  resumeAll: () => void;
  setSleepTimer: (minutes: number) => void;
  isPlaying: (id: string) => boolean;
}

const AppContext = createContext<AppContextValue | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [ready, setReady] = useState(false);
  const [settings, setSettings] = useState<AppSettings>(DEFAULT_SETTINGS);
  const [mixer, setMixer] = useState<MixerState>(EMPTY_MIXER_STATE);
  const [appInfo, setAppInfo] = useState<AppInfo>({
    version: '',
    buildNumber: '',
    hasLegacyFlutterData: false,
  });
  const settingsRef = useRef(settings);
  settingsRef.current = settings;
  // Tracks currently queued (loaded) in the native mixer, so we only load once.
  const loadedRef = useRef(new Set<string>());

  useEffect(() => {
    let mounted = true;
    const unsubscribe = Mixer.subscribe(state => {
      loadedRef.current = new Set(state.tracks.map(t => t.id));
      if (mounted) setMixer(state);
    });
    (async () => {
      const info = await Mixer.getAppInfo().catch(() => null);
      let stored = await loadSettings();
      if (!stored) {
        // First launch of the React Native build. If this device is upgrading from the Flutter
        // build (its Hive files are still on disk) the user has already seen onboarding.
        stored = { ...DEFAULT_SETTINGS, isOnboardingCompleted: !!info?.hasLegacyFlutterData };
        await saveSettings(stored);
      }
      stored = { ...stored, accentColor: normalizeAccentKey(stored.accentColor) };
      const state = await Mixer.getState().catch(() => EMPTY_MIXER_STATE);
      if (!mounted) return;
      if (info) setAppInfo(info);
      loadedRef.current = new Set(state.tracks.map(t => t.id));
      setMixer(state);
      setSettings(stored);
      setReady(true);
    })();
    return () => {
      mounted = false;
      unsubscribe();
    };
  }, []);

  // applyAppSettings(): keep the native mixer in sync with persisted settings.
  useEffect(() => {
    if (!ready) return;
    Mixer.setMasterVolume(settings.masterVolume);
  }, [ready, settings.masterVolume]);

  useEffect(() => {
    if (!ready) return;
    Mixer.setFadeConfig(settings.enableFadeInOut, settings.fadeInDuration, settings.fadeOutDuration);
  }, [ready, settings.enableFadeInOut, settings.fadeInDuration, settings.fadeOutDuration]);

  // Background playback toggle: when disabled, pause the mix while the app is in the background.
  const pausedForBackground = useRef(false);
  useEffect(() => {
    const sub = AppState.addEventListener('change', next => {
      if (next === 'background' && !settingsRef.current.enableBackgroundPlay) {
        pausedForBackground.current = true;
        Mixer.pauseAll();
      } else if (next === 'active' && pausedForBackground.current) {
        pausedForBackground.current = false;
        Mixer.resumeAll();
      }
    });
    return () => sub.remove();
  }, []);

  const updateSettings = useCallback((patch: Partial<AppSettings>) => {
    setSettings(prev => {
      const next = { ...prev, ...patch };
      saveSettings(next);
      return next;
    });
  }, []);

  const resetAllData = useCallback(async () => {
    await clearAllData();
    setSettings(DEFAULT_SETTINGS);
  }, []);

  const ensureLoaded = useCallback((sound: Sound) => {
    if (loadedRef.current.has(sound.id)) return;
    loadedRef.current.add(sound.id);
    Mixer.load(sound.id, sound.fileName, sound.name, sound.defaultVolume);
  }, []);

  const isPlaying = useCallback(
    (id: string) => mixer.tracks.some(t => t.id === id && t.playing),
    [mixer.tracks],
  );

  const toggleSound = useCallback(
    (sound: Sound) => {
      ensureLoaded(sound);
      if (mixer.tracks.some(t => t.id === sound.id && t.playing)) Mixer.pause(sound.id);
      else Mixer.play(sound.id);
    },
    [ensureLoaded, mixer.tracks],
  );

  const playSound = useCallback(
    (sound: Sound, volume?: number) => {
      ensureLoaded(sound);
      if (volume !== undefined) Mixer.setVolume(sound.id, volume);
      Mixer.play(sound.id);
    },
    [ensureLoaded],
  );

  const removeSound = useCallback((id: string) => {
    loadedRef.current.delete(id);
    Mixer.remove(id);
  }, []);

  const setMasterVolume = useCallback(
    (volume: number) => {
      Mixer.setMasterVolume(volume);
      updateSettings({ masterVolume: volume });
    },
    [updateSettings],
  );

  const value = useMemo<AppContextValue>(
    () => ({
      ready,
      settings,
      accent: accentFor(settings.accentColor),
      mixer,
      appInfo,
      updateSettings,
      resetAllData,
      ensureLoaded,
      toggleSound,
      playSound,
      removeSound,
      setSoundVolume: (id, v) => Mixer.setVolume(id, v),
      setMasterVolume,
      pauseAll: () => Mixer.pauseAll(),
      resumeAll: () => Mixer.resumeAll(),
      setSleepTimer: m => Mixer.setSleepTimer(m),
      isPlaying,
    }),
    [
      ready,
      settings,
      mixer,
      appInfo,
      updateSettings,
      resetAllData,
      ensureLoaded,
      toggleSound,
      playSound,
      removeSound,
      setMasterVolume,
      isPlaying,
    ],
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used inside AppProvider');
  return ctx;
}

