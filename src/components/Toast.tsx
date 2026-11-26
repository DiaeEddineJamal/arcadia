// Brief confirmations ("Sleep timer set for 30 min"). A small glass capsule under the status bar.
import React, { createContext, useCallback, useContext, useRef, useState } from 'react';
import { AccessibilityInfo, Animated, Easing, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Text } from '../design/primitives';
import { motion } from '../design/tokens';
import { Surface } from '../glass';

type ShowToast = (message: string, durationMs?: number) => void;

const ToastContext = createContext<ShowToast>(() => {});

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const insets = useSafeAreaInsets();
  const [message, setMessage] = useState<string | null>(null);
  const v = useRef(new Animated.Value(0)).current;
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const show = useCallback<ShowToast>(
    (text, durationMs = 2600) => {
      if (timer.current) clearTimeout(timer.current);
      setMessage(text);
      AccessibilityInfo.announceForAccessibility(text);
      Animated.timing(v, { toValue: 1, duration: motion.standard, easing: Easing.out(Easing.cubic), useNativeDriver: true }).start();
      timer.current = setTimeout(() => {
        Animated.timing(v, { toValue: 0, duration: motion.standard, useNativeDriver: true }).start(() => setMessage(null));
      }, durationMs);
    },
    [v],
  );

  return (
    <ToastContext.Provider value={show}>
      {children}
      {message && (
        <Animated.View
          pointerEvents="none"
          style={[
            styles.wrap,
            {
              top: insets.top + 8,
              opacity: v,
              transform: [{ translateY: v.interpolate({ inputRange: [0, 1], outputRange: [-12, 0] }) }],
            },
          ]}>
          <Surface radius={22} tone="raised" style={styles.toast}>
            <Text kind="secondary">{message}</Text>
          </Surface>
        </Animated.View>
      )}
    </ToastContext.Provider>
  );
}

export function useToast(): ShowToast {
  return useContext(ToastContext);
}

const styles = StyleSheet.create({
  wrap: { position: 'absolute', left: 0, right: 0, alignItems: 'center' },
  toast: { minHeight: 44, paddingHorizontal: 20, justifyContent: 'center' },
});
