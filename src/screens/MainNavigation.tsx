/**
 * App shell, after BitChord.
 *
 * Layer order (back to front):
 *   1. GlassBackdrop — the scene and the current page. The scene clips carry BitChord's
 *      progressive blur (sharp top, blurred behind the title and controls) baked in.
 *   1b. Immersive (BitChord): a tap on the scene, or IDLE_MS without a touch while sound plays,
 *      lifts the baked blur, drops the title to the foot of the screen and slides the controls
 *      and bar off the bottom with it. Another tap or Back brings them back. Everything glass samples this, so the
 *      bar and player refract the photographs and lists scrolling beneath them.
 *   2. Floating chrome — Listen's controls, the timer chip, and the bottom bar (tabs + player),
 *      which merges into one row while a list is scrolled down.
 *   3. Sheets and dialogs (one at a time).
 *
 * Tab switches are instant, as in BitChord.
 */
import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import {
  Animated,
  BackHandler,
  Easing,
  NativeScrollEvent,
  NativeSyntheticEvent,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { ConfirmDialog } from '../components/ConfirmDialog';
import {
  ListenPlayer,
  listenLayout,
  TimerChip,
} from '../components/ListenControls';
import { MixerSheet } from '../components/MixerSheet';
import { leadClip, Scene, ScenePlace } from '../components/Scene';
import { BottomBar, miniArtRect, Tab } from '../components/TabBar';
import {
  PlayerTransition,
  TransitionState,
} from '../components/PlayerTransition';
import { TimerSheet } from '../components/TimerSheet';
import { useToast } from '../components/Toast';
import { SCENE_IMAGE, SCENE_VIDEO } from '../data/scenes';
import { getSound } from '../data/sounds';
import { useReducedMotion } from '../design/primitives';
import { GlassBackdrop } from '../glass';
import { maybeShowLibraryInterstitial } from '../services/ads';
import { useApp } from '../state/AppContext';
import { useSceneLead } from '../state/useSceneLead';
import { ListenScreen } from './ListenScreen';
import { SettingsScreen } from './SettingsScreen';
import { SoundsScreen } from './SoundsScreen';

type SheetName = 'mixer' | 'timer' | null;
const IDLE_MS = 6000;
export type ScrollHandler = (
  e: NativeSyntheticEvent<NativeScrollEvent>,
) => void;

/** Collapse on a downward scroll past the top; expand on a deliberate upward scroll or near the top. */
function useScrollCollapse(setCollapsed: (v: boolean) => void): ScrollHandler {
  const last = useRef(0);
  const upTravel = useRef(0);
  return useCallback(
    (e: NativeSyntheticEvent<NativeScrollEvent>) => {
      const y = e.nativeEvent.contentOffset.y;
      const dy = y - last.current;
      last.current = y;
      if (y < 48) {
        upTravel.current = 0;
        setCollapsed(false);
        return;
      }
      if (dy > 4) {
        upTravel.current = 0;
        setCollapsed(true);
      } else if (dy < 0) {
        upTravel.current += -dy;
        if (upTravel.current > 140) setCollapsed(false);
      }
    },
    [setCollapsed],
  );
}

export function MainNavigation() {
  const { resetAllData, mixer } = useApp();
  // The scene follows the sound that leads the mix (see useSceneLead). Forest and silence
  // keep the forest footage; every other place shows its photograph.
  const leadId = useSceneLead(mixer.tracks);
  const lead = leadId ? getSound(leadId) : undefined;
  const place = useMemo<ScenePlace | null>(
    () =>
      lead && lead.category !== 'Forest'
        ? {
            key: lead.id,
            image: SCENE_IMAGE[lead.category],
            video: SCENE_VIDEO[lead.id],
          }
        : null,
    [lead],
  );
  const toast = useToast();
  const insets = useSafeAreaInsets();
  const [tab, setTab] = useState<Tab>('listen');
  const [sheet, setSheet] = useState<SheetName>(null);
  const [confirmReset, setConfirmReset] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [transition, setTransition] = useState<TransitionState>(null);
  const [entry, setEntry] = useState(0); // bumps when Listen is entered from the player
  const returnTab = useRef<Tab | null>(null);
  const { width: W, height: H } = useWindowDimensions();
  const onScroll = useScrollCollapse(setCollapsed);
  const listen = tab === 'listen';
  const hasMix = mixer.tracks.length > 0;
  const reduced = useReducedMotion();

  // ---- Immersive (BitChord): a tap on the scene, or IDLE_MS without a touch while sound
  // plays, lifts the blur and sends the title to the foot of the screen; the controls slide
  // down off the screen with it. Another tap (or Back) brings everything back.
  const immersiveAllowed =
    listen && hasMix && sheet === null && !transition && !confirmReset;
  const autoIdle = immersiveAllowed && mixer.isMasterPlaying;
  const [idle, setIdle] = useState(false);
  const [arriving, setArriving] = useState(false);
  const idleV = useRef(new Animated.Value(0)).current;
  const idleTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const auto = useRef(autoIdle);
  auto.current = autoIdle;
  const armIdle = useCallback(() => {
    if (idleTimer.current) clearTimeout(idleTimer.current);
    idleTimer.current = auto.current
      ? setTimeout(() => setIdle(true), IDLE_MS)
      : null;
  }, []);
  /** Any touch restarts the countdown; it never claims the touch. */
  const touched = useCallback(() => {
    armIdle();
    return false;
  }, [armIdle]);
  const toggleImmersive = useCallback(() => {
    setIdle(v => !v);
    armIdle();
  }, [armIdle]);
  useEffect(() => {
    if (!immersiveAllowed) setIdle(false);
  }, [immersiveAllowed]);
  useEffect(() => {
    if (!idle) armIdle();
  }, [idle, autoIdle, armIdle]);
  useEffect(
    () => () => {
      if (idleTimer.current) clearTimeout(idleTimer.current);
    },
    [],
  );
  useEffect(() => {
    // BitChord's move is quick and decelerating, the same both ways.
    Animated.timing(idleV, {
      toValue: idle ? 1 : 0,
      duration: reduced ? 200 : 320,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [idle, idleV, reduced]);
  const layout = listenLayout(insets.bottom);
  const fall = (distance: number) =>
    reduced
      ? []
      : [
          {
            translateY: idleV.interpolate({
              inputRange: [0, 1],
              outputRange: [0, distance],
            }),
          },
        ];
  const controlsOut = idleV.interpolate({
    inputRange: [0, 0.75, 1],
    outputRange: [1, 0.35, 0],
  });
  const chipOut = idleV.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: [1, 0, 0],
  });

  const go = useCallback((t: Tab) => {
    if (t === 'sounds') maybeShowLibraryInterstitial();
    setCollapsed(false);
    setTab(t);
  }, []);

  const leadImage = lead ? SCENE_IMAGE[lead.category] : null;

  /** Tap on the bar's player: grow its artwork into the Listen scene. */
  const openPlayer = () => {
    if (!leadImage || transition) return go('listen');
    returnTab.current = tab;
    setArriving(true);
    setTransition({
      kind: 'open',
      from: miniArtRect(W, H, insets.bottom, collapsed),
      image: leadImage,
      clip: leadClip(leadId),
    });
  };

  /** Back from a Listen opened from the player: shrink the scene back into the player. */
  const closePlayer = () => {
    const back = returnTab.current;
    returnTab.current = null;
    if (!back || !leadImage) return go('sounds');
    setTransition({
      kind: 'close',
      to: miniArtRect(W, H, insets.bottom, false),
      image: leadImage,
      clip: leadClip(leadId),
    });
    pendingTab.current = back;
  };
  const pendingTab = useRef<Tab | null>(null);

  useEffect(() => {
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      if (transition) return true;
      if (idle) {
        setIdle(false);
        return true;
      }
      if (tab !== 'listen') {
        go('listen');
        return true;
      }
      if (returnTab.current) {
        closePlayer();
        return true;
      }
      return false;
    });
    return () => sub.remove();
  });

  return (
    <View style={styles.root} onStartShouldSetResponderCapture={touched}>
      <GlassBackdrop id="scene" style={StyleSheet.absoluteFill}>
        <Scene dim={0} place={place} clear={arriving || (listen && idle)} />
        {!listen && (
          <View
            pointerEvents="none"
            style={[StyleSheet.absoluteFill, styles.solidPage]}
          />
        )}
        <Page active={listen}>
          <ListenScreen
            obscured={sheet !== null}
            entry={entry}
            idle={reduced ? undefined : idleV}
            onToggleImmersive={toggleImmersive}
            onBrowse={() => go('sounds')}
          />
        </Page>
        <Page active={tab === 'sounds'}>
          <SoundsScreen onScroll={onScroll} />
        </Page>
        <Page active={tab === 'settings'}>
          <SettingsScreen
            onScroll={onScroll}
            onRequestReset={() => setConfirmReset(true)}
          />
        </Page>
        {!listen && (
          <>
            {/* Lists dissolve into the status bar and under the bottom bar. */}
            <View
              pointerEvents="none"
              style={[styles.statusScrim, { height: insets.top + 28 }]}
            />
            <View
              pointerEvents="none"
              style={[styles.bottomScrim, { height: insets.bottom + 180 }]}
            />
          </>
        )}
      </GlassBackdrop>

      {listen && sheet === null && (
        <ArriveFromBelow key={entry}>
          <Animated.View
            pointerEvents={idle ? 'none' : 'box-none'}
            style={[StyleSheet.absoluteFill, { opacity: chipOut }]}
          >
            <TimerChip visible onPress={() => setSheet('timer')} />
          </Animated.View>
          <Animated.View
            pointerEvents={idle ? 'none' : 'box-none'}
            style={[
              StyleSheet.absoluteFill,
              { opacity: controlsOut, transform: fall(layout.drop) },
            ]}
          >
            <ListenPlayer
              onTimer={() => setSheet('timer')}
              onMixer={() => setSheet('mixer')}
            />
          </Animated.View>
        </ArriveFromBelow>
      )}
      <Animated.View
        pointerEvents={idle ? 'none' : 'box-none'}
        style={[
          StyleSheet.absoluteFill,
          { opacity: controlsOut, transform: fall(layout.drop) },
        ]}
      >
        <BottomBar
          tab={tab}
          onChange={go}
          collapsed={collapsed}
          onExpand={() => setCollapsed(false)}
          showPlayer={!listen && hasMix && transition?.kind !== 'open'}
          onOpenPlayer={openPlayer}
          leadId={leadId}
        />
      </Animated.View>

      <PlayerTransition
        state={transition}
        parked={
          hasMix && leadImage
            ? {
                rect: miniArtRect(W, H, insets.bottom, collapsed),
                image: leadImage,
                clip: leadClip(leadId),
              }
            : null
        }
        onCovered={() => {
          if (transition?.kind === 'open') {
            setTab('listen');
            setCollapsed(false);
            setEntry(e => e + 1);
            // The scene went clear while the clip flew (see openPlayer); the blur now wipes
            // up as the title and controls come in.
            setTimeout(() => setArriving(false), 80);
          } else if (pendingTab.current) {
            setTab(pendingTab.current);
            pendingTab.current = null;
          }
        }}
        onDone={() => setTransition(null)}
      />

      <MixerSheet
        visible={sheet === 'mixer'}
        onClose={() => setSheet(null)}
        onBrowse={() => go('sounds')}
      />
      <TimerSheet visible={sheet === 'timer'} onClose={() => setSheet(null)} />
      <ConfirmDialog
        visible={confirmReset}
        title="Reset Arcadia?"
        message="Every setting returns to its default and the introduction shows again. Sounds keep playing."
        confirmTitle="Reset"
        onCancel={() => setConfirmReset(false)}
        onConfirm={async () => {
          setConfirmReset(false);
          await resetAllData();
          toast('Arcadia was reset');
        }}
      />
    </View>
  );
}

