/**
 * Listen: the scene itself. The current mix is named in large serif type at the foot of the
 * footage, entering like a title card whenever it changes. When the app goes idle (see
 * MainNavigation), the title settles to the foot of the screen, as BitChord's does.
 */
import React, { useEffect, useRef } from 'react';
import { Animated, Easing, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { listenLayout } from '../components/ListenControls';
import { getSound, mixTitle } from '../data/sounds';
import {
  Button,
  Tappable,
  Text,
  haptic,
  useReducedMotion,
} from '../design/primitives';
import { space } from '../design/tokens';
import { useApp } from '../state/AppContext';

/** One-tap starting points when nothing is playing (the Flutter app's "Featured Sounds"). */
const STARTERS = ['rain_light', 'forest', 'fireplace'];

/** Fades and rises its children in each time `id` changes. */
function TitleCard({
  id,
  children,
}: {
  id: string;
  children: React.ReactNode;
}) {
  const reduced = useReducedMotion();
  const v = useRef(new Animated.Value(reduced ? 1 : 0)).current;
  useEffect(() => {
    if (reduced) {
      v.setValue(1);
      return;
    }
    v.setValue(0);
    Animated.timing(v, {
      toValue: 1,
      duration: 1100,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [id, reduced, v]);
  return (
    <Animated.View
      style={{
        opacity: v,
        transform: [
          {
            translateY: v.interpolate({
              inputRange: [0, 1],
              outputRange: [14, 0],
            }),
          },
        ],
      }}
    >
      {children}
    </Animated.View>
  );
}

export function ListenScreen({
  obscured,
  entry = 0,
  idle,
  onToggleImmersive,
  onBrowse,
}: {
  obscured: boolean;
  entry?: number;
  /** 0 → 1 immersive; omitted with reduced motion (the title then stays put). */
  idle?: Animated.Value;
  /** A tap on the scene itself (not a control) toggles immersive mode, as in BitChord. */
  onToggleImmersive?: () => void;
  onBrowse: () => void;
}) {
  const { accent, mixer, playSound } = useApp();
  const insets = useSafeAreaInsets();
  const names = mixer.tracks
    .map(t => getSound(t.id)?.name)
    .filter((n): n is string => !!n);
  const hasMix = names.length > 0;
  const playingCount = mixer.tracks.filter(t => t.playing).length;
  const title = hasMix ? mixTitle(names) : 'Quiet';

  const layout = listenLayout(insets.bottom);
  // With nothing playing there is no volume or play row, so the invitation sits lower.
  const bottom = hasMix ? layout.titleBottom : layout.base + 8;
  const drop =
    idle && hasMix
      ? [
          {
            translateY: idle.interpolate({
              inputRange: [0, 1],
              outputRange: [0, layout.drop],
            }),
          },
        ]
      : [];
  const tapStart = useRef<{ x: number; y: number } | null>(null);

  return (
    <View
      style={StyleSheet.absoluteFill}
      onStartShouldSetResponder={() => hasMix && !!onToggleImmersive}
      onResponderGrant={e => {
        tapStart.current = { x: e.nativeEvent.pageX, y: e.nativeEvent.pageY };
      }}
      onResponderRelease={e => {
        const s = tapStart.current;
        tapStart.current = null;
        if (
          s &&
          Math.abs(e.nativeEvent.pageX - s.x) < 12 &&
          Math.abs(e.nativeEvent.pageY - s.y) < 12
        ) {
          onToggleImmersive?.();
        }
      }}
    >
      <Animated.View
        style={[
          styles.block,
          { bottom, opacity: obscured ? 0 : 1, transform: drop },
        ]}
        pointerEvents="box-none"
      >
        <TitleCard id={`${title}|${entry}`}>
          <Text kind="scene" numberOfLines={3} accessibilityRole="header">
            {title}
          </Text>
          <Text tone="secondary" style={styles.meta}>
            {hasMix
              ? mixer.isMasterPlaying
                ? `${playingCount} ${
                    playingCount === 1 ? 'layer' : 'layers'
                  } playing`
                : 'Paused'
              : 'Start with one sound, then layer more from the mix.'}
          </Text>
        </TitleCard>
        {!hasMix && (
          <View style={styles.starters}>
            {STARTERS.map(id => {
              const s = getSound(id)!;
              return (
                <Tappable
                  key={id}
                  label={`Play ${s.name}`}
                  style={styles.starter}
                  onPress={() => {
                    haptic.tap();
                    playSound(s, s.defaultVolume);
                  }}
                >
                  <Text kind="secondary">{s.name}</Text>
                </Tappable>
              );
            })}
            <Button
              title="All sounds"
              accent={accent}
              onPress={onBrowse}
              style={styles.all}
            />
          </View>
        )}
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  block: { position: 'absolute', left: space.xxl, right: space.xxl },
  meta: { marginTop: space.s },
  starters: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    gap: space.s,
    marginTop: space.xl,
  },
  starter: {
    height: 40,
    paddingHorizontal: space.l,
    borderRadius: 20,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(238,234,224,0.4)',
    backgroundColor: 'rgba(12,14,11,0.2)',
    justifyContent: 'center',
  },
  all: { paddingHorizontal: space.m },
});
