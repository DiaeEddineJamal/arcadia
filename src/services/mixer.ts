// JS side of the native ambient mixer (android/app/src/main/java/com/Luziv/arcadia/mixer,
// ios/Arcadia/ArcadiaMixer.swift). Port of the Flutter AudioPlayerService API.
import { NativeEventEmitter, NativeModules } from 'react-native';

export interface MixerTrack {
  id: string;
  playing: boolean;
  volume: number;
}

export interface MixerState {
  tracks: MixerTrack[];
  isMasterPlaying: boolean;
  masterVolume: number;
  sleepTimerMinutes: number;
  sleepTimerEndsAt: number;
}

export interface AppInfo {
  version: string;
  buildNumber: string;
  hasLegacyFlutterData: boolean;
}

export const EMPTY_MIXER_STATE: MixerState = {
  tracks: [],
  isMasterPlaying: false,
  masterVolume: 0.8,
  sleepTimerMinutes: 0,
  sleepTimerEndsAt: 0,
};

const Native = NativeModules.ArcadiaMixer;

if (!Native) {
  console.warn('ArcadiaMixer native module is not available; audio is disabled.');
}

const noop = () => {};

export const Mixer = {
  load: (id: string, fileName: string, title: string, volume: number) =>
    Native?.load(id, fileName, title, volume),
  play: (id: string) => Native?.play(id),
  pause: (id: string) => Native?.pause(id),
  remove: (id: string) => Native?.remove(id),
  setVolume: (id: string, volume: number) => Native?.setVolume(id, volume),
  setMasterVolume: (volume: number) => Native?.setMasterVolume(volume),
  /** While dragging: audio follows the finger, no state event (avoids an app-wide re-render). */
  setVolumeQuiet: (id: string, volume: number) => Native?.setVolumeQuiet?.(id, volume),
  setMasterVolumeQuiet: (volume: number) => Native?.setMasterVolumeQuiet?.(volume),
  setFadeConfig: (enabled: boolean, fadeIn: number, fadeOut: number) =>
    Native?.setFadeConfig(enabled, fadeIn, fadeOut),
  pauseAll: () => Native?.pauseAll(),
  resumeAll: () => Native?.resumeAll(),
  stopAll: () => Native?.stopAll(),
  setSleepTimer: (minutes: number) => Native?.setSleepTimer(minutes),
  haptic: (kind: 'tap' | 'tick' | 'confirm') => Native?.haptic?.(kind),
  getState: (): Promise<MixerState> =>
    Native ? Native.getState() : Promise.resolve(EMPTY_MIXER_STATE),
  getAppInfo: (): Promise<AppInfo> =>
    Native
      ? Native.getAppInfo()
      : Promise.resolve({ version: '', buildNumber: '', hasLegacyFlutterData: false }),
  subscribe(listener: (state: MixerState) => void): () => void {
    if (!Native) return noop;
    const emitter = new NativeEventEmitter(Native);
    const sub = emitter.addListener('ArcadiaMixerState', state =>
      listener(state as unknown as MixerState),
    );
    return () => sub.remove();
  },
};