/** Listen's controls rise into place after the player transition (BitChord's controls arrive last). */
function ArriveFromBelow({ children }: { children: React.ReactNode }) {
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(v, {
      toValue: 1,
      duration: 360,
      delay: 60,
      useNativeDriver: true,
    }).start();
  }, [v]);
  return (
    <Animated.View
      pointerEvents="box-none"
      style={[
        StyleSheet.absoluteFill,
        {
          opacity: v,
          transform: [
            {
              translateY: v.interpolate({
                inputRange: [0, 1],
                outputRange: [24, 0],
              }),
            },
          ],
        },
      ]}
    >
      {children}
    </Animated.View>
  );
}

/** Pages switch instantly; inactive ones stay mounted (scroll position survives) but are hidden. */
function Page({
  active,
  children,
}: {
  active: boolean;
  children: React.ReactNode;
}) {
  return (
    <View
      style={[StyleSheet.absoluteFill, !active && styles.hidden]}
      pointerEvents={active ? 'auto' : 'none'}
      accessibilityElementsHidden={!active}
      importantForAccessibility={active ? 'auto' : 'no-hide-descendants'}
    >
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#0C0E0B' },
  hidden: { opacity: 0 },
  solidPage: { backgroundColor: '#0E100D' },
  statusScrim: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    backgroundImage:
      'linear-gradient(180deg, rgba(9,11,8,0.92) 0%, rgba(9,11,8,0.7) 55%, rgba(9,11,8,0) 100%)',
  },
  bottomScrim: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundImage:
      'linear-gradient(180deg, rgba(9,11,8,0) 0%, rgba(9,11,8,0.55) 60%, rgba(9,11,8,0.8) 100%)',
  },
});
