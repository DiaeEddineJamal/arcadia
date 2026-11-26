// Banner placement used when ADS_ENABLED is true (currently off). Shown only once an ad loads.
import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { BannerAd, BannerAdSize } from 'react-native-google-mobile-ads';
import { ADS_ENABLED } from '../services/ads';

export function BannerAdSlot({ unitId }: { unitId: string }) {
  const [loaded, setLoaded] = useState(false);
  if (!ADS_ENABLED) return null;
  return (
    <View style={loaded ? styles.slot : styles.hidden}>
      <BannerAd
        unitId={unitId}
        size={BannerAdSize.LARGE_BANNER}
        onAdLoaded={() => setLoaded(true)}
        onAdFailedToLoad={() => setLoaded(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  slot: { alignItems: 'center', marginTop: 32 },
  hidden: { height: 0, opacity: 0, overflow: 'hidden' },
});
