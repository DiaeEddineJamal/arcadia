// Small, shared building blocks. Kept deliberately plain: no containers for their own sake.
import React, { useEffect, useId, useRef, useState } from 'react';
import {
  AccessibilityInfo,
  Animated,
  Easing,
  GestureResponderEvent,
  LayoutChangeEvent,
  PanResponder,
  Pressable,
  StyleProp,
  StyleSheet,
  Text as RNText,
  TextProps,
  TextStyle,
  View,
  ViewStyle,
} from 'react-native';
import { Lucide } from '@react-native-vector-icons/lucide';
import { Glass, GlassBackdrop } from '../glass';
import { Mixer } from '../services/mixer';
import { color, motion, size, type } from './tokens';

// ---------------------------------------------------------------- text

type TypeName = keyof typeof type;

export function Text({
  kind = 'body',
  tone = 'primary',
  tint,
  style,
  ...rest
}: TextProps & {
  kind?: TypeName;
  tone?: 'primary' | 'secondary' | 'tertiary';
  tint?: string;
}) {
  const c =
    tint ?? (tone === 'secondary' ? color.paperSecondary : tone === 'tertiary' ? color.paperTertiary : color.paper);
  return <RNText {...rest} style={[type[kind], { color: c }, style as StyleProp<TextStyle>]} />;
}

// ---------------------------------------------------------------- icons

export type IconName = React.ComponentProps<typeof Lucide>['name'];

export function Icon({ name, size: s = size.icon, tint = color.paper }: { name: IconName; size?: number; tint?: string }) {
  return <Lucide name={name} size={s} color={tint} />;
}

const OUTER_KEYS = [
  'flex',
  'flexGrow',
  'flexShrink',
  'flexBasis',
  'alignSelf',
  'width',
  'minWidth',
  'maxWidth',
  'margin',
  'marginTop',
  'marginBottom',
  'marginLeft',
  'marginRight',
  'marginHorizontal',
  'marginVertical',
  'position',
  'top',
  'bottom',
  'left',
  'right',
] as const;

// ---------------------------------------------------------------- feedback

export const haptic = {
  tap: () => Mixer.haptic('tap'),
  tick: () => Mixer.haptic('tick'),
  confirm: () => Mixer.haptic('confirm'),
};

export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(false);
  useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setReduced).catch(() => {});
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduced);
    return () => sub.remove();
  }, []);
  return reduced;
}

/** Pressable with a gentle press-in dim/scale, used for every tappable element. */
export function Tappable({
  onPress,
  onLongPress,
  style,
  children,
  label,
  hint,
  role = 'button',
  selected,
  disabled,
  scaleTo = 0.97,
  hitSlop = 4,
}: {
  onPress?: (e: GestureResponderEvent) => void;
  onLongPress?: () => void;
  style?: StyleProp<ViewStyle>;
  children: React.ReactNode;
  label?: string;
  hint?: string;
  role?: 'button' | 'tab' | 'switch' | 'adjustable' | 'radio';
  selected?: boolean;
  disabled?: boolean;
  scaleTo?: number;
  hitSlop?: number;
}) {
  const v = useRef(new Animated.Value(0)).current;
  // Layout props must sit on the Pressable (the flex child); visuals stay on the animated view.
  const flat = StyleSheet.flatten(style) ?? {};
  const outer: Record<string, unknown> = {};
  const inner: Record<string, unknown> = { ...flat };
  for (const k of OUTER_KEYS) {
    if (k in flat) {
      outer[k] = (flat as Record<string, unknown>)[k];
      delete inner[k];
    }
  }
  const to = (n: number) =>
    Animated.timing(v, { toValue: n, duration: motion.quick, easing: Easing.out(Easing.quad), useNativeDriver: true }).start();
  return (
    <Pressable
      onPress={onPress}
      onLongPress={onLongPress}
      onPressIn={() => to(1)}
      onPressOut={() => to(0)}
      disabled={disabled}
      hitSlop={hitSlop}
      accessibilityRole={role}
      accessibilityLabel={label}
      accessibilityHint={hint}
      accessibilityState={{ selected, disabled }}
      style={outer as ViewStyle}>
      <Animated.View
        style={[
          inner as ViewStyle,
          {
            opacity: v.interpolate({ inputRange: [0, 1], outputRange: [disabled ? 0.4 : 1, 0.72] }),
            transform: [{ scale: v.interpolate({ inputRange: [0, 1], outputRange: [1, scaleTo] }) }],
          },
        ]}>
        {children}
      </Animated.View>
    </Pressable>
  );
}

/** A 48×48 icon-only control with no container (the surface it sits on is the container). */
export function IconButton({
  icon,
  label,
  onPress,
  tint = color.paper,
  iconSize = size.icon,
}: {
  icon: IconName;
  label: string;
  onPress: () => void;
  tint?: string;
  iconSize?: number;
}) {
  return (
    <Tappable onPress={onPress} label={label} style={styles.iconButton} scaleTo={0.9}>
      <Icon name={icon} size={iconSize} tint={tint} />
    </Tappable>
  );
}

