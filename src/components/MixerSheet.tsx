// The mix: overall volume, then every layer as a level bar with pause and remove.
import React, { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { getSound, Sound } from '../data/sounds';
import { Button, IconButton, LevelBar, Text, haptic } from '../design/primitives';
import { color, space } from '../design/tokens';
import { Mixer } from '../services/mixer';
import { useApp } from '../state/AppContext';
import { Sheet } from './Sheet';

export function MixerSheet({
  visible,
  onClose,
  onBrowse,
}: {
  visible: boolean;
  onClose: () => void;
  onBrowse: () => void;
}) {
  const { accent, mixer, setMasterVolume, setSoundVolume, toggleSound, removeSound } = useApp();
  const [masterDraft, setMasterDraft] = useState<number | null>(null);
  const layers = mixer.tracks
    .map(t => ({ track: t, sound: getSound(t.id) }))
    .filter((l): l is { track: (typeof mixer.tracks)[number]; sound: Sound } => !!l.sound);

  const browse = () => {
    onClose();
    onBrowse();
  };

  return (
    <Sheet
      visible={visible}
      onClose={onClose}
      title="Mix"
      heightFraction={0.64}
      accessory={layers.length > 0 ? <Button title="Add" accent={accent} onPress={browse} /> : undefined}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <LevelBar
          label="Overall volume"
          title="Volume"
          leading="volume-1"
          trailing="volume-2"
          value={masterDraft ?? mixer.masterVolume}
          onChange={v => {
            setMasterDraft(v);
            Mixer.setMasterVolumeQuiet(v);
          }}
          onCommit={v => {
            setMasterVolume(v);
            setMasterDraft(null);
          }}
        />

        {layers.length === 0 ? (
          <View style={styles.empty}>
            <Text tone="secondary" style={styles.center}>
              Nothing in the mix yet.
            </Text>
            <Button title="Browse sounds" accent={accent} onPress={browse} />
          </View>
        ) : (
          <>
            <Text kind="caption" tone="tertiary" style={styles.caption}>
              {`${layers.length} ${layers.length === 1 ? 'layer' : 'layers'}`}
            </Text>
            {layers.map(({ track, sound }) => (
              <View key={sound.id} style={styles.layer}>
                <View style={[styles.flex, !track.playing && styles.paused]}>
                  <LevelBar
                    label={`${sound.name} volume`}
                    title={sound.name}
                    value={track.volume}
                    onChange={v => Mixer.setVolumeQuiet(sound.id, v)}
                    onCommit={v => setSoundVolume(sound.id, v)}
                  />
                </View>
                <IconButton
                  icon={track.playing ? 'pause' : 'play'}
                  label={track.playing ? `Pause ${sound.name}` : `Play ${sound.name}`}
                  tint={color.paperSecondary}
                  iconSize={18}
                  onPress={() => {
                    haptic.tap();
                    toggleSound(sound);
                  }}
                />
                <IconButton
                  icon="x"
                  label={`Remove ${sound.name}`}
                  tint={color.paperTertiary}
                  iconSize={18}
                  onPress={() => {
                    haptic.tap();
                    removeSound(sound.id);
                  }}
                />
              </View>
            ))}
          </>
        )}
      </ScrollView>
    </Sheet>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  center: { textAlign: 'center' },
  content: { paddingHorizontal: space.xl, paddingTop: space.xs, paddingBottom: space.xxl },
  caption: { marginTop: space.xxl, marginBottom: space.s, marginLeft: space.xs },
  layer: { flexDirection: 'row', alignItems: 'flex-end', marginBottom: space.m, marginRight: -space.s },
  paused: { opacity: 0.45 },
  empty: { alignItems: 'center', gap: space.m, paddingTop: space.huge },
});
