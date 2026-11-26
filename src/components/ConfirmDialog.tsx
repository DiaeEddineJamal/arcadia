// Centered confirmation for destructive actions.
import React, { useEffect, useRef } from 'react';
import { Animated, BackHandler, Pressable, StyleSheet, View } from 'react-native';
import { Button, Text } from '../design/primitives';
import { color, motion, space } from '../design/tokens';
import { Surface } from '../glass';

export function ConfirmDialog({
  visible,
  title,
  message,
  confirmTitle,
  onConfirm,
  onCancel,
}: {
  visible: boolean;
  title: string;
  message: string;
  confirmTitle: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(v, { toValue: visible ? 1 : 0, duration: motion.standard, useNativeDriver: true }).start();
    if (!visible) return;
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      onCancel();
      return true;
    });
    return () => sub.remove();
  }, [visible, v, onCancel]);

  if (!visible) return null;
  return (
    <Animated.View style={[StyleSheet.absoluteFill, styles.scrim, { opacity: v }]}>
      <Pressable style={StyleSheet.absoluteFill} onPress={onCancel} accessibilityLabel="Cancel" />
      <Animated.View
        accessibilityViewIsModal
        style={{ transform: [{ scale: v.interpolate({ inputRange: [0, 1], outputRange: [0.96, 1] }) }] }}>
        <Surface radius={28} tone="raised" style={styles.card}>
          <Text kind="sheetTitle" accessibilityRole="header">
            {title}
          </Text>
          <Text tone="secondary" style={styles.message}>
            {message}
          </Text>
          <View style={styles.actions}>
            <Button title="Cancel" accent={color.paper} onPress={onCancel} />
            <Button title={confirmTitle} destructive accent={color.danger} onPress={onConfirm} />
          </View>
        </Surface>
      </Animated.View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  scrim: { backgroundColor: 'rgba(6,8,5,0.5)', alignItems: 'center', justifyContent: 'center', padding: space.xxl },
  card: { width: 320, padding: space.xxl, paddingBottom: space.m },
  message: { marginTop: space.s },
  actions: { flexDirection: 'row', justifyContent: 'flex-end', marginTop: space.l, marginRight: -space.m },
});
