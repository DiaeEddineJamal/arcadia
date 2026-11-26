module.exports = {
  preset: '@react-native/jest-preset',
  setupFiles: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?|@react-native-vector-icons|react-native-video|react-native-google-mobile-ads|react-native-safe-area-context|@react-native-async-storage)/)',
  ],
};
