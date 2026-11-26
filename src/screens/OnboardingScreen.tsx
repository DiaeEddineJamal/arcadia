/**
 * First launch: four short pages, each over its own clip. Clips cross-fade as you move; each
 * page's words arrive like a title card, and a small live demonstration shows what the page
 * describes. Controls sit in a Liquid Glass dock that refracts the footage behind it.
 */
import React, { useEffect, useRef, useState } from 'react';
import {
  Animated,
  Easing,
  Image,
  NativeScrollEvent,
  NativeSyntheticEvent,
  PermissionsAndroid,
  Platform,
  ScrollView,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Footage, ONBOARDING_VIDEOS } from '../components/Scene';
import { useToast } from '../components/Toast';
import { Icon, IconName, Tappable, Text, haptic, useReducedMotion } from '../design/primitives';
import { color, font, motion, space } from '../design/tokens';
import { Glass, GlassBackdrop } from '../glass';
import { useApp } from '../state/AppContext';

const STILL = require('../../assets/images/static_main.jpg');
const PAGES = 4;
const ACTION = 56;

// ------------------------------------------------------------------ footage

/** Two clip slots; a page change loads the next clip into the hidden slot and cross-fades. */
function CrossfadingFootage({ page }: { page: number }) {
  const reduced = useReducedMotion();
  const [slots, setSlots] = useState<[number, number]>([0, -1]);
  const [front, setFront] = useState(0);
  const mix = useRef(new Animated.Value(0)).current; // 0 → slot A, 1 → slot B
  const pendingRef = useRef<number | null>(null);

  useEffect(() => {
    if (slots[front] === page) return;
    const back = front === 0 ? 1 : 0;
    pendingRef.current = back;
    setSlots(s => (back === 0 ? [page, s[1]] : [s[0], page]));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page]);

  const reveal = (slot: number) => {
    if (pendingRef.current !== slot) return;
    pendingRef.current = null;
    Animated.timing(mix, {
      toValue: slot,
      duration: 1100,
      easing: Easing.inOut(Easing.quad),
      useNativeDriver: true,
    }).start();
    setFront(slot);
  };

  if (reduced) return <Image source={STILL} style={StyleSheet.absoluteFill} resizeMode="cover" />;

  return (
    <>
      {slots.map((clip, i) =>
        clip < 0 ? null : (
          <Animated.View
            key={i}
            style={[
              StyleSheet.absoluteFill,
              { opacity: i === 0 ? mix.interpolate({ inputRange: [0, 1], outputRange: [1, 0] }) : mix },
            ]}>
            <Footage key={clip} source={ONBOARDING_VIDEOS[clip]} onReady={() => reveal(i)} />
          </Animated.View>
        ),
      )}
    </>
  );
}

// ------------------------------------------------------------------ motion helpers

