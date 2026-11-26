/**
 * The Listen player's controls: a thick knob-less volume bar (as BitChord's scrubber) and one
 * row of clear glass controls that refract the scene, plus the timer chip while a timer runs.
 */
import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import {
  Icon,
  LevelBar,
  PlayGlyph,
  Tappable,
  Text,
  haptic,
} from '../design/primitives';
import { color, space } from '../design/tokens';
import { Glass } from '../glass';
import { Mixer } from '../services/mixer';
import { useApp } from '../state/AppContext';
import { BAR_H, tabBarBottom } from './TabBar';
import { formatRemaining, useNow } from './TimerSheet';

const ROW = 76; // play diameter; the row's height
const PEBBLE = 44; // BitChord's star / more size
const VOLUME_ROW = 40;

/** Vertical layout shared with ListenScreen (bottom offsets from the screen edge). */
export function listenLayout(bottomInset: number) {
  const base = tabBarBottom(bottomInset) + BAR_H + 26;
  const volume = base + ROW + 18;
  const titleBottom = volume + VOLUME_ROW + 22;
  // Immersive mode (BitChord): the title settles near the foot of the screen; everything under
  // it moves down by the same distance, off the screen.
  const restBottom = bottomInset + 40;
  const drop = Math.max(0, titleBottom - restBottom);
  return { base, volume, titleBottom, drop };
}

/** BitChord's star / more: a pale frosted pebble. */
function Pebble({
  label,
  onPress,
  children,
}: {
  label: string;
  onPress: () => void;
  children: React.ReactNode;
}) {
  return (
    <Tappable label={label} onPress={onPress} scaleTo={0.9}>
      <Glass material="pebble" radius={PEBBLE / 2} style={styles.pebble}>
        {children}
      </Glass>
    </Tappable>
  );
}

/**
 * Listen, from the bottom up: one row of glass controls (timer, play, mix), the thick volume
 * bar, then the title. Nothing overlaps the title; the controls refract the photograph.
 */
export function ListenPlayer({
  onTimer,
  onMixer,
}: {
  onTimer: () => void;
  onMixer: () => void;
}) {
  const { mixer, pauseAll, resumeAll, setMasterVolume } = useApp();
  const insets = useSafeAreaInsets();
  const [draft, setDraft] = useState<number | null>(null);
  const hasMix = mixer.tracks.length > 0;
  const playing = mixer.isMasterPlaying;
  const L = listenLayout(insets.bottom);
  if (!hasMix) return null;

  return (
    <View pointerEvents="box-none" style={StyleSheet.absoluteFill}>
      <View style={[styles.volume, { bottom: L.volume }]}>
        <LevelBar
          label="Volume"
          leading="volume-1"
          trailing="volume-2"
          value={draft ?? mixer.masterVolume}
          onChange={v => {
            setDraft(v);
            Mixer.setMasterVolumeQuiet(v);
          }}
          onCommit={v => {
            setMasterVolume(v);
            setDraft(null);
          }}
        />
      </View>
      <View pointerEvents="box-none" style={[styles.row, { bottom: L.base }]}>
        <Pebble label="Sleep timer" onPress={onTimer}>
          <Icon name="moon" size={18} tint={color.paper} />
        </Pebble>
        <Tappable
          label={playing ? 'Pause' : 'Play'}
          scaleTo={0.86}
          onPress={() => {
            haptic.tap();
            playing ? pauseAll() : resumeAll();
          }}
          style={styles.playHit}
        >
          <PlayGlyph playing={playing} size={40} />
        </Tappable>
        <Pebble label="Mix" onPress={onMixer}>
          <Icon name="sliders-horizontal" size={18} tint={color.paper} />
        </Pebble>
      </View>
    </View>
  );
}

/** Top-right floating glass chip while a sleep timer runs (BitChord's floating top controls). */
export function TimerChip({
  visible,
  onPress,
}: {
  visible: boolean;
  onPress: () => void;
}) {
  const { mixer } = useApp();
  const insets = useSafeAreaInsets();
  const active = mixer.sleepTimerEndsAt > 0;
  const now = useNow(active && visible);
  if (!active || !visible) return null;
  const remaining = formatRemaining(mixer.sleepTimerEndsAt - now);
  return (
    <View
      pointerEvents="box-none"
      style={[styles.chipWrap, { top: insets.top + space.m }]}
    >
      <Tappable
        onPress={onPress}
        label={`Sleep timer, ${remaining} left`}
        scaleTo={0.95}
      >
        <Glass material="chip" radius={20} style={styles.chip}>
          <Icon name="moon" size={15} tint={color.paper} />
          <Text kind="secondary" style={styles.chipText}>
            {remaining}
          </Text>
        </Glass>
      </Tappable>
    </View>
  );
}

const styles = StyleSheet.create({
  pebble: {
    width: PEBBLE,
    height: PEBBLE,
    alignItems: 'center',
    justifyContent: 'center',
  },
  playHit: {
    width: ROW,
    height: ROW,
    alignItems: 'center',
    justifyContent: 'center',
  },
  volume: {
    position: 'absolute',
    left: space.xxl,
    right: space.xxl,
    height: VOLUME_ROW,
  },
  row: {
    position: 'absolute',
    left: 0,
    right: 0,
    height: ROW,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 44,
  },
  chipWrap: { position: 'absolute', right: space.l },
  chip: {
    height: 40,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    gap: 8,
  },
  chipText: { fontVariant: ['tabular-nums'], color: color.paper },
});