/** Text button. `filled` uses the accent as a quiet fill; otherwise it is text only. */
export function Button({
  title,
  onPress,
  accent,
  filled,
  destructive,
  style,
}: {
  title: string;
  onPress: () => void;
  accent: string;
  filled?: boolean;
  destructive?: boolean;
  style?: StyleProp<ViewStyle>;
}) {
  return (
    <Tappable
      onPress={onPress}
      label={title}
      style={[styles.button, filled && { backgroundColor: accent }, style]}>
      <Text
        kind="bodyStrong"
        tint={filled ? color.ink : destructive ? color.danger : accent}>
        {title}
      </Text>
    </Tappable>
  );
}

// ---------------------------------------------------------------- volume bar

/**
 * Volume, in the manner of BitChord's and Apple Music's scrubber: a thick rounded track with no
 * knob that swells while you hold it. Drag is relative, so a touch never jumps the level.
 */
export function LevelBar({
  value,
  onChange,
  onCommit,
  label,
  title,
  leading,
  trailing,
}: {
  value: number;
  onChange?: (v: number) => void;
  onCommit?: (v: number) => void;
  label: string;
  /** Optional text above the bar, left (e.g. the sound's name). The value shows on the right. */
  title?: string;
  /** Optional icons at the ends of the track (e.g. quiet and loud speakers). */
  leading?: IconName;
  trailing?: IconName;
}) {
  const [width, setWidth] = useState(0);
  // The fill follows the finger through an Animated.Value (no React render per move); only the
  // percentage text re-renders, and only when the whole percent changes.
  const [pctShown, setPctShown] = useState(Math.round(value * 100));
  const [held, setHeld] = useState<number | null>(null); // last dragged value until props catch up
  const level = useRef(new Animated.Value(value)).current;
  const dragging = useRef(false);
  const widthRef = useRef(0);
  const startRef = useRef(value);
  const lastRef = useRef(value);
  const valueRef = useRef(value);
  valueRef.current = value;
  const cb = useRef({ onChange, onCommit });
  cb.current = { onChange, onCommit };
  const thick = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (dragging.current) return;
    if (held !== null && Math.abs(held - value) > 0.005) return; // wait for the native echo
    if (held !== null) setHeld(null);
    level.setValue(value);
    setPctShown(Math.round(value * 100));
  }, [value, held, level]);

  useEffect(() => {
    if (held === null) return;
    const t = setTimeout(() => setHeld(null), 600);
    return () => clearTimeout(t);
  }, [held]);

  const clamp = (n: number) => Math.max(0, Math.min(1, n));
  const grow = (to: number) =>
    Animated.timing(thick, { toValue: to, duration: motion.quick, easing: Easing.out(Easing.quad), useNativeDriver: false }).start();

  const finish = () => {
    dragging.current = false;
    setHeld(lastRef.current);
    cb.current.onCommit?.(lastRef.current);
    grow(0);
  };

  const responder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: (_, g) => Math.abs(g.dx) > 4 && Math.abs(g.dx) > Math.abs(g.dy),
      onPanResponderTerminationRequest: () => false,
      onPanResponderGrant: () => {
        dragging.current = true;
        startRef.current = lastRef.current = (level as unknown as { _value: number })._value ?? valueRef.current;
        grow(1);
      },
      onPanResponderMove: (_, g) => {
        const v = clamp(startRef.current + g.dx / (widthRef.current || 1));
        const tens = (n: number) => Math.round(n * 10);
        if (tens(v) !== tens(lastRef.current)) haptic.tick();
        lastRef.current = v;
        level.setValue(v);
        setPctShown(p => (p === Math.round(v * 100) ? p : Math.round(v * 100)));
        cb.current.onChange?.(v);
      },
      onPanResponderRelease: finish,
      onPanResponderTerminate: finish,
    }),
  ).current;

  const step = (d: number) => {
    const v = clamp(Math.round((value + d) * 10) / 10);
    onChange?.(v);
    onCommit?.(v);
  };

  const h = thick.interpolate({ inputRange: [0, 1], outputRange: [8, 14] });
  const pct = `${pctShown}`;

  return (
    <View>
      {title ? (
        <View style={styles.levelHead}>
          <Text kind="body" style={styles.flexText} numberOfLines={1}>
            {title}
          </Text>
          <Text kind="secondary" tone="secondary" style={styles.levelValue}>
            {pct}
          </Text>
        </View>
      ) : null}
      <View style={styles.levelRow}>
        {leading ? <Icon name={leading} size={16} tint={color.paperSecondary} /> : null}
        <View
          style={styles.levelBand}
          onLayout={(e: LayoutChangeEvent) => {
            widthRef.current = e.nativeEvent.layout.width;
            setWidth(e.nativeEvent.layout.width);
          }}
          accessible
          accessibilityRole="adjustable"
          accessibilityLabel={label}
          accessibilityValue={{ min: 0, max: 100, now: pctShown, text: `${pct} percent` }}
          accessibilityActions={[{ name: 'increment' }, { name: 'decrement' }]}
          onAccessibilityAction={e => step(e.nativeEvent.actionName === 'increment' ? 0.1 : -0.1)}
          {...responder.panHandlers}>
          <Animated.View style={[styles.levelTrack, { height: h }]}>
            <Animated.View
              style={[styles.levelFill, { width: level.interpolate({ inputRange: [0, 1], outputRange: [0, width || 1] }) }]}
            />
          </Animated.View>
        </View>
        {trailing ? <Icon name={trailing} size={16} tint={color.paperSecondary} /> : null}
      </View>
    </View>
  );
}

