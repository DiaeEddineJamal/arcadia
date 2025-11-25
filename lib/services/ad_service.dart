import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/ad_helper.dart';

class AdService extends ChangeNotifier {
  bool _initialized = false;
  bool _isHomeBannerLoading = false;
  bool _isSettingsBannerLoading = false;
  BannerAd? _homeBannerAd;
  BannerAd? _settingsBannerAd;
  InterstitialAd? _libraryInterstitial;
  DateTime? _lastInterstitialShownAt;

  BannerAd? get homeBannerAd => _homeBannerAd;
  BannerAd? get settingsBannerAd => _settingsBannerAd;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadHomeBannerAd();
    _loadSettingsBannerAd();
    _preloadLibraryInterstitial();
  }

  void _loadHomeBannerAd() {
    if (!_initialized || _isHomeBannerLoading) return;
    _isHomeBannerLoading = true;
    final banner = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: AdHelper.homeBannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _homeBannerAd = ad as BannerAd;
          _isHomeBannerLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _homeBannerAd = null;
          _isHomeBannerLoading = false;
          notifyListeners();
        },
      ),
    );
    banner.load();
  }

  void _loadSettingsBannerAd() {
    if (!_initialized || _isSettingsBannerLoading) return;
    _isSettingsBannerLoading = true;
    final banner = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: AdHelper.settingsBannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _settingsBannerAd = ad as BannerAd;
          _isSettingsBannerLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _settingsBannerAd = null;
          _isSettingsBannerLoading = false;
          notifyListeners();
        },
      ),
    );
    banner.load();
  }

  void _preloadLibraryInterstitial() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: AdHelper.libraryInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _libraryInterstitial = ad
            ..fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _libraryInterstitial = null;
                _lastInterstitialShownAt = DateTime.now();
                _preloadLibraryInterstitial();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _libraryInterstitial = null;
                _preloadLibraryInterstitial();
              },
            );
        },
        onAdFailedToLoad: (error) {
          _libraryInterstitial = null;
          Future<void>.delayed(const Duration(seconds: 30), _preloadLibraryInterstitial);
        },
      ),
    );
  }

  Future<void> maybeShowLibraryInterstitial() async {
    if (_libraryInterstitial == null) return;
    final now = DateTime.now();
    if (_lastInterstitialShownAt != null &&
        now.difference(_lastInterstitialShownAt!) < AdHelper.interstitialCooldown) {
      return;
    }
    final ad = _libraryInterstitial;
    _libraryInterstitial = null;
    await ad?.show();
    if (_libraryInterstitial == null) {
      _preloadLibraryInterstitial();
    }
  }

  void refreshBanner() {
    _homeBannerAd?.dispose();
    _homeBannerAd = null;
    _loadHomeBannerAd();
  }

  @override
  void dispose() {
    _homeBannerAd?.dispose();
    _settingsBannerAd?.dispose();
    _libraryInterstitial?.dispose();
    super.dispose();
  }
}

