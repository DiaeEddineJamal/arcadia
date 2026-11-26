/**
 * The bottom bar: navigation and the now-playing player, after BitChord.
 *
 * Expanded: a full-width glass player above a full-width glass tab bar whose selected tab is a
 * lighter pill that refracts the bar's own glass. Scrolling a list down collapses both into one
 * row: the tab bar shrinks to a glass circle holding the current tab, and the player slides down
 * beside it as a capsule. Scrolling back up, or tapping the circle, expands it again.
 */
import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { ClipThumb } from './Scene';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { getSound, mixTitle } from '../data/sounds';
import {
  Icon,
  IconName,
  PlayGlyph,
  Tappable,
  Text,
  haptic,
  useReducedMotion,
} from '../design/primitives';
import { color, font, motion } from '../design/tokens';
import { Glass } from '../glass';
import { useApp } from '../state/AppContext';

export type Tab = 'listen' | 'sounds' | 'settings';

const TABS: { key: Tab; label: string; icon: IconName }[] = [
  { key: 'listen', label: 'Listen', icon: 'audio-lines' },
  { key: 'sounds', label: 'Sounds', icon: 'library' },
  { key: 'settings', label: 'Settings', icon: 'settings-2' },
];

export const BAR_H = 64;
export const PLAYER_H = 58;
const CIRCLE = 58;
const SIDE = 16;
const GAP = 8;
const INSET = 4;

export function tabBarBottom(bottomInset: number) {
  return Math.max(bottomInset, 12) + 6;
}

/** Height the bottom chrome occupies (for content padding). */
export function bottomChromeHeight(bottomInset: number, withPlayer: boolean) {
  return tabBarBottom(bottomInset) + BAR_H + (withPlayer ? PLAYER_H + GAP : 0);
}

/** Window rect of the mini player's artwork (for the open / close transition). */
export function miniArtRect(
  screenW: number,
  screenH: number,
  bottomInset: number,
  collapsed: boolean,
) {
  const bottom = tabBarBottom(bottomInset);
  const playerBottom = collapsed ? bottom : bottom + BAR_H + GAP;
  const playerLeft = collapsed ? SIDE + CIRCLE + GAP : SIDE;
  const top = screenH - playerBottom - PLAYER_H;
  return {
    x: playerLeft + 9,
    y: top + (PLAYER_H - 40) / 2,
    width: 40,
    height: 40,
  };
}