/** Bare filled transport glyph (play / pause), drawn rather than stroked, like BitChord's. */
export function PlayGlyph({ playing, size: s = 34, tint = color.paper }: { playing: boolean; size?: number; tint?: string }) {
  if (playing) {
    const w = s * 0.26;
    const bar = { width: w, height: s * 0.86, borderRadius: w * 0.35, backgroundColor: tint };
    return (
      <View style={[styles.glyphBox, { width: s, height: s, gap: s * 0.2 }]}>
        <View style={bar} />
        <View style={bar} />
      </View>
    );
  }
  const h = s * 0.92;
  return (
    <View style={[styles.glyphBox, { width: s, height: s }]}>
      <View
        style={[
          styles.triangle,
          {
            marginLeft: s * 0.14,
            borderTopWidth: h / 2,
            borderBottomWidth: h / 2,
            borderLeftWidth: h * 0.86,
            borderLeftColor: tint,
          },
        ]}
      />
    </View>
  );
}

// ---------------------------------------------------------------- toggle

const TRACK_W = 52;
const TRACK_H = 32;
const THUMB = 26;
const THUMB_PRESSED = 36;

/**
 * Switch, as in iOS 26: a solid thumb at rest that, while pressed, stretches into a clear glass
 * lens refracting the track beneath it (the accent or the off tone), then settles back to solid.
 */
export function Toggle({
  value,
  onChange,
  accent,
  label,
}: {
  value: boolean;
  onChange: (v: boolean) => void;
  accent: string;
  label: string;
}) {
  const backdropId = `switch-${useId()}`;
  const on = useRef(new Animated.Value(value ? 1 : 0)).current;
  const press = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.spring(on, { toValue: value ? 1 : 0, useNativeDriver: false, damping: 22, stiffness: 260 }).start();
  }, [value, on]);
  const pressTo = (to: number) =>
    Animated.timing(press, { toValue: to, duration: motion.quick, easing: Easing.out(Easing.quad), useNativeDriver: false }).start();

  const thumbW = press.interpolate({ inputRange: [0, 1], outputRange: [THUMB, THUMB_PRESSED] });
  // On: the thumb is a clear lens over the accent track. Off: solid at rest, lens while pressed.
  const glassness = Animated.add(on, press).interpolate({ inputRange: [0, 1, 2], outputRange: [0, 1, 1] });
  const inset = (TRACK_H - THUMB) / 2;
  // Thumb's left edge: from the left inset (off) to the right inset (on), keeping its right edge
  // pinned while it stretches in the on position.
  const left = Animated.add(
    on.interpolate({ inputRange: [0, 1], outputRange: [inset, TRACK_W - inset] }),
    Animated.multiply(on, Animated.multiply(thumbW, -1)),
  );

  return (
    <Pressable
      onPressIn={() => pressTo(1)}
      onPressOut={() => pressTo(0)}
      onPress={() => {
        haptic.tap();
        onChange(!value);
      }}
      hitSlop={10}
      accessibilityRole="switch"
      accessibilityLabel={label}
      accessibilityState={{ checked: value }}
      style={styles.toggleHit}>
      <View style={styles.toggleBox}>
        <GlassBackdrop id={backdropId} style={styles.toggleTrack}>
          <Animated.View
            style={[
              StyleSheet.absoluteFill,
              { backgroundColor: on.interpolate({ inputRange: [0, 1], outputRange: ['rgba(238,234,224,0.16)', accent] }) },
            ]}
          />
        </GlassBackdrop>
        <Animated.View pointerEvents="none" style={[styles.thumbSlot, { left, width: thumbW, top: inset }]}>
          <Animated.View style={[styles.thumbSolid, { opacity: Animated.subtract(1, glassness) }]} />
          <Animated.View style={[StyleSheet.absoluteFill, { opacity: glassness }]}>
            <Glass backdrop={backdropId} material="lens" radius={THUMB / 2} lens={1.5} style={styles.fill} />
          </Animated.View>
        </Animated.View>
      </View>
    </Pressable>
  );
}

