/**
 * Liquid Glass material system.
 *
 * <GlassBackdrop> marks the content glass can sample (the scene). <Glass> renders a surface that
 * refracts it. On Android both are native views (android/.../glass): the backdrop is recorded
 * once per frame into a RenderNode and every glass surface replays it through
 * saturation → blur → AGSL lens refraction, then tint, content and a directional rim light.
 *
 * Elsewhere (iOS for now, or when the native views are unavailable) <Glass> falls back to an
 * opaque material with a hairline edge — never a fake translucent "glassmorphism" layer.
 */
import React, { createContext, useContext } from 'react';
import {
  Platform,
  requireNativeComponent,
  StyleProp,
  StyleSheet,
  UIManager,
  View,
  ViewProps,
  ViewStyle,
} from 'react-native';

export type GlassQuality = 'liquid' | 'frosted' | 'solid';

/**
 * Glass is reserved for navigation and the few controls that float over the scene (tab bar,
 * the scene's round controls, the timer chip), exactly as BitChord limits it to its nav bar and
 * floating top controls. Everything else is a solid <Surface>. Values are BitChord's own.
 */
export const MATERIALS = {
  /** Floating navigation and controls over the scene. BitChord's liquidGlass() values. */
  clear: {
    tintColor: 'rgba(14,15,13,0.22)',
    solidColor: 'rgba(22,24,21,0.98)',
    brightness: 0,
    saturation: 1.6,
    blurRadius: 6,
    lensHeight: 26,
    lensAmount: 34,
    highlightOpacity: 0.45,
    rimWidth: 0.5,
    shadowOpacity: 0.14,
    innerShadowOpacity: 0.16,
  },
  /** Raised element inside a glass surface (selected tab, a button in a dock). Refracts its parent. */
  lift: {
    tintColor: 'rgba(238,234,224,0.08)',
    solidColor: 'rgba(255,255,255,0.12)',
    brightness: 0,
    saturation: 1.6,
    blurRadius: 2,
    lensHeight: 20,
    lensAmount: 28,
    highlightOpacity: 0.45,
    rimWidth: 0.5,
    shadowOpacity: 0.12,
    innerShadowOpacity: 0,
  },
  /** Small round icon buttons (BitChord's star / more): a pale frosted pebble. */
  frost: {
    tintColor: 'rgba(14,15,13,0.18)',
    solidColor: 'rgba(40,42,38,0.98)',
    brightness: 0,
    saturation: 1.6,
    blurRadius: 4,
    lensHeight: 22,
    lensAmount: 30,
    highlightOpacity: 0.45,
    rimWidth: 0.5,
    shadowOpacity: 0.16,
    innerShadowOpacity: 0.14,
  },
  /** BitChord's star / more buttons: a pale frosted pebble over the footage. */
  pebble: {
    tintColor: 'rgba(255,255,255,0.20)',
    solidColor: 'rgba(90,92,88,0.98)',
    brightness: 0,
    saturation: 1.3,
    blurRadius: 16,
    lensHeight: 12,
    lensAmount: 12,
    highlightOpacity: 0.7,
    rimWidth: 0.6,
    shadowOpacity: 0.12,
    innerShadowOpacity: 0,
  },
  /** A clear lens with almost no tint (the pressed switch thumb): pure refraction. */
  lens: {
    tintColor: 'rgba(238,234,224,0.05)',
    solidColor: 'rgba(238,234,224,0.95)',
    brightness: 0,
    saturation: 1.4,
    blurRadius: 0,
    lensHeight: 12,
    lensAmount: 16,
    highlightOpacity: 0.5,
    rimWidth: 0.5,
    shadowOpacity: 0.22,
    innerShadowOpacity: 0,
  },
  /** Text chips (BitChord's "Best Part"): dark glass that carries the scene's hue. */
  chip: {
    tintColor: 'rgba(16,20,22,0.62)',
    solidColor: 'rgba(30,34,34,0.98)',
    brightness: 0,
    saturation: 1.8,
    blurRadius: 22,
    lensHeight: 14,
    lensAmount: 10,
    highlightOpacity: 0.45,
    rimWidth: 0.75,
    shadowOpacity: 0.12,
    innerShadowOpacity: 0,
  },
} as const;

/** Solid surfaces (sheets, dialogs, mini player, toasts). */
export const SURFACE = {
  base: '#151714',
  raised: '#1C1E1A',
  edge: 'rgba(255,255,255,0.10)',
} as const;

