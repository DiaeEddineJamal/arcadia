/**
 * BitChord's now-playing transition, from its source (PlayerSheetMotion / CanvasArtworkPlayer):
 * the mini player's moving artwork flies to full screen on a critically damped spring (no
 * bounce, ~0.45 s, brisk start and a long settle), and the clip never restarts — it continues
 * from the frame that was showing. Like BitChord's dock, the flying clip is kept mounted, hidden
 * and on the scene's clock (see Footage), parked behind the mini player's artwork, so a tap flies
 * a clip that is already playing in sync. At full size it swaps for the live Listen scene, which
 * is on the same frame. Closing runs the same path in reverse, back into the mini player.
 */
import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Image,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { useReducedMotion } from '../design/primitives';
import type { SceneClip } from '../data/scenes';
import { Footage } from './Scene';

export interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export type TransitionState =
  | { kind: 'open'; from: Rect; image: number; clip: SceneClip | null }
  | { kind: 'close'; to: Rect; image: number; clip: SceneClip | null }
  | null;

/** Critically damped: damping = 2·√(stiffness·mass). BitChord's stiffness is 195. */
const SPRING = { stiffness: 195, damping: 2 * Math.sqrt(195), mass: 1 };
const THUMB_RADIUS = 10;
/** Longest wait for the clip's first frame before flying with the photograph instead. */
const READY_WAIT = 350;

export interface Parking {
  rect: Rect;
  image: number;
  clip: SceneClip | null;
}

export function PlayerTransition({
  state,
  parked,
  onCovered,
  onDone,
}: {
  state: TransitionState;
  /** Where the hidden clip waits while the mini player shows (null: not mounted). */
  parked: Parking | null;
  /** The scene fills the screen (open) or is about to leave it (close): switch tabs underneath. */
  onCovered: () => void;
  onDone: () => void;
}) {
  const { width: W, height: H } = useWindowDimensions();
  const reduced = useReducedMotion();
  const p = useRef(new Animated.Value(0)).current; // 0 = thumbnail, 1 = full screen
  const veil = useRef(new Animated.Value(0)).current; // the flying layer's opacity
  const clipIn = useRef(new Animated.Value(0)).current; // the clip over the photograph
  const ready = useRef(false);
  const cb = useRef({ onCovered, onDone });
  cb.current = { onCovered, onDone };

  const clipKey = (state ?? parked)?.clip?.sharp;
  // Reset when the clip changes (not per transition: a parked clip is already running).
  useEffect(() => {
    ready.current = false;
    clipIn.setValue(0);
  }, [clipKey, clipIn]);

  // One sequence per transition: place the layer, wait for the clip's first frame (at most
  // READY_WAIT), then fly. Parked (no transition): hidden behind the mini player's artwork.
  useEffect(() => {
    if (!state) {
      p.setValue(0);
      veil.setValue(0);
      return;
    }
    p.setValue(state.kind === 'open' ? 0 : 1);
    veil.setValue(0);
    if (reduced) {
      cb.current.onCovered();
      cb.current.onDone();
      return;
    }
    let cancelled = false;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const started = Date.now();
    const spring = (to: number) =>
      Animated.spring(p, {
        toValue: to,
        ...SPRING,
        useNativeDriver: false,
        restDisplacementThreshold: 0.002,
        restSpeedThreshold: 0.002,
      });
    const fly = () => {
      if (cancelled) return;
      if (state.clip && !ready.current && Date.now() - started < READY_WAIT) {
        timer = setTimeout(fly, 16);
        return;
      }
      // No dissolves: the flying clip and the scene are on the same frame (one clock), so
      // the hand-off is a plain swap, as BitChord's canvas simply continues. (Fading a view
      // that holds a playing video also went through black on the test phone.)
      veil.setValue(1);
      if (state.kind === 'open') {
        spring(1).start(() => {
          cb.current.onCovered();
          cb.current.onDone();
        });
      } else {
        cb.current.onCovered();
        spring(0).start(() => cb.current.onDone());
      }
    };
    fly();
    return () => {
      cancelled = true;
      if (timer) clearTimeout(timer);
    };
  }, [state, p, veil, reduced]);

  const cur = state ?? (parked ? { kind: 'parked' as const, ...parked } : null);
  if (!cur) return null;
  const r =
    cur.kind === 'open' ? cur.from : cur.kind === 'close' ? cur.to : cur.rect;
  const lerp = (a: number, b: number) =>
    p.interpolate({ inputRange: [0, 1], outputRange: [a, b] });

  return (
    <View
      pointerEvents={state ? 'auto' : 'none'}
      style={StyleSheet.absoluteFill}
    >
      <Animated.View
        style={[
          styles.panel,
          {
            opacity: veil,
            left: lerp(r.x, 0),
            top: lerp(r.y, 0),
            width: lerp(r.width, W),
            height: lerp(r.height, H),
            borderRadius: lerp(THUMB_RADIUS, 0),
          },
        ]}
      >
        {/* The picture is laid out at full-screen size and centred in the window, so growing the
            window reveals more of the same cover-fit frame instead of rescaling it. */}
        <Animated.View
          style={{
            ...styles.picture,
            width: W,
            height: H,
            left: lerp(-(W - r.width) / 2, 0),
            top: lerp(-(H - r.height) / 2, 0),
          }}
        >
          <Image
            source={cur.image}
            resizeMode="cover"
            style={{ width: W, height: H }}
          />
          {cur.clip && (
            <Animated.View
              style={[StyleSheet.absoluteFill, { opacity: clipIn }]}
            >
              <Footage
                key={cur.clip.sharp}
                source={cur.clip.sharp}
                clock="follow"
                onReady={() => {
                  clipIn.setValue(1);
                  ready.current = true;
                }}
              />
            </Animated.View>
          )}
        </Animated.View>
        {/* The Listen scene's legibility scrims arrive with the growth, so the hand-off matches. */}
        <Animated.View
          style={[StyleSheet.absoluteFill, styles.scrims, { opacity: p }]}
        />
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  picture: { position: 'absolute' },
  panel: {
    position: 'absolute',
    overflow: 'hidden',
    backgroundColor: '#0C0E0B',
  },
  scrims: {
    backgroundImage:
      'linear-gradient(180deg, rgba(8,10,7,0.45) 0%, rgba(8,10,7,0) 22%, rgba(8,10,7,0) 40%, rgba(8,10,7,0.4) 62%, rgba(8,10,7,0.32) 100%)',
  },
});