/**
 * Segmented choice with a glass pill (BitChord's search switcher): the labels sit in their own
 * small backdrop and the selected pill is clear glass that slides over them, bending what it covers.
 */
export function GlassSegmented<T extends string | number>({
  value,
  options,
  onChange,
  accent,
}: {
  value: T;
  options: { value: T; label: string }[];
  onChange: (v: T) => void;
  accent: string;
}) {
  const backdropId = `segmented-${useId()}`;
  const [width, setWidth] = useState(0);
  const index = Math.max(0, options.findIndex(o => o.value === value));
  const x = useRef(new Animated.Value(index)).current;
  useEffect(() => {
    Animated.spring(x, { toValue: index, useNativeDriver: true, damping: 24, stiffness: 240 }).start();
  }, [index, x]);
  const segW = (width - SEG_INSET * 2) / options.length;

  return (
    <View
      style={styles.segmented}
      onLayout={e => setWidth(e.nativeEvent.layout.width)}
      accessibilityRole="radiogroup">
      <GlassBackdrop id={backdropId} style={[StyleSheet.absoluteFill, styles.segmentedTrack]}>
        <View style={styles.segmentLabels}>
          {options.map(o => (
            <View key={String(o.value)} style={styles.segmentLabel}>
              <Text kind="secondary" tint={o.value === value ? accent : color.paperSecondary}>
                {o.label}
              </Text>
            </View>
          ))}
        </View>
      </GlassBackdrop>
      {width > 0 && (
        <Animated.View
          pointerEvents="none"
          style={[
            styles.segmentPill,
            { width: segW, transform: [{ translateX: x.interpolate({ inputRange: [0, 1], outputRange: [0, segW] }) }] },
          ]}>
          <Glass backdrop={backdropId} material="lift" radius={SEG_H / 2 - SEG_INSET} style={styles.fill} />
        </Animated.View>
      )}
      <View style={styles.segmentHits}>
        {options.map(o => (
          <Pressable
            key={String(o.value)}
            style={styles.segmentLabel}
            accessibilityRole="radio"
            accessibilityState={{ selected: o.value === value }}
            accessibilityLabel={o.label}
            onPress={() => {
              if (o.value !== value) haptic.tap();
              onChange(o.value);
            }}
          />
        ))}
      </View>
    </View>
  );
}

const SEG_H = 44;
const SEG_INSET = 3;

export function Hairline({ style }: { style?: StyleProp<ViewStyle> }) {
  return <View style={[styles.hairline, style]} />;
}

const styles = StyleSheet.create({
  iconButton: { width: size.touch, height: size.touch, alignItems: 'center', justifyContent: 'center' },
  button: {
    minHeight: size.touch,
    paddingHorizontal: 20,
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
  },
  levelHead: { flexDirection: 'row', alignItems: 'baseline', marginBottom: 2 },
  flexText: { flex: 1 },
  levelValue: { fontVariant: ['tabular-nums'], minWidth: 32, textAlign: 'right' },
  levelRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  levelBand: { flex: 1, height: 40, justifyContent: 'center' },
  levelTrack: { borderRadius: 7, backgroundColor: 'rgba(238,234,224,0.2)', overflow: 'hidden' },
  levelFill: { height: '100%', backgroundColor: 'rgba(238,234,224,0.92)' },
  glyphBox: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
  triangle: {
    width: 0,
    height: 0,
    borderTopColor: 'transparent',
    borderBottomColor: 'transparent',
  },
  toggleHit: { paddingVertical: 6 },
  toggleBox: { width: TRACK_W, height: TRACK_H },
  toggleTrack: { width: TRACK_W, height: TRACK_H, borderRadius: TRACK_H / 2, overflow: 'hidden' },
  thumbSlot: { position: 'absolute', height: THUMB },
  thumbSolid: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: THUMB / 2,
    backgroundColor: color.paper,
    boxShadow: '0px 1px 3px rgba(0,0,0,0.3)',
  },
  fill: { flex: 1 },
  segmented: { height: SEG_H },
  segmentedTrack: { borderRadius: SEG_H / 2, backgroundColor: color.fill, overflow: 'hidden' },
  segmentLabels: { flex: 1, flexDirection: 'row', paddingHorizontal: SEG_INSET },
  segmentLabel: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  segmentPill: { position: 'absolute', left: SEG_INSET, top: SEG_INSET, bottom: SEG_INSET },
  segmentHits: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, flexDirection: 'row', paddingHorizontal: SEG_INSET },
  hairline: { height: StyleSheet.hairlineWidth, backgroundColor: color.hairline },
});
