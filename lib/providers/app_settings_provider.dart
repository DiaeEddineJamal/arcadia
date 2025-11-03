import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  AppSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = StorageService.getSettings();
      _settings = loadedSettings;
      notifyListeners();
    } catch (e) {
      // Handle error loading settings
      print('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    
    try {
      await StorageService.updateSettings(_settings);
    } catch (e) {
      // Handle error saving settings
      print('Error saving settings: $e');
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    final newSettings = _settings.copyWith(isDarkMode: isDark);
    await updateSettings(newSettings);
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_settings.isDarkMode);
  }

  Future<void> setAccentColor(String colorName) async {
    final newSettings = _settings.copyWith(accentColor: colorName);
    await updateSettings(newSettings);
  }

  Future<void> setMasterVolume(double volume) async {
    final newSettings = _settings.copyWith(masterVolume: volume);
    await updateSettings(newSettings);
  }

  Future<void> toggleBackgroundPlay() async {
    final newSettings = _settings.copyWith(
      enableBackgroundPlay: !_settings.enableBackgroundPlay,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleFadeInOut() async {
    final newSettings = _settings.copyWith(
      enableFadeInOut: !_settings.enableFadeInOut,
    );
    await updateSettings(newSettings);
  }

  Future<void> setFadeDurations(int fadeInDuration, int fadeOutDuration) async {
    final newSettings = _settings.copyWith(
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
    );
    await updateSettings(newSettings);
  }

  Future<void> setSleepTimer(int minutes) async {
    final newSettings = _settings.copyWith(defaultSleepTimer: minutes);
    await updateSettings(newSettings);
  }

  Future<void> toggleGrainOverlay() async {
    final newSettings = _settings.copyWith(
      enableGrainOverlay: !_settings.enableGrainOverlay,
    );
    await updateSettings(newSettings);
  }

  Future<void> setGrainIntensity(double intensity) async {
    final newSettings = _settings.copyWith(grainIntensity: intensity);
    await updateSettings(newSettings);
  }

  Future<void> completeOnboarding() async {
    final newSettings = _settings.copyWith(isOnboardingCompleted: true);
    await updateSettings(newSettings);
  }
}