/** Fades and lifts children in when `active` becomes true, after `delay`. */
function Arrive({ active, delay = 0, children }: { active: boolean; delay?: number; children: React.ReactNode }) {
  const reduced = useReducedMotion();
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    if (!active) {
      v.setValue(0);
      return;
    }
    Animated.timing(v, {
      toValue: 1,
      delay: reduced ? 0 : delay,
      duration: reduced ? 0 : 900,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [active, delay, reduced, v]);
  return (
    <Animated.View
      style={{ opacity: v, transform: [{ translateY: v.interpolate({ inputRange: [0, 1], outputRange: [18, 0] }) }] }}>
      {children}
    </Animated.View>
  );
}

/** "Arcadia", one letter at a time. */
function Wordmark({ active }: { active: boolean }) {
  const reduced = useReducedMotion();
  const letters = 'Arcadia'.split('');
  const values = useRef(letters.map(() => new Animated.Value(0))).current;
  useEffect(() => {
    if (!active) return;
    Animated.stagger(
      reduced ? 0 : 90,
      values.map(v =>
        Animated.timing(v, { toValue: 1, duration: reduced ? 0 : 1000, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
      ),
    ).start();
  }, [active, reduced, values]);
  return (
    <View style={styles.wordmark} accessible accessibilityRole="header" accessibilityLabel="Arcadia">
      {letters.map((ch, i) => (
        <Animated.Text
          key={i}
          style={[
            styles.wordmarkLetter,
            {
              opacity: values[i],
              transform: [{ translateY: values[i].interpolate({ inputRange: [0, 1], outputRange: [16, 0] }) }],
            },
          ]}>
          {ch}
        </Animated.Text>
      ))}
    </View>
  );
}

function Headline({ lead, emphasis }: { lead: string; emphasis: string }) {
  return (
    <Text style={styles.headline} accessibilityRole="header">
      {lead} <Text style={[styles.headline, styles.emphasis]}>{emphasis}</Text>
    </Text>
  );
}

// ------------------------------------------------------------------ demonstrations

function LayersDemo({ active }: { active: boolean }) {
  const reduced = useReducedMotion();
  const layers: { name: string; icon: IconName; level: number }[] = [
    { name: 'Light Rain', icon: 'cloud-rain', level: 0.72 },
    { name: 'Fireplace', icon: 'flame', level: 0.46 },
    { name: 'Ocean Waves', icon: 'waves', level: 0.58 },
  ];
  const values = useRef(layers.map(() => new Animated.Value(0))).current;
  useEffect(() => {
    if (!active) {
      values.forEach(v => v.setValue(0));
      return;
    }
    Animated.stagger(
      reduced ? 0 : 180,
      values.map((v, i) =>
        Animated.timing(v, {
          toValue: layers[i].level,
          delay: reduced ? 0 : 500,
          duration: reduced ? 0 : 1400,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: false,
        }),
      ),
    ).start();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [active, reduced]);
  return (
    <View style={styles.demo} importantForAccessibility="no-hide-descendants">
      {layers.map((l, i) => (
        <View key={l.name} style={styles.demoBar}>
          <Animated.View
            style={[
              styles.demoFill,
              { width: values[i].interpolate({ inputRange: [0, 1], outputRange: ['0%', '100%'] }) },
            ]}
          />
          <View style={styles.demoContent}>
            <Icon name={l.icon} size={16} tint={color.paperSecondary} />
            <Text kind="secondary" style={styles.demoName}>
              {l.name}
            </Text>
          </View>
        </View>
      ))}
    </View>
  );
}

function CountdownDemo({ active }: { active: boolean }) {
  const [left, setLeft] = useState(30 * 60);
  useEffect(() => {
    if (!active) {
      setLeft(30 * 60);
      return;
    }
    const id = setInterval(() => setLeft(s => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, [active]);
  const mm = Math.floor(left / 60);
  const ss = `${left % 60}`.padStart(2, '0');
  return (
    <View style={styles.demo} importantForAccessibility="no-hide-descendants">
      <Text style={styles.countdown}>{`${mm}:${ss}`}</Text>
      <View style={styles.countdownTrack}>
        <View style={[styles.countdownFill, { width: `${(left / 1800) * 100}%` }]} />
      </View>
      <Text kind="caption" tone="tertiary" style={styles.countdownCaption}>
        then a slow fade to silence
      </Text>
    </View>
  );
}

// ------------------------------------------------------------------ screen

export function OnboardingScreen() {
  const { updateSettings } = useApp();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const toast = useToast();
  const reduced = useReducedMotion();
  const [page, setPage] = useState(0);
  const scroller = useRef<React.ComponentRef<typeof ScrollView>>(null);
  const leave = useRef(new Animated.Value(1)).current;
  const progress = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(progress, {
      toValue: page,
      duration: reduced ? 0 : motion.sheet,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start();
  }, [page, reduced, progress]);

  const goTo = (p: number) => {
    const next = Math.max(0, Math.min(PAGES - 1, p));
    scroller.current?.scrollTo({ x: next * width, animated: !reduced });
    setPage(next);
    haptic.tick();
  };

  const onScrollEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const p = Math.round(e.nativeEvent.contentOffset.x / width);
    if (p !== page) {
      setPage(p);
      haptic.tick();
    }
  };

  const finish = async () => {
    haptic.confirm();
    if (Platform.OS === 'android' && Number(Platform.Version) >= 33) {
      try {
        const r = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS);
        if (r !== PermissionsAndroid.RESULTS.GRANTED) {
          toast('Playback controls won’t appear in notifications.', 3500);
        }
      } catch {
        // ignore
      }
    }
    Animated.timing(leave, { toValue: 0, duration: reduced ? 0 : motion.scene, useNativeDriver: true }).start(() =>
      updateSettings({ isOnboardingCompleted: true }),
    );
  };

  const last = page === PAGES - 1;
  const bottomSpace = insets.bottom + space.xl + ACTION + space.xxl;
  const topSpace = insets.top + 76;

  return (
    <Animated.View style={[styles.root, { opacity: leave }]}>
      <GlassBackdrop id="intro" style={StyleSheet.absoluteFill}>
        <CrossfadingFootage page={page} />
        <View pointerEvents="none" style={[StyleSheet.absoluteFill, styles.scrim]} />
      </GlassBackdrop>

      <ScrollView
        ref={scroller}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={onScrollEnd}
        style={StyleSheet.absoluteFill}>
        {/* 1 - name */}
        <View style={[styles.page, styles.pageEnd, { width, paddingBottom: bottomSpace }]}>
          <Wordmark active={page === 0} />
          <Arrive active={page === 0} delay={900}>
            <Text style={styles.line}>
              Fifteen recordings of rain, wind, water, fire and quiet rooms, for working, resting and sleeping.
            </Text>
          </Arrive>
        </View>

        {/* 2 - layering */}
        <View style={[styles.page, { width, paddingTop: topSpace, paddingBottom: bottomSpace }]}>
          <Arrive active={page === 1}>
            <Headline lead="Layer the" emphasis="sound." />
            <Text style={styles.line}>Start with rain. Add a fire, a distant sea. Every layer keeps its own level.</Text>
          </Arrive>
          <View style={styles.flex} />
          <Arrive active={page === 1} delay={250}>
            <LayersDemo active={page === 1} />
          </Arrive>
        </View>

        {/* 3 - timer */}
        <View style={[styles.page, { width, paddingTop: topSpace, paddingBottom: bottomSpace }]}>
          <Arrive active={page === 2}>
            <Headline lead="Let it end" emphasis="gently." />
            <Text style={styles.line}>Set a sleep timer and the mix fades out on its own, so silence arrives slowly.</Text>
          </Arrive>
          <View style={styles.flex} />
          <Arrive active={page === 2} delay={250}>
            <CountdownDemo active={page === 2} />
          </Arrive>
        </View>

        {/* 4 - background */}
        <View style={[styles.page, { width, paddingTop: topSpace, paddingBottom: bottomSpace }]}>
          <Arrive active={page === 3}>
            <Headline lead="Keep it" emphasis="playing." />
            <Text style={styles.line}>
              Arcadia keeps playing with the screen off, and its controls stay in your notifications. Allow them next.
            </Text>
          </Arrive>
        </View>
      </ScrollView>

      {/* progress, story-style */}
      <View style={[styles.top, { paddingTop: insets.top + space.m }]} pointerEvents="box-none">
        <View style={styles.progress} accessibilityLabel={`Page ${page + 1} of ${PAGES}`}>
          {Array.from({ length: PAGES }).map((_, i) => (
            <View key={i} style={styles.segment}>
              <Animated.View
                style={[
                  styles.segmentFill,
                  {
                    width: progress.interpolate({
                      inputRange: [i - 1, i, i + 1],
                      outputRange: ['0%', '100%', '100%'],
                      extrapolate: 'clamp',
                    }),
                  },
                ]}
              />
            </View>
          ))}
        </View>
        <View style={[styles.skipSlot, last && styles.hidden]} pointerEvents={last ? 'none' : 'box-none'}>
          <Tappable label="Skip the introduction" onPress={() => goTo(PAGES - 1)} scaleTo={0.94}>
            <Glass backdrop="intro" material="clear" radius={18} style={styles.skip}>
              <Text kind="secondary">Skip</Text>
            </Glass>
          </Tappable>
        </View>
      </View>

      {/* actions: a frosted back pebble and a solid primary, as in BitChord's album actions */}
      <View style={[styles.actions, { bottom: insets.bottom + space.xl }]} pointerEvents="box-none">
        <View style={[styles.backSlot, page === 0 && styles.gone]} pointerEvents={page === 0 ? 'none' : 'box-none'}>
          <Tappable label="Previous page" onPress={() => goTo(page - 1)} scaleTo={0.9}>
            <Glass backdrop="intro" material="frost" radius={ACTION / 2} style={styles.back}>
              <Icon name="arrow-left" size={20} tint={color.paper} />
            </Glass>
          </Tappable>
        </View>
        <Tappable
          label={last ? 'Begin' : 'Continue'}
          onPress={() => (last ? finish() : goTo(page + 1))}
          scaleTo={0.97}
          style={styles.primaryHit}>
          <View style={styles.primary}>
            <Text style={styles.primaryText}>{last ? 'Begin' : 'Continue'}</Text>
          </View>
        </Tappable>
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: color.ink },
  flex: { flex: 1 },
  scrim: {
    backgroundImage:
      'linear-gradient(180deg, rgba(8,10,7,0.72) 0%, rgba(8,10,7,0.45) 26%, rgba(8,10,7,0) 46%, rgba(8,10,7,0) 56%, rgba(8,10,7,0.55) 78%, rgba(8,10,7,0.8) 100%)',
  },
  page: { flex: 1, paddingHorizontal: space.xxl + 4 },
  pageEnd: { justifyContent: 'flex-end' },
  wordmark: { flexDirection: 'row' },
  wordmarkLetter: { fontFamily: font.display, fontSize: 84, lineHeight: 100, letterSpacing: -1, color: color.paper },
  headline: { fontFamily: font.display, fontSize: 54, lineHeight: 64, letterSpacing: -0.8, color: color.paper, paddingBottom: 6 },
  emphasis: { fontFamily: font.displayItalic },
  line: {
    fontFamily: font.ui,
    fontSize: 16,
    lineHeight: 24,
    color: 'rgba(238,234,224,0.82)',
    marginTop: space.l,
    maxWidth: 340,
  },
  demo: {},
  demoBar: {
    height: 46,
    borderRadius: 23,
    backgroundColor: 'rgba(238,234,224,0.1)',
    overflow: 'hidden',
    marginBottom: space.s,
    justifyContent: 'center',
  },
  demoFill: { position: 'absolute', left: 0, top: 0, bottom: 0, backgroundColor: 'rgba(238,234,224,0.22)' },
  demoContent: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 18 },
  demoName: { color: color.paper },
  countdown: { fontFamily: font.displayRegular, fontSize: 72, lineHeight: 76, color: color.paper, fontVariant: ['lining-nums', 'tabular-nums'] },
  countdownTrack: { height: 2, borderRadius: 1, backgroundColor: 'rgba(238,234,224,0.16)', marginTop: space.m, overflow: 'hidden' },
  countdownFill: { height: 2, backgroundColor: color.paper },
  countdownCaption: { marginTop: space.s },
  notice: { flexDirection: 'row', alignItems: 'center', gap: 14, paddingHorizontal: 16, height: 72 },
  noticeIcon: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: 'rgba(238,234,224,0.12)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  top: { position: 'absolute', top: 0, left: 0, right: 0, paddingHorizontal: space.xxl, flexDirection: 'row', alignItems: 'center', gap: space.l },
  progress: { flex: 1, flexDirection: 'row', gap: 6 },
  segment: { flex: 1, height: 2.5, borderRadius: 2, backgroundColor: 'rgba(238,234,224,0.22)', overflow: 'hidden' },
  segmentFill: { height: '100%', backgroundColor: color.paper },
  skipSlot: {},
  skip: { height: 36, paddingHorizontal: 16, justifyContent: 'center' },
  hidden: { opacity: 0 },
  gone: { display: 'none' },
  actions: { position: 'absolute', left: space.xxl, right: space.xxl, flexDirection: 'row', alignItems: 'center', gap: 12 },
  backSlot: {},
  back: { width: ACTION, height: ACTION, alignItems: 'center', justifyContent: 'center' },
  primaryHit: { flex: 1 },
  primary: { height: ACTION, borderRadius: ACTION / 2, backgroundColor: color.paper, alignItems: 'center', justifyContent: 'center' },
  primaryText: { fontFamily: font.uiStrong, fontSize: 16, color: color.ink },
});