export function BottomBar({
  tab,
  onChange,
  collapsed,
  onExpand,
  showPlayer,
  onOpenPlayer,
  leadId,
}: {
  tab: Tab;
  onChange: (t: Tab) => void;
  collapsed: boolean;
  onExpand: () => void;
  showPlayer: boolean;
  onOpenPlayer: () => void;
  /** The sound leading the scene; its place is the player's artwork. */
  leadId: string | null;
}) {
  const insets = useSafeAreaInsets();
  const { width: W } = useWindowDimensions();
  const reduced = useReducedMotion();
  const { mixer, pauseAll, resumeAll } = useApp();

  const canCollapse = collapsed && showPlayer;
  const c = useRef(new Animated.Value(canCollapse ? 1 : 0)).current;
  const playerIn = useRef(new Animated.Value(showPlayer ? 1 : 0)).current;
  const index = TABS.findIndex(t => t.key === tab);
  const pill = useRef(new Animated.Value(index)).current;

  useEffect(() => {
    Animated.timing(c, {
      toValue: canCollapse ? 1 : 0,
      duration: reduced ? 0 : 340,
      easing: Easing.bezier(0.2, 0.8, 0.2, 1),
      useNativeDriver: false,
    }).start();
  }, [canCollapse, reduced, c]);

  useEffect(() => {
    Animated.timing(playerIn, {
      toValue: showPlayer ? 1 : 0,
      duration: reduced ? 0 : motion.standard,
      useNativeDriver: false,
    }).start();
  }, [showPlayer, reduced, playerIn]);

  useEffect(() => {
    if (reduced) pill.setValue(index);
    else
      Animated.spring(pill, {
        toValue: index,
        useNativeDriver: true,
        ...motion.spring,
      }).start();
  }, [index, reduced, pill]);

  const bottom = tabBarBottom(insets.bottom);
  const fullW = W - SIDE * 2;
  const itemW = (fullW - INSET * 2) / TABS.length;

  const barW = c.interpolate({
    inputRange: [0, 1],
    outputRange: [fullW, CIRCLE],
  });
  const barH = c.interpolate({
    inputRange: [0, 1],
    outputRange: [BAR_H, CIRCLE],
  });
  const tabsOpacity = c.interpolate({
    inputRange: [0, 0.4],
    outputRange: [1, 0],
    extrapolate: 'clamp',
  });
  const iconOpacity = c.interpolate({
    inputRange: [0.6, 1],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });

  const playerLeft = c.interpolate({
    inputRange: [0, 1],
    outputRange: [SIDE, SIDE + CIRCLE + GAP],
  });
  const playerBottom = c.interpolate({
    inputRange: [0, 1],
    outputRange: [bottom + BAR_H + GAP, bottom],
  });

  const names = mixer.tracks
    .map(t => getSound(t.id)?.name)
    .filter((n): n is string => !!n);
  const playing = mixer.isMasterPlaying;
  const playingCount = mixer.tracks.filter(t => t.playing).length;
  const current = TABS[index];

  return (
    <View pointerEvents="box-none" style={StyleSheet.absoluteFill}>
      {/* player */}
      <Animated.View
        pointerEvents={showPlayer ? 'box-none' : 'none'}
        style={[
          styles.playerWrap,
          {
            left: playerLeft,
            right: SIDE,
            bottom: playerBottom,
            opacity: playerIn,
            transform: [
              {
                translateY: playerIn.interpolate({
                  inputRange: [0, 1],
                  outputRange: [14, 0],
                }),
              },
            ],
          },
        ]}
      >
        <Glass radius={PLAYER_H / 2} style={styles.player}>
          <Tappable
            onPress={onOpenPlayer}
            label="Open the scene"
            scaleTo={0.98}
            style={styles.playerBody}
          >
            {/* Always mounted, so its clip is already playing in sync when the player shows. */}
            {mixer.tracks.length > 0 ? (
              <ClipThumb leadId={leadId} style={styles.art} />
            ) : (
              <View style={styles.art} />
            )}
            <View style={styles.playerText}>
              <Text numberOfLines={1} style={styles.playerTitle}>
                {mixTitle(names)}
              </Text>
              <Text kind="caption" tone="secondary" numberOfLines={1}>
                {playing
                  ? `${playingCount} ${
                      playingCount === 1 ? 'layer' : 'layers'
                    } playing`
                  : 'Paused'}
              </Text>
            </View>
          </Tappable>
          <Tappable
            label={playing ? 'Pause' : 'Play'}
            scaleTo={0.88}
            onPress={() => {
              haptic.tap();
              playing ? pauseAll() : resumeAll();
            }}
            style={styles.playerButton}
          >
            <PlayGlyph playing={playing} size={22} />
          </Tappable>
        </Glass>
      </Animated.View>

      {/* tab bar / circle */}
      <Animated.View
        style={[styles.barWrap, { bottom, width: barW, height: barH }]}
      >
        <Glass
          exportId="tabbar"
          radius={BAR_H / 2}
          style={styles.fill}
          accessibilityRole="tablist"
        >
          <Animated.View
            style={[styles.tabs, { opacity: tabsOpacity }]}
            pointerEvents={canCollapse ? 'none' : 'auto'}
          >
            <Animated.View
              style={[
                styles.pillWrap,
                {
                  width: itemW,
                  transform: [
                    {
                      translateX: pill.interpolate({
                        inputRange: [0, 1],
                        outputRange: [0, itemW],
                      }),
                    },
                  ],
                },
              ]}
            >
              <Glass
                backdrop="tabbar"
                material="lift"
                radius={(BAR_H - INSET * 2) / 2}
                style={styles.fill}
              />
            </Animated.View>
            {TABS.map(t => {
              const selected = t.key === tab;
              return (
                <Tappable
                  key={t.key}
                  role="tab"
                  selected={selected}
                  label={t.label}
                  scaleTo={0.94}
                  onPress={() => {
                    if (!selected) haptic.tap();
                    onChange(t.key);
                  }}
                  style={[styles.item, { width: itemW }]}
                >
                  <Icon
                    name={t.icon}
                    size={20}
                    tint={selected ? color.paper : color.paperSecondary}
                  />
                  <Text
                    kind="label"
                    tint={selected ? color.paper : color.paperSecondary}
                    style={styles.label}
                  >
                    {t.label}
                  </Text>
                </Tappable>
              );
            })}
          </Animated.View>
          <Animated.View
            style={[
              StyleSheet.absoluteFill,
              styles.circleIcon,
              { opacity: iconOpacity },
            ]}
            pointerEvents={canCollapse ? 'auto' : 'none'}
          >
            <Tappable
              label={`${current.label}, show all tabs`}
              onPress={onExpand}
              style={styles.circleHit}
            >
              <Icon name={current.icon} size={22} tint={color.paper} />
            </Tappable>
          </Animated.View>
        </Glass>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  barWrap: { position: 'absolute', left: SIDE },
  tabs: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: INSET,
  },
  pillWrap: { position: 'absolute', left: INSET, top: INSET, bottom: INSET },
  item: { height: BAR_H, alignItems: 'center', justifyContent: 'center' },
  label: { marginTop: 3 },
  circleIcon: { alignItems: 'center', justifyContent: 'center' },
  circleHit: {
    width: CIRCLE,
    height: CIRCLE,
    alignItems: 'center',
    justifyContent: 'center',
  },
  playerWrap: { position: 'absolute', height: PLAYER_H },
  player: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: 9,
    paddingRight: 6,
  },
  playerBody: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 12 },
  art: { width: 40, height: 40, borderRadius: 10, backgroundColor: color.fill },
  playerText: { flex: 1 },
  playerTitle: {
    fontFamily: font.uiStrong,
    fontSize: 15,
    lineHeight: 21,
    color: color.paper,
  },
  playerButton: {
    width: 46,
    height: 46,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
