/**
 * Arcadia — ambient sound for focus, rest and sleep.
 */
import React, { useEffect } from 'react';
import { StatusBar, StyleSheet, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { ToastProvider } from './src/components/Toast';
import { color } from './src/design/tokens';
import { GlassQualityProvider } from './src/glass';
import { MainNavigation } from './src/screens/MainNavigation';
import { OnboardingScreen } from './src/screens/OnboardingScreen';
import { initializeAds } from './src/services/ads';
import { AppProvider, useApp } from './src/state/AppContext';

function Root() {
  const { ready, settings } = useApp();

  useEffect(() => {
    initializeAds();
  }, []);

  return (
    <GlassQualityProvider value={settings.glassQuality}>
      <ToastProvider>
        <View style={styles.root}>
          <StatusBar barStyle="light-content" />
          {!ready ? null : settings.isOnboardingCompleted ? <MainNavigation /> : <OnboardingScreen />}
        </View>
      </ToastProvider>
    </GlassQualityProvider>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppProvider>
        <Root />
      </AppProvider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: color.ink },
});
