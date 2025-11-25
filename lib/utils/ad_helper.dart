import 'dart:io';

class AdHelper {
  static const Duration interstitialCooldown = Duration(minutes: 2);

  static String get homeBannerAdUnitId {
    if (Platform.isAndroid) {
      // Real AdMob banner ad unit ID
      return 'ca-app-pub-6329609540816457/3905620831';
    } else if (Platform.isIOS) {
      // TODO: Add your iOS banner ad unit ID once created in AdMob
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID for now
    }
    throw UnsupportedError('Unsupported platform for banner ads');
  }

  static String get libraryInterstitialUnitId {
    if (Platform.isAndroid) {
      // Real AdMob interstitial ad unit ID
      return 'ca-app-pub-6329609540816457/8798854867';
    } else if (Platform.isIOS) {
      // TODO: Add your iOS interstitial ad unit ID once created in AdMob
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID for now
    }
    throw UnsupportedError('Unsupported platform for interstitial ads');
  }
}

