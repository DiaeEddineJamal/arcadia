// Sleep timer: live countdown when set, presets, and a custom hours/minutes picker.
import React, { useEffect, useRef, useState } from 'react';
import {
  NativeScrollEvent,
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';
import { Button, Tappable, Text, haptic } from '../design/primitives';
import { color, radius, space } from '../design/tokens';
import { useApp } from '../state/AppContext';
import { Sheet } from './Sheet';

const PRESETS = [15, 30, 45, 60, 90];

/** Re-renders every `ms` while `active`. */
export function useNow(active: boolean, ms = 1000): number {
  const [now, setNow] = useState(Date.now());
  useEffect(() => {
    if (!active) return;
    setNow(Date.now());
    const id = setInterval(() => setNow(Date.now()), ms);
    return () => clearInterval(id);
  }, [active, ms]);
  return now;
}

export function formatRemaining(ms: number): string {
  const total = Math.max(0, Math.round(ms / 1000));
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  const mm = h > 0 ? `${m}`.padStart(2, '0') : `${m}`;
  return `${h > 0 ? `${h}:` : ''}${mm}:${`${s}`.padStart(2, '0')}`;
}

function clockTime(ts: number): string {
  const d = new Date(ts);
  return `${d.getHours()}:${`${d.getMinutes()}`.padStart(2, '0')}`;
}

export function TimerSheet({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const { accent, mixer, settings, setSleepTimer } = useApp();
  const active = mixer.sleepTimerEndsAt > 0;
  const now = useNow(visible && active);
  const [custom, setCustom] = useState(false);
  const [hours, setHours] = useState(0);
  const [minutes, setMinutes] = useState(20);

  useEffect(() => {
    if (visible) setCustom(false);
  }, [visible]);

  const start = (mins: number) => {
    if (mins <= 0) return;
    haptic.confirm();
    setSleepTimer(mins);
    setCustom(false);
  };

  return (
    <Sheet
      visible={visible}
      onClose={onClose}
      title="Sleep timer"
      heightFraction={custom ? 0.78 : 0.6}
      accessory={
        active ? (
          <Button
            title="Turn off"
            destructive
            accent={accent}
            onPress={() => {
              haptic.tap();
              setSleepTimer(0);
            }}
          />
        ) : undefined
      }>
      <View style={styles.content}>
        {active ? (
          <View style={styles.countdown} accessible accessibilityLabel={`Stops in ${formatRemaining(mixer.sleepTimerEndsAt - now)}`}>
            <Text kind="numeral">{formatRemaining(mixer.sleepTimerEndsAt - now)}</Text>
            <Text tone="secondary">
              {`Sound stops at ${clockTime(mixer.sleepTimerEndsAt)}${settings.enableFadeInOut ? `, fading out over ${settings.fadeOutDuration} s` : ''}`}
            </Text>
          </View>
        ) : (
          <View style={styles.suggest}>
            <Text tone="secondary">Stop the sound after</Text>
            <Tappable
              label={`Start a ${settings.defaultSleepTimer} minute sleep timer`}
              onPress={() => start(settings.defaultSleepTimer)}
              style={styles.start}>
              <View style={styles.startButton}>
                <Text kind="bodyStrong" tint={color.ink}>{`Start ${settings.defaultSleepTimer} min`}</Text>
              </View>
            </Tappable>
            <Text kind="caption" tone="tertiary" style={styles.or}>
              or choose another length
            </Text>
          </View>
        )}

        <View style={styles.presets}>
          {PRESETS.map(m => {
            return (
              <Tappable key={m} label={`${m} minutes`} onPress={() => start(m)} style={styles.presetHit}>
                <View style={styles.preset}>
                  <Text kind="sheetTitle" tint={color.paper} style={styles.lining}>
                    {m}
                  </Text>
                  <Text kind="caption" tone="tertiary">
                    min
                  </Text>
                </View>
              </Tappable>
            );
          })}
        </View>

        {custom ? (
          <View style={styles.custom}>
            <View style={styles.wheels}>
              <Wheel count={13} value={hours} onChange={setHours} format={h => `${h}`} unit="h" />
              <Wheel count={60} value={minutes} onChange={setMinutes} format={m => `${m}`.padStart(2, '0')} unit="min" />
            </View>
            <Button title="Start" filled accent={accent} onPress={() => start(hours * 60 + minutes)} />
          </View>
        ) : (
          <Button title="Other duration" accent={accent} style={styles.other} onPress={() => setCustom(true)} />
        )}
      </View>
    </Sheet>
  );
}

const ITEM = 44;
const WHEEL_H = ITEM * 3;

function Wheel({
  count,
  value,
  onChange,
  format,
  unit,
}: {
  count: number;
  value: number;
  onChange: (v: number) => void;
  format: (i: number) => string;
  unit: string;
}) {
  const ref = useRef<React.ComponentRef<typeof ScrollView>>(null);
  const [selected, setSelected] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => ref.current?.scrollTo({ y: value * ITEM, animated: false }), 0);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  const onScroll = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const i = Math.max(0, Math.min(count - 1, Math.round(e.nativeEvent.contentOffset.y / ITEM)));
    if (i !== selected) {
      setSelected(i);
      haptic.tick();
    }
  };
  const settle = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const i = Math.max(0, Math.min(count - 1, Math.round(e.nativeEvent.contentOffset.y / ITEM)));
    onChange(i);
  };
  return (
    <View style={styles.wheelRow}>
      <View style={styles.wheel}>
        <View pointerEvents="none" style={styles.wheelBand} />
        <ScrollView
          ref={ref}
          showsVerticalScrollIndicator={false}
          snapToInterval={ITEM}
          decelerationRate="fast"
          nestedScrollEnabled
          scrollEventThrottle={32}
          onScroll={onScroll}
          onMomentumScrollEnd={settle}
          onScrollEndDrag={settle}
          contentContainerStyle={{ paddingVertical: ITEM }}
          accessibilityLabel={unit === 'h' ? 'Hours' : 'Minutes'}>
          {Array.from({ length: count }).map((_, i) => (
            <View key={i} style={styles.wheelItem}>
              <Text kind="sheetTitle" tone={i === selected ? 'primary' : 'tertiary'} style={styles.lining}>
                {format(i)}
              </Text>
            </View>
          ))}
        </ScrollView>
      </View>
      <Text tone="secondary" style={styles.unit}>
        {unit}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  content: { paddingHorizontal: space.xxl, paddingTop: space.s },
  countdown: { marginBottom: space.xxl, gap: space.xs },
  suggest: { marginBottom: space.l },
  start: { marginTop: space.m },
  or: { marginTop: space.xl },
  presets: { flexDirection: 'row', gap: space.s },
  presetHit: { flex: 1 },
  preset: { height: 76, borderRadius: 18, backgroundColor: color.fill, alignItems: 'center', justifyContent: 'center' },
  startButton: { height: 52, borderRadius: 26, backgroundColor: color.paper, alignItems: 'center', justifyContent: 'center' },
  other: { alignSelf: 'flex-start', marginLeft: -space.xl, marginTop: space.l },
  custom: { marginTop: space.xl, gap: space.l },
  wheels: { flexDirection: 'row', justifyContent: 'center', gap: space.xxxl },
  wheelRow: { flexDirection: 'row', alignItems: 'center' },
  wheel: { width: 64, height: WHEEL_H },
  wheelBand: {
    position: 'absolute',
    top: ITEM,
    left: 0,
    right: 0,
    height: ITEM,
    borderRadius: radius.small,
    backgroundColor: color.fill,
  },
  lining: { fontVariant: ['lining-nums', 'tabular-nums'] },
  wheelItem: { height: ITEM, alignItems: 'center', justifyContent: 'center' },
  unit: { marginLeft: space.s, width: 32 },
});

