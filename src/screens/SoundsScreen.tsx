/**
 * Sounds: the full catalogue as a quiet list grouped by place, over the dimmed scene.
 * A row adds the sound to the mix and plays it; tapping again pauses or resumes it.
 */
import React, { useId } from 'react';
import {
  Image,
  ScrollView,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { SCENE_FOCUS, SCENE_IMAGE } from '../data/scenes';
import { CATEGORY_ICON, CATEGORY_ORDER, Sound, soundsIn } from '../data/sounds';
import { Icon, PlayGlyph, Tappable, Text, haptic } from '../design/primitives';
import { color, size, space } from '../design/tokens';
import { useApp } from '../state/AppContext';
import { bottomChromeHeight } from '../components/TabBar';
import type { ScrollHandler } from './MainNavigation';
import { Glass, GlassBackdrop } from '../glass';

const PLATE_H = 172;

export function SoundsScreen({ onScroll }: { onScroll?: ScrollHandler }) {
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const plateW = width - space.xxl * 2;
  const plateImgH = plateW * (2340 / 1080);
  const bottom = bottomChromeHeight(insets.bottom, true) + space.huge;
  return (
    <ScrollView
      onScroll={onScroll}
      scrollEventThrottle={16}
      contentContainerStyle={[
        styles.content,
        { paddingTop: insets.top + space.xxxl, paddingBottom: bottom },
      ]}
      showsVerticalScrollIndicator={false}
    >
      <Text kind="title" accessibilityRole="header">
        Sounds
      </Text>
      {CATEGORY_ORDER.map(cat => (
        <View key={cat} style={styles.section}>
          <View style={styles.plate}>
            <Image
              source={SCENE_IMAGE[cat]}
              resizeMode="cover"
              style={[
                styles.plateImage,
                {
                  width: plateW,
                  height: plateImgH,
                  top: PLATE_H / 2 - plateImgH * SCENE_FOCUS[cat],
                },
              ]}
            />
            <View style={[StyleSheet.absoluteFill, styles.plateShade]} />
            <View style={styles.plateText}>
              <Icon
                name={CATEGORY_ICON[cat]}
                size={16}
                tint={color.paperSecondary}
              />
              <Text kind="sheetTitle" accessibilityRole="header">
                {cat}
              </Text>
            </View>
          </View>
          {soundsIn(cat).map(s => (
            <SoundRow key={s.id} sound={s} />
          ))}
        </View>
      ))}
    </ScrollView>
  );
}

function SoundRow({ sound }: { sound: Sound }) {
  const { accent, mixer, toggleSound } = useApp();
  const track = mixer.tracks.find(t => t.id === sound.id);
  const state: 'off' | 'playing' | 'paused' = !track
    ? 'off'
    : track.playing
    ? 'playing'
    : 'paused';
  const hint =
    state === 'off'
      ? 'Adds to the mix and plays'
      : state === 'playing'
      ? 'Pauses this sound'
      : 'Resumes this sound';

  return (
    <Tappable
      onPress={() => {
        haptic.tap();
        toggleSound(sound);
      }}
      label={`${sound.name}${
        state === 'off' ? '' : state === 'playing' ? ', playing' : ', paused'
      }`}
      hint={hint}
      scaleTo={0.985}
      style={styles.row}
    >
      <View style={styles.flex}>
        <Text tint={state === 'playing' ? accent : color.paper}>
          {sound.name}
        </Text>
        {state !== 'off' && (
          <Text kind="caption" tone="tertiary">
            {state === 'playing' ? 'Playing' : 'Paused'}
          </Text>
        )}
      </View>
      <GlassPebble
        state={state}
        glow={
          state === 'playing'
            ? accent
            : state === 'paused'
            ? PAUSED_GLOW
            : OFF_GLOW
        }
      />
    </Tappable>
  );
}

const OFF_GLOW = 'rgba(238,234,224,0.05)';
const PAUSED_GLOW = 'rgba(238,234,224,0.14)';

/**
 * The row's add / pause / resume button: BitChord's frosted pebble. The page is solid, so the
 * pebble bends its own small backdrop (a disc, in the accent while the sound plays), the same
 * way the Settings switch does.
 */
function GlassPebble({
  state,
  glow,
}: {
  state: 'off' | 'playing' | 'paused';
  glow: string;
}) {
  const id = `pebble-${useId()}`;
  return (
    <View style={styles.state} pointerEvents="none">
      <GlassBackdrop id={id} style={StyleSheet.absoluteFill}>
        <View
          style={[
            styles.glow,
            state === 'playing' && styles.glowSoft,
            { backgroundColor: glow },
          ]}
        />
      </GlassBackdrop>
      <Glass
        backdrop={id}
        material="pebble"
        radius={STATE / 2}
        lens={1.3}
        style={styles.pebble}
      >
        {state === 'off' ? (
          <Icon name="plus" size={17} tint={color.paper} />
        ) : (
          <PlayGlyph playing={state === 'playing'} size={14} />
        )}
      </Glass>
    </View>
  );
}

const STATE = 38;

const styles = StyleSheet.create({
  content: { paddingHorizontal: space.xxl },
  flex: { flex: 1 },
  section: { marginTop: space.xxl },
  plateImage: { position: 'absolute', left: 0 },
  plate: {
    height: PLATE_H,
    borderRadius: 20,
    overflow: 'hidden',
    marginBottom: space.s,
    justifyContent: 'flex-end',
  },
  plateShade: {
    backgroundImage:
      'linear-gradient(180deg, rgba(8,10,7,0.05) 30%, rgba(8,10,7,0.65) 100%)',
  },
  plateText: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.s,
    padding: space.l,
  },
  row: {
    minHeight: size.rowHeight,
    flexDirection: 'row',
    alignItems: 'center',
  },
  state: { width: STATE, height: STATE },
  glow: {
    position: 'absolute',
    top: 3,
    left: 3,
    right: 3,
    bottom: 3,
    borderRadius: STATE / 2,
  },
  glowSoft: { opacity: 0.55 },
  pebble: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
