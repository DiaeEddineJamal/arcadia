/**
 * A glass sheet rising from the bottom of the scene. One at a time, a grabber, drag down or tap
 * outside to dismiss, Android back closes it. Rendered in-tree (not a Modal window) so its glass
 * samples the same backdrop as the rest of the interface.
 */
import React, { useEffect, useRef, useState } from 'react';
import {
  Animated,
  BackHandler,
  Easing,
  PanResponder,
  Pressable,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text, useReducedMotion } from '../design/primitives';
import { motion, radius, space } from '../design/tokens';
import { Surface } from '../glass';

const OVERHANG = 48; // sheet extends below the screen so only its top corners are rounded

export function Sheet({
  visible,
  onClose,
  title,
  accessory,
  heightFraction = 0.62,
  children,
}: {
  visible: boolean;
  onClose: () => void;
  title: string;
  accessory?: React.ReactNode;
  heightFraction?: number;
  children: React.ReactNode;
}) {
  const { height: screenH } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const reduced = useReducedMotion();
  const sheetH = Math.round(screenH * heightFraction) + insets.bottom;
  const y = useRef(new Animated.Value(sheetH)).current;
  const [mounted, setMounted] = useState(visible);
  const closeRef = useRef(onClose);
  closeRef.current = onClose;

  useEffect(() => {
    if (visible) {
      setMounted(true);
      if (reduced) y.setValue(0);
      else Animated.spring(y, { toValue: 0, useNativeDriver: true, ...motion.spring }).start();
    } else if (mounted) {
      Animated.timing(y, {
        toValue: sheetH,
        duration: reduced ? 0 : motion.standard,
        easing: Easing.in(Easing.cubic),
        useNativeDriver: true,
      }).start(() => setMounted(false));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visible]);

  useEffect(() => {
    if (!visible) return;
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      closeRef.current();
      return true;
    });
    return () => sub.remove();
  }, [visible]);

  const pan = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_, g) => g.dy > 6 && Math.abs(g.dy) > Math.abs(g.dx),
      onPanResponderMove: (_, g) => y.setValue(Math.max(0, g.dy)),
      onPanResponderRelease: (_, g) => {
        if (g.dy > 120 || g.vy > 0.9) closeRef.current();
        else Animated.spring(y, { toValue: 0, useNativeDriver: true, ...motion.spring }).start();
      },
    }),
  ).current;

  if (!mounted) return null;

  return (
    <View style={StyleSheet.absoluteFill} pointerEvents="box-none">
      <Animated.View
        style={[
          StyleSheet.absoluteFill,
          styles.scrim,
          { opacity: y.interpolate({ inputRange: [0, sheetH], outputRange: [1, 0], extrapolate: 'clamp' }) },
        ]}>
        <Pressable style={StyleSheet.absoluteFill} onPress={onClose} accessibilityLabel="Close" />
      </Animated.View>
      <Animated.View
        style={[styles.sheetWrap, { height: sheetH + OVERHANG, bottom: -OVERHANG, transform: [{ translateY: y }] }]}
        accessibilityViewIsModal>
        <Surface radius={radius.sheet} style={styles.sheet}>
          <View {...pan.panHandlers} style={styles.header}>
            <View style={styles.grabber} />
            <View style={styles.titleRow}>
              <Text kind="sheetTitle" accessibilityRole="header" style={styles.title}>
                {title}
              </Text>
              {accessory}
            </View>
          </View>
          <View style={[styles.body, { paddingBottom: insets.bottom + OVERHANG }]}>{children}</View>
        </Surface>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  scrim: { backgroundColor: 'rgba(6,8,5,0.32)' },
  sheetWrap: { position: 'absolute', left: 8, right: 8 },
  sheet: { flex: 1 },
  header: { paddingTop: 10, paddingHorizontal: space.xxl },
  grabber: {
    alignSelf: 'center',
    width: 36,
    height: 5,
    borderRadius: 3,
    backgroundColor: 'rgba(238,234,224,0.3)',
    marginBottom: space.l,
  },
  titleRow: { flexDirection: 'row', alignItems: 'center', minHeight: 48 },
  title: { flex: 1 },
  body: { flex: 1 },
});
