/**
 * Arcadia design tokens.
 *
 * The scene carries the colour; the interface stays neutral. Text is a warm paper white, never
 * pure white, so it sits inside the footage instead of on top of it. Accents are taken from
 * natural materials and used sparingly: slider fills, the selected tab, the active sound.
 */
import { TextStyle } from 'react-native';

export const color = {
  ink: '#0C0E0B', // page base under the scene
  paper: '#EEEAE0', // primary text
  paperSecondary: 'rgba(238,234,224,0.66)',
  paperTertiary: 'rgba(238,234,224,0.42)',
  hairline: 'rgba(238,234,224,0.12)',
  fill: 'rgba(238,234,224,0.08)', // quiet fills (pressed rows, tracks)
  danger: '#E5866F',
} as const;

/** Accent choices (Settings → Accent). Legacy Flutter names map to their nearest natural tone. */
export const ACCENTS = [
  { key: 'moss', label: 'Moss', value: '#B4C493' },
  { key: 'ember', label: 'Ember', value: '#E3A27C' },
  { key: 'tide', label: 'Tide', value: '#93BCC8' },
  { key: 'sand', label: 'Sand', value: '#DCC9A1' },
  { key: 'heather', label: 'Heather', value: '#BFA8C9' },
  { key: 'lichen', label: 'Lichen', value: '#CBD3A6' },
] as const;

const LEGACY_ACCENTS: Record<string, string> = {
  lime: 'moss',
  mint: 'moss',
  orange: 'ember',
  coral: 'ember',
  peach: 'ember',
  yellow: 'sand',
  purple: 'heather',
  magenta: 'heather',
};

export function accentFor(key: string): string {
  const k = LEGACY_ACCENTS[key] ?? key;
  return (ACCENTS.find(a => a.key === k) ?? ACCENTS[0]).value;
}

export function normalizeAccentKey(key: string): string {
  const k = LEGACY_ACCENTS[key] ?? key;
  return ACCENTS.some(a => a.key === k) ? k : ACCENTS[0].key;
}

/**
 * Cormorant Garamond for names and numbers (a high-contrast book face that reads like a film title
 * card); Manrope for everything you operate. Each weight is its own family so Android never
 * substitutes a synthetic or system face.
 */
export const font = {
  display: 'CormorantGaramond-Medium',
  displayRegular: 'CormorantGaramond-Regular',
  displayItalic: 'CormorantGaramond-MediumItalic',
  ui: 'Manrope-Regular',
  uiMedium: 'Manrope-Medium',
  uiStrong: 'Manrope-SemiBold',
};

/** Type scale. Hierarchy comes from face, size and colour — never from heavy weights. */
export const type: Record<string, TextStyle> = {
  // Display line heights stay ≥ 1.2× the size: Cormorant's descenders (g, q, y, p) are deep
  // and Android clips the last line to its line box.
  scene: {
    fontFamily: font.display,
    fontSize: 50,
    lineHeight: 60,
    letterSpacing: -0.6,
  },
  title: {
    fontFamily: font.display,
    fontSize: 40,
    lineHeight: 50,
    letterSpacing: -0.3,
  },
  sheetTitle: {
    fontFamily: font.display,
    fontSize: 30,
    lineHeight: 38,
    letterSpacing: -0.2,
  },
  section: { fontFamily: font.displayItalic, fontSize: 22, lineHeight: 28 },
  body: { fontFamily: font.ui, fontSize: 16, lineHeight: 22 },
  bodyStrong: { fontFamily: font.uiStrong, fontSize: 16, lineHeight: 22 },
  secondary: { fontFamily: font.ui, fontSize: 14, lineHeight: 20 },
  caption: { fontFamily: font.ui, fontSize: 12.5, lineHeight: 17 },
  label: {
    fontFamily: font.uiMedium,
    fontSize: 11,
    lineHeight: 14,
    letterSpacing: 0.3,
  },
  numeral: {
    fontFamily: font.displayRegular,
    fontSize: 76,
    lineHeight: 80,
    fontVariant: ['lining-nums', 'tabular-nums'],
  },
};

/** 4-pt grid. */
export const space = {
  xs: 4,
  s: 8,
  m: 12,
  l: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 48,
} as const;

/** Three radii only: controls are capsules, sheets are large, small fills are 12. */
export const radius = { small: 12, sheet: 32, capsule: 999 } as const;

export const size = {
  touch: 48, // minimum hit target (Android 48 dp; covers iOS 44 pt)
  tabBarHeight: 54,
  control: 52, // round glass controls on the scene
  playControl: 64,
  rowHeight: 56,
  icon: 20,
} as const;

/** Motion: short, eased, no overshoot. */
export const motion = {
  quick: 160,
  standard: 260,
  sheet: 340,
  scene: 900,
  spring: { damping: 26, stiffness: 260, mass: 1 },
} as const;