export function Surface({
  radius,
  tone = 'base',
  style,
  children,
  ...rest
}: ViewProps & { radius: number; tone?: 'base' | 'raised' }) {
  return (
    <View
      {...rest}
      style={[
        {
          borderRadius: radius,
          backgroundColor: SURFACE[tone],
          borderWidth: StyleSheet.hairlineWidth,
          borderColor: SURFACE.edge,
          boxShadow: '0px 10px 30px rgba(0,0,0,0.35)',
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}

export type MaterialName = keyof typeof MATERIALS;

const hasNative =
  Platform.OS === 'android' &&
  !!(UIManager.hasViewManagerConfig?.('ArcadiaLiquidGlass') ?? true);

// Registered once per JS runtime (Fast Refresh re-evaluates this module).
const registry = globalThis as unknown as {
  __arcadiaGlass?: { backdrop: unknown; glass: unknown };
};
if (hasNative && !registry.__arcadiaGlass) {
  registry.__arcadiaGlass = {
    backdrop: requireNativeComponent('ArcadiaGlassBackdrop'),
    glass: requireNativeComponent('ArcadiaLiquidGlass'),
  };
}

const NativeBackdrop = hasNative
  ? (registry.__arcadiaGlass!.backdrop as React.ComponentType<
      ViewProps & { backdropId: string }
    >)
  : null;

type NativeGlassProps = ViewProps & {
  backdropId: string;
  glassMode: GlassQuality;
  cornerRadius: number;
  tintColor: string;
  solidColor: string;
  saturation: number;
  exportId?: string;
  innerShadowOpacity: number;
  brightness: number;
  rimWidth: number;
  blurRadius: number;
  lensHeight: number;
  lensAmount: number;
  chromaticAberration: boolean;
  resolutionScale: number;
  highlightOpacity: number;
  shadowOpacity: number;
};

const NativeGlass = hasNative
  ? (registry.__arcadiaGlass!.glass as React.ComponentType<NativeGlassProps>)
  : null;

const QualityContext = createContext<GlassQuality>('liquid');

export const GlassQualityProvider = QualityContext.Provider;

export function useGlassQuality(): GlassQuality {
  return useContext(QualityContext);
}

export function GlassBackdrop({
  id,
  style,
  children,
}: {
  id: string;
  style?: StyleProp<ViewStyle>;
  children: React.ReactNode;
}) {
  if (!NativeBackdrop) return <View style={style}>{children}</View>;
  return (
    <NativeBackdrop backdropId={id} style={style} collapsable={false}>
      {children}
    </NativeBackdrop>
  );
}

export interface GlassProps extends ViewProps {
  /** Which backdrop to sample. */
  backdrop?: string;
  material?: MaterialName;
  radius: number;
  /** Lens strength multiplier, e.g. raised while pressed. */
  lens?: number;
  /** Forces a quality below the app setting (never above it). */
  quality?: GlassQuality;
  /** Publish this surface's glass so glass placed on top of it can refract it. */
  exportId?: string;
}

const ORDER: GlassQuality[] = ['solid', 'frosted', 'liquid'];

export function Glass({
  backdrop = 'scene',
  material = 'clear',
  radius,
  lens = 1,
  quality,
  exportId,
  style,
  children,
  ...rest
}: GlassProps) {
  const appQuality = useGlassQuality();
  const effective =
    quality && ORDER.indexOf(quality) < ORDER.indexOf(appQuality)
      ? quality
      : appQuality;
  const m = MATERIALS[material];

  if (!NativeGlass) {
    return (
      <View
        {...rest}
        style={[
          { borderRadius: radius, backgroundColor: m.solidColor },
          styles.fallbackEdge,
          style,
        ]}
      >
        {children}
      </View>
    );
  }

  return (
    <NativeGlass
      {...rest}
      collapsable={false}
      backdropId={backdrop}
      glassMode={effective}
      cornerRadius={radius}
      tintColor={m.tintColor}
      solidColor={m.solidColor}
      saturation={m.saturation}
      exportId={exportId}
      innerShadowOpacity={m.innerShadowOpacity}
      brightness={m.brightness}
      rimWidth={m.rimWidth}
      blurRadius={m.blurRadius}
      lensHeight={m.lensHeight}
      lensAmount={m.lensAmount * lens}
      chromaticAberration
      resolutionScale={0.33}
      highlightOpacity={m.highlightOpacity}
      shadowOpacity={m.shadowOpacity}
      style={style}
    >
      {children}
    </NativeGlass>
  );
}

const styles = StyleSheet.create({
  fallbackEdge: {
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(255,255,255,0.10)',
  },
});
