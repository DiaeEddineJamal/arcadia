/**
 * The scene: full-bleed environmental footage that the whole app sits in.
 *
 * - Muted, looping, cover-fit video on a TextureView (react-native-video is patched for it;
 *   see patches/). Each clip also has a cut with BitChord's progressive blur baked in (sharp
 *   top, blurred behind the title); it fades out in immersive mode. See VIDEO_VISUALS.md.
 * - The still (static_main.jpg) is shown until the first frame arrives, if the video fails, and
 *   permanently under Reduce Motion.
 * - Bottom and top scrims are environmental (a darkening of the footage, not a colour) and exist
 *   for text legibility. `dim` darkens the whole scene behind text-heavy pages.
 */
import React, {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import {
  Animated,
  AppState,
  Easing,
  Image,
  StyleProp,
  StyleSheet,
  useWindowDimensions,
  View,
  ViewStyle,
} from 'react-native';
import Video, { ViewType, type VideoRef } from 'react-native-video';
import { useReducedMotion } from '../design/primitives';
import { color, motion } from '../design/tokens';
import { SCENE_IMAGE, SCENE_VIDEO, type SceneClip } from '../data/scenes';
import { getSound } from '../data/sounds';

const VIDEO: SceneClip = {
  sharp: require('../../assets/videos/main_animated_sharp.mp4'),
  blur: require('../../assets/videos/main_animated_blur.mp4'),
};

/** 0 = Listen as usual (blurred lower half), 1 = immersive (clear footage). */
const ClearContext = createContext(false);

/** 0 → 1 over BitChord's 320 ms when `on` flips. Each view owns its value (see Scene). */
function useFade(on: boolean): Animated.Value {
  const v = useRef(new Animated.Value(on ? 1 : 0)).current;
  useEffect(() => {
    Animated.timing(v, {
      toValue: on ? 1 : 0,
      duration: 320,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [on, v]);
  return v;
}

/**
 * Both cuts of a clip, the blurred one on top. In immersive mode the blurred cut fades out and
 * the clear footage shows, as BitChord's blur lifts when its title drops.
 */
function ClipPair({
  clip,
  paused,
  onReady,
  onError,
}: {
  clip: SceneClip;
  paused?: boolean;
  onReady?: () => void;
  onError?: () => void;
}) {
  const clear = useFade(useContext(ClearContext));
  // A wipe, not a fade: the blurred band slides down out of view as the title drops (and back
  // up), its picture counter-moving so it stays registered with the sharp cut. Fading a playing
  // TextureView to ~0 made it come back black for a frame. A 2 px sliver stays on screen so it
  // never stops drawing.
  const { height } = useWindowDimensions();
  // The band covers the whole screen while controls show: the two cuts play on separate
  // decoders and can drift, so they only meet on screen during the 320 ms wipe.
  const bandTop = 0;
  const travel = height - bandTop - 2;
  const slide = clear.interpolate({
    inputRange: [0, 1],
    outputRange: [0, travel],
  });
  const counter = clear.interpolate({
    inputRange: [0, 1],
    outputRange: [0, -travel],
  });
  return (
    <>
      <Footage
        source={clip.sharp}
        clock="master"
        paused={paused}
        onReady={onReady}
        onError={onError}
      />
      <Animated.View
        style={[
          styles.band,
          { top: bandTop, transform: [{ translateY: slide }] },
        ]}
      >
        <Animated.View
          style={[
            styles.bandPicture,
            { top: -bandTop, height, transform: [{ translateY: counter }] },
          ]}
        >
          <Footage source={clip.blur} clock="follow" paused={paused} />
        </Animated.View>
      </Animated.View>
    </>
  );
}

const STILL = require('../../assets/images/static_main.jpg');

export const ONBOARDING_VIDEOS = [
  require('../../assets/videos/Animated1.mp4'),
  require('../../assets/videos/Animated2.mp4'),
  require('../../assets/videos/Animated3.mp4'),
  require('../../assets/videos/animated4.mp4'),
];

function useAppActive(): boolean {
  const [active, setActive] = useState(AppState.currentState === 'active');
  useEffect(() => {
    const sub = AppState.addEventListener('change', s =>
      setActive(s === 'active'),
    );
    return () => sub.remove();
  }, []);
  return active;
}

/**
 * One clock per clip (keyed by its asset). The Listen scene's sharp cut keeps time ('master');
 * every other copy of that clip — the blurred cut, the mini player's thumbnail, the transition's
 * flying clip — starts at the master's current frame ('follow'). Copies then hand over to each
 * other without a jump, as BitChord resumes its canvas from the frame that was showing.
 */
const clocks = new Map<
  number,
  { t: number; at: number; dur: number; running: boolean }
>();

function clockNow(source: number): number | null {
  const c = clocks.get(source);
  if (!c || !c.dur) return null;
  const t = c.running ? c.t + (Date.now() - c.at) / 1000 : c.t;
  return t % c.dur;
}

/** One looping muted clip. Paused in the background and under Reduce Motion. */
export function Footage({
  source,
  paused,
  clock,
  onReady,
  onError,
}: {
  source: number;
  paused?: boolean;
  clock?: 'master' | 'follow';
  onReady?: () => void;
  onError?: () => void;
}) {
  const active = useAppActive();
  const ref = useRef<VideoRef>(null);
  const running = !paused && active;
  const duration = useRef(0);
  const lastNudge = useRef(0);
  useEffect(() => {
    if (clock !== 'master') return;
    const c = clocks.get(source);
    if (c) clocks.set(source, { ...c, running });
  }, [clock, source, running]);
  return (
    <Video
      ref={ref}
      // A Metro asset id (require('...mp4')) is a valid source at runtime.
      source={source as unknown as React.ComponentProps<typeof Video>['source']}
      style={StyleSheet.absoluteFill}
      resizeMode="cover"
      repeat
      muted
      paused={!running}
      disableFocus
      mixWithOthers="mix"
      playInBackground={false}
      shutterColor="transparent"
      viewType={ViewType.TEXTURE}
      progressUpdateInterval={clock ? 250 : 250000}
      onLoad={e => {
        duration.current = e.duration;
        if (clock === 'follow') {
          const t = clockNow(source);
          if (t != null) ref.current?.seek(t);
        }
      }}
      onProgress={
        clock === 'master'
          ? e =>
              clocks.set(source, {
                t: e.currentTime,
                at: Date.now(),
                dur: duration.current,
                running,
              })
          : clock === 'follow'
          ? e => {
              // A seek lands late by however long the decoder took to start, and loops drift:
              // nudge back whenever more than ~0.1 s off, at most once every 1.5 s.
              const t = clockNow(source);
              const dur = duration.current;
              if (t == null || !dur || Date.now() - lastNudge.current < 1500)
                return;
              let d = t - e.currentTime;
              if (d > dur / 2) d -= dur;
              if (d < -dur / 2) d += dur;
              if (Math.abs(d) > 0.1) {
                lastNudge.current = Date.now();
                ref.current?.seek((t + 0.06) % dur);
              }
            }
          : undefined
      }
      onReadyForDisplay={onReady}
      onError={onError}
    />
  );
}

/**
 * The clip a lead sound plays on Listen: the forest base when Forest or nothing leads, null
 * when its place has no clip (then its photograph is shown).
 */
export function leadClip(leadId: string | null): SceneClip | null {
  const lead = leadId ? getSound(leadId) : undefined;
  if (!lead || lead.category === 'Forest') return VIDEO;
  // No clip for this place (the placeholder clips are not in git): the photograph stands in.
  return SCENE_VIDEO[lead.id] ?? null;
}

/**
 * The mini player's artwork: the lead's photograph, with its clip fading in over it on the
 * scene's clock, so opening the player continues the same moving picture.
 */
export function ClipThumb({
  leadId,
  style,
}: {
  leadId: string | null;
  style?: StyleProp<ViewStyle>;
}) {
  const lead = leadId ? getSound(leadId) : undefined;
  const clip = leadClip(leadId);
  const reduced = useReducedMotion();
  const v = useRef(new Animated.Value(0)).current;
  return (
    <View style={[style, styles.thumb]}>
      {lead && (
        <Image
          source={SCENE_IMAGE[lead.category]}
          style={StyleSheet.absoluteFill}
        />
      )}
      {!reduced && clip && (
        <Animated.View
          key={clip.sharp}
          style={[StyleSheet.absoluteFill, { opacity: v }]}
        >
          <Footage
            source={clip.sharp}
            clock="follow"
            onReady={() =>
              Animated.timing(v, {
                toValue: 1,
                duration: 260,
                useNativeDriver: true,
              }).start()
            }
          />
        </Animated.View>
      )}
    </View>
  );
}

export interface ScenePlace {
  /** Stable identity (the leading sound id) so the same place never restarts its video. */
  key: string;
  image: number;
  video?: SceneClip;
}

/** One place: its photograph at once, then its looping video fading in over it when ready. */
function PlaceView({
  place,
  playing,
}: {
  place: ScenePlace;
  playing: boolean;
}) {
  const { width, height } = useWindowDimensions();
  const reduced = useReducedMotion();
  const videoIn = useRef(new Animated.Value(0)).current;
  const [failed, setFailed] = useState(false);
  const showVideo = !!place.video && !reduced && !failed;
  return (
    <>
      {/* Explicit size: an Image sized only by absoluteFill was drawn at its intrinsic size. */}
      <Image
        source={place.image}
        resizeMode="cover"
        style={{ width, height }}
      />
      {showVideo && (
        <Animated.View style={[StyleSheet.absoluteFill, { opacity: videoIn }]}>
          <ClipPair
            clip={place.video!}
            paused={!playing}
            onReady={() =>
              Animated.timing(videoIn, {
                toValue: 1,
                duration: 700,
                useNativeDriver: true,
              }).start()
            }
            onError={() => setFailed(true)}
          />
        </Animated.View>
      )}
    </>
  );
}

/**
 * The place leading the mix. A new place dissolves in over the previous one (1.4 s); `null`
 * dissolves back to the forest footage underneath.
 */
// Memoised so flipping immersive mode (a Scene re-render) doesn't re-render every place.
const PlaceLayer = React.memo(function PlaceLayerImpl({
  place,
}: {
  place: ScenePlace | null;
}) {
  const reduced = useReducedMotion();
  const [layers, setLayers] = useState<
    { place: ScenePlace; id: number; v: Animated.Value }[]
  >([]);
  const counter = useRef(0);
  const visible = useRef(new Animated.Value(place ? 1 : 0)).current;

  useEffect(() => {
    Animated.timing(visible, {
      toValue: place ? 1 : 0,
      duration: reduced ? 0 : 1400,
      useNativeDriver: true,
    }).start();
    if (!place) return;
    setLayers(prev => {
      if (prev.length && prev[prev.length - 1].place.key === place.key)
        return prev;
      const v = new Animated.Value(prev.length ? 0 : 1);
      const next = [...prev.slice(-1), { place, id: ++counter.current, v }];
      if (prev.length) {
        Animated.timing(v, {
          toValue: 1,
          duration: reduced ? 0 : 1400,
          easing: Easing.inOut(Easing.quad),
          useNativeDriver: true,
        }).start(() => setLayers(l => l.slice(-1)));
      }
      return next;
    });
  }, [place, reduced, visible]);

  return (
    <Animated.View style={[StyleSheet.absoluteFill, { opacity: visible }]}>
      {layers.map((l, i) => (
        <Animated.View
          key={l.id}
          style={[StyleSheet.absoluteFill, { opacity: l.v }]}
        >
          <PlaceView
            place={l.place}
            playing={!!place && i >= layers.length - 2}
          />
        </Animated.View>
      ))}
    </Animated.View>
  );
});

export function Scene({
  dim,
  place = null,
  clear = false,
}: {
  dim: number;
  place?: ScenePlace | null;
  /**
   * Immersive Listen: lifts the baked blur and most of the bottom scrim. A flag rather than a
   * shared Animated.Value: clips mount and unmount as places change, and natively driven
   * interpolations attached mid-animation start from a stale value.
   */
  clear?: boolean;
}) {
  const { width, height } = useWindowDimensions();
  const reduced = useReducedMotion();
  const [ready, setReady] = useState(false);
  const [failed, setFailed] = useState(false);
  const stillOpacity = useRef(new Animated.Value(1)).current;
  const dimValue = useRef(new Animated.Value(dim)).current;
  const showVideo = !reduced && !failed;

  useEffect(() => {
    Animated.timing(stillOpacity, {
      toValue: showVideo && ready ? 0 : 1,
      duration: motion.scene,
      useNativeDriver: true,
    }).start();
  }, [showVideo, ready, stillOpacity]);

  useEffect(() => {
    Animated.timing(dimValue, {
      toValue: dim,
      duration: reduced ? 0 : motion.sheet,
      useNativeDriver: true,
    }).start();
  }, [dim, reduced, dimValue]);

  const clearV = useFade(clear);
  const scrimOpacity = clearV.interpolate({
    inputRange: [0, 1],
    outputRange: [1, 0.45],
  });

  return (
    <ClearContext.Provider value={clear}>
      <View style={[StyleSheet.absoluteFill, styles.base]} pointerEvents="none">
        <View style={StyleSheet.absoluteFill}>
          {showVideo && (
            <ClipPair
              clip={VIDEO}
              paused={!!place}
              onReady={() => setReady(true)}
              onError={() => setFailed(true)}
            />
          )}
          <Animated.View
            style={[StyleSheet.absoluteFill, { opacity: stillOpacity }]}
          >
            <Image
              source={STILL}
              resizeMode="cover"
              style={{ width, height }}
            />
          </Animated.View>
          <PlaceLayer place={place} />
        </View>
        <View style={[StyleSheet.absoluteFill, styles.topScrim]} />
        <Animated.View
          style={[
            StyleSheet.absoluteFill,
            styles.bottomScrim,
            { opacity: scrimOpacity },
          ]}
        />
        <Animated.View
          style={[StyleSheet.absoluteFill, styles.dim, { opacity: dimValue }]}
        />
      </View>
    </ClearContext.Provider>
  );
}

const styles = StyleSheet.create({
  thumb: { overflow: 'hidden' },
  band: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    overflow: 'hidden',
  },
  bandPicture: { position: 'absolute', left: 0, right: 0 },
  base: { backgroundColor: color.ink },
  topScrim: {
    backgroundImage:
      'linear-gradient(180deg, rgba(8,10,7,0.45) 0%, rgba(8,10,7,0) 22%)',
  },
  bottomScrim: {
    backgroundImage:
      'linear-gradient(180deg, rgba(8,10,7,0) 30%, rgba(8,10,7,0.5) 56%, rgba(8,10,7,0.55) 78%, rgba(8,10,7,0.4) 100%)',
  },
  dim: { backgroundColor: 'rgba(9,11,8,0.72)' },
});
