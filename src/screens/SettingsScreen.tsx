// Settings: a plain sectioned list over the dimmed scene. Every row does something real.
import React from 'react';
import { Linking, ScrollView, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { bottomChromeHeight } from '../components/TabBar';
import type { ScrollHandler } from './MainNavigation';
import { useToast } from '../components/Toast';
import { GlassSegmented, Icon, IconButton, Tappable, Text, Toggle, haptic } from '../design/primitives';
import { ACCENTS, color, normalizeAccentKey, size, space } from '../design/tokens';
import { GlassQuality } from '../glass';
import { useApp } from '../state/AppContext';

const TIMER_PRESETS = [15, 30, 45, 60, 90];

export function SettingsScreen({
  onRequestReset,
  onScroll,
}: {
  onRequestReset: () => void;
  onScroll?: ScrollHandler;
}) {
  const { accent, settings, updateSettings, appInfo } = useApp();
  const insets = useSafeAreaInsets();
  const toast = useToast();
  const bottom = bottomChromeHeight(insets.bottom, true) + space.huge;
  const accentKey = normalizeAccentKey(settings.accentColor);

  return (
    <ScrollView
      onScroll={onScroll}
      scrollEventThrottle={16}
      contentContainerStyle={[styles.content, { paddingTop: insets.top + space.xxxl, paddingBottom: bottom }]}
      showsVerticalScrollIndicator={false}>
      <Text kind="title" accessibilityRole="header">
        Settings
      </Text>

      <Section title="Playback">
        <Row title="Fade in and out" detail="Sounds ease in when they start and out when they stop.">
          <Toggle
            label="Fade in and out"
            accent={accent}
            value={settings.enableFadeInOut}
            onChange={v => updateSettings({ enableFadeInOut: v })}
          />
        </Row>
        {settings.enableFadeInOut && (
          <>
            <Row title="Fade in">
              <Stepper
                value={`${settings.fadeInDuration} s`}
                label="Fade in duration"
                onDecrease={() => updateSettings({ fadeInDuration: Math.max(1, settings.fadeInDuration - 1) })}
                onIncrease={() => updateSettings({ fadeInDuration: Math.min(10, settings.fadeInDuration + 1) })}
              />
            </Row>
            <Row title="Fade out">
              <Stepper
                value={`${settings.fadeOutDuration} s`}
                label="Fade out duration"
                onDecrease={() => updateSettings({ fadeOutDuration: Math.max(1, settings.fadeOutDuration - 1) })}
                onIncrease={() => updateSettings({ fadeOutDuration: Math.min(15, settings.fadeOutDuration + 1) })}
              />
            </Row>
          </>
        )}
        <Row
          title="Keep playing in the background"
          detail={settings.enableBackgroundPlay ? 'Controls stay in your notifications.' : 'Sound pauses when you leave Arcadia.'}>
          <Toggle
            label="Keep playing in the background"
            accent={accent}
            value={settings.enableBackgroundPlay}
            onChange={v => updateSettings({ enableBackgroundPlay: v })}
          />
        </Row>
        <Row title="Default sleep timer" detail="Offered first when you open the timer.">
          <View />
        </Row>
        <GlassSegmented
          value={settings.defaultSleepTimer}
          accent={accent}
          options={TIMER_PRESETS.map(m => ({ value: m, label: `${m}` }))}
          onChange={m => updateSettings({ defaultSleepTimer: m })}
        />
      </Section>

      <Section title="Appearance">
        <Text tone="secondary" style={styles.label}>
          Accent
        </Text>
        <View style={styles.swatches} accessibilityRole="radiogroup">
          {ACCENTS.map(a => {
            const selected = a.key === accentKey;
            return (
              <Tappable
                key={a.key}
                role="radio"
                selected={selected}
                label={a.label}
                scaleTo={0.9}
                onPress={() => {
                  haptic.tap();
                  updateSettings({ accentColor: a.key });
                }}
                style={[styles.swatchRing, selected && { borderColor: a.value }]}>
                <View style={[styles.swatch, { backgroundColor: a.value }]} />
              </Tappable>
            );
          })}
        </View>
        <Text tone="secondary" style={[styles.label, styles.glassLabel]}>
          Glass
        </Text>
        <GlassSegmented
          value={settings.glassQuality as GlassQuality}
          accent={accent}
          options={[
            { value: 'liquid', label: 'Liquid' },
            { value: 'frosted', label: 'Frosted' },
            { value: 'solid', label: 'Solid' },
          ]}
          onChange={(v: GlassQuality) => updateSettings({ glassQuality: v })}
        />
        <Text kind="caption" tone="tertiary" style={styles.caption}>
          {settings.glassQuality === 'liquid'
            ? 'Controls refract the scene behind them.'
            : settings.glassQuality === 'frosted'
              ? 'Blur without refraction, lighter on older phones.'
              : 'Opaque controls, no transparency.'}
        </Text>
      </Section>

      <Section title="Data">
        <Tappable onPress={onRequestReset} label="Reset Arcadia" style={styles.linkRow}>
          <Text tint={color.danger}>Reset Arcadia</Text>
        </Tappable>
        <Text kind="caption" tone="tertiary">
          Restores every setting to its default.
        </Text>
      </Section>

      <Section title="About">
        <Row title="Version">
          <Text tone="secondary">{`${appInfo.version || '1.0.2'} (${appInfo.buildNumber || '2'})`}</Text>
        </Row>
        <Tappable
          label="Made by Luziv, opens GitHub"
          style={styles.linkRow}
          onPress={() => Linking.openURL('https://github.com/DiaeEddineJamal').catch(() => toast('Could not open the link'))}>
          <Text style={styles.flex}>Made by Luziv</Text>
          <Icon name="arrow-up-right" size={18} tint={color.paperTertiary} />
        </Tappable>
      </Section>
    </ScrollView>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text kind="section" tone="secondary" accessibilityRole="header" style={styles.sectionTitle}>
        {title}
      </Text>
      {children}
    </View>
  );
}

function Row({ title, detail, children }: { title: string; detail?: string; children: React.ReactNode }) {
  return (
    <View style={styles.row}>
      <View style={styles.flex}>
        <Text>{title}</Text>
        {detail ? (
          <Text kind="caption" tone="tertiary" style={styles.detail}>
            {detail}
          </Text>
        ) : null}
      </View>
      {children}
    </View>
  );
}

function Stepper({
  value,
  label,
  onDecrease,
  onIncrease,
}: {
  value: string;
  label: string;
  onDecrease: () => void;
  onIncrease: () => void;
}) {
  return (
    <View style={styles.stepper} accessible accessibilityLabel={`${label}, ${value}`}>
      <IconButton icon="minus" label={`Decrease ${label}`} tint={color.paperSecondary} iconSize={18} onPress={onDecrease} />
      <Text tone="secondary" style={styles.stepValue}>
        {value}
      </Text>
      <IconButton icon="plus" label={`Increase ${label}`} tint={color.paperSecondary} iconSize={18} onPress={onIncrease} />
    </View>
  );
}

const styles = StyleSheet.create({
  content: { paddingHorizontal: space.xxl },
  flex: { flex: 1 },
  section: { marginTop: space.xxxl + space.s },
  sectionTitle: { marginBottom: space.xs },
  row: { minHeight: size.rowHeight, flexDirection: 'row', alignItems: 'center', gap: space.l, paddingVertical: space.s },
  detail: { marginTop: 2 },
  label: { marginTop: space.m, marginBottom: space.m },
  glassLabel: { marginTop: space.xxl },
  caption: { marginTop: space.s },
  swatches: { flexDirection: 'row', justifyContent: 'space-between', marginHorizontal: -space.xs },
  swatchRing: {
    width: size.touch,
    height: size.touch,
    borderRadius: size.touch / 2,
    borderWidth: 1.5,
    borderColor: 'transparent',
    alignItems: 'center',
    justifyContent: 'center',
  },
  swatch: { width: 32, height: 32, borderRadius: 16 },
  linkRow: { minHeight: size.rowHeight - 8, flexDirection: 'row', alignItems: 'center' },
  stepper: { flexDirection: 'row', alignItems: 'center', marginRight: -space.m },
  stepValue: { minWidth: 56, textAlign: 'center', fontVariant: ['tabular-nums'] },
});
