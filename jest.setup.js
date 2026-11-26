/* eslint-env jest */
// Native modules are not available under Jest; mock the ones the app touches at import time.
jest.mock('@react-native-async-storage/async-storage', () => {
  const store = new Map();
  return {
    __esModule: true,
    default: {
      getItem: jest.fn(async k => (store.has(k) ? store.get(k) : null)),
      setItem: jest.fn(async (k, v) => void store.set(k, v)),
      removeItem: jest.fn(async k => void store.delete(k)),
      clear: jest.fn(async () => store.clear()),
    },
  };
});
jest.mock('react-native-video', () => {
  const { View } = require('react-native');
  return { __esModule: true, default: View, ViewType: { TEXTURE: 1, SURFACE: 0 } };
});
jest.mock('react-native-google-mobile-ads', () => ({
  __esModule: true,
  default: () => ({ initialize: jest.fn(async () => []) }),
  AdEventType: {},
  InterstitialAd: { createForAdRequest: jest.fn() },
  BannerAd: () => null,
  BannerAdSize: { LARGE_BANNER: 'LARGE_BANNER' },
  TestIds: { BANNER: 'test-banner', INTERSTITIAL: 'test-interstitial' },
}));
jest.mock('@react-native-vector-icons/lucide', () => ({ Lucide: () => null }));
