import 'package:hive_flutter/hive_flutter.dart';
import '../models/sound.dart';
import '../models/sound_mix.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _soundsBoxName = 'sounds';
  static const String _mixesBoxName = 'mixes';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';
  
  static Box<Sound>? _soundsBox;
  static Box<SoundMix>? _mixesBox;
  static Box<AppSettings>? _settingsBox;
  static List<Sound> _cachedSounds = [];
  static const Sound _tavernSound = Sound(
    id: 'tavern',
    name: 'Enchanted Tavern',
    fileName: 'tavern.mp3',
    category: 'Fantasy',
    iconPath: 'assets/icons/fantasy.png',
    defaultVolume: 0.6,
  );

  static const Sound _piratesSound = Sound(
    id: 'pirates',
    name: 'Pirates of the Caribbean',
    fileName: 'pirates.mp3',
    category: 'Fantasy',
    iconPath: 'assets/icons/fantasy.png',
    defaultVolume: 0.65,
  );

  static const Sound _tavernSingingSound = Sound(
    id: 'tavern_singing',
    name: 'Tavern Singing',
    fileName: 'tavern_singing.mp3',
    category: 'Fantasy',
    iconPath: 'assets/icons/fantasy.png',
    defaultVolume: 0.55,
  );
  
  // Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SoundAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SoundTrackAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SoundMixAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    
    // Open boxes
    _soundsBox = await Hive.openBox<Sound>(_soundsBoxName);
    _mixesBox = await Hive.openBox<SoundMix>(_mixesBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    
    // Initialize with default sounds if empty
    if (_soundsBox!.isEmpty) {
      await _initializeDefaultSounds();
    }

    await _refreshSoundCache();
    await _ensureLatestDefaultSounds();
    
    // Initialize with default settings if empty
    if (_settingsBox!.get(_settingsKey) == null) {
      await _settingsBox!.put(_settingsKey, const AppSettings());
    }
  }
  
  // Sound operations
  static List<Sound> getAllSounds() {
    return List<Sound>.unmodifiable(_cachedSounds);
  }
  
  static Sound? getSound(String id) {
    try {
      return _cachedSounds.firstWhere((sound) => sound.id == id);
    } catch (_) {
      return null;
    }
  }
  
  static List<Sound> getSoundsByCategory(String category) {
    return _cachedSounds.where((sound) => sound.category == category).toList();
  }
  
  static Future<void> addSound(Sound sound) async {
    await _soundsBox?.put(sound.id, sound);
    await _refreshSoundCache();
  }
  
  static Future<void> updateSound(Sound sound) async {
    await _soundsBox?.put(sound.id, sound);
    await _refreshSoundCache();
  }
  
  static Future<void> deleteSound(String id) async {
    await _soundsBox?.delete(id);
    await _refreshSoundCache();
  }
  
  // Sound mix operations
  static List<SoundMix> getAllMixes() {
    return _mixesBox?.values.toList() ?? [];
  }
  
  static List<SoundMix> getFavoriteMixes() {
    return _mixesBox?.values
        .where((mix) => mix.isFavorite)
        .toList() ?? [];
  }
  
  static SoundMix? getMix(String id) {
    return _mixesBox?.values.firstWhere(
      (mix) => mix.id == id,
      orElse: () => throw StateError('Mix not found'),
    );
  }
  
  static Future<void> saveMix(SoundMix mix) async {
    await _mixesBox?.put(mix.id, mix);
  }
  
  static Future<void> updateMix(SoundMix mix) async {
    final updatedMix = mix.copyWith(updatedAt: DateTime.now());
    await _mixesBox?.put(mix.id, updatedMix);
  }
  
  static Future<void> deleteMix(String id) async {
    await _mixesBox?.delete(id);
  }
  
  static Future<void> toggleMixFavorite(String id) async {
    final mix = getMix(id);
    if (mix != null) {
      final updatedMix = mix.copyWith(
        isFavorite: !mix.isFavorite,
        updatedAt: DateTime.now(),
      );
      await updateMix(updatedMix);
    }
  }
  
  // Settings operations
  static AppSettings getSettings() {
    try {
      if (_settingsBox == null) {
        throw StateError('Settings box not initialized');
      }
      return _settingsBox!.get(_settingsKey) ?? const AppSettings();
    } catch (e) {
      // Return default settings if there's any error
      return const AppSettings();
    }
  }
  
  static Future<void> updateSettings(AppSettings settings) async {
    await _settingsBox?.put(_settingsKey, settings);
  }
  
  static Future<void> resetSettings() async {
    await _settingsBox?.put(_settingsKey, const AppSettings());
  }
  
  // Initialize default sounds
  static Future<void> _initializeDefaultSounds() async {
    final defaultSounds = [
      // Nature sounds
      const Sound(
        id: 'rain_light',
        name: 'Light Rain',
        fileName: 'rain_light.mp3',
        category: 'Rain',
        iconPath: 'assets/icons/rain.png',
        defaultVolume: 0.7,
      ),
      const Sound(
        id: 'rain_heavy',
        name: 'Heavy Rain',
        fileName: 'rain_heavy.mp3',
        category: 'Rain',
        iconPath: 'assets/icons/rain_heavy.png',
        defaultVolume: 0.6,
      ),
      const Sound(
        id: 'thunder',
        name: 'Thunder',
        fileName: 'thunder.mp3',
        category: 'Rain',
        iconPath: 'assets/icons/thunder.png',
        defaultVolume: 0.5,
      ),
      const Sound(
        id: 'ocean_waves',
        name: 'Ocean Waves',
        fileName: 'ocean_waves.mp3',
        category: 'Ocean',
        iconPath: 'assets/icons/waves.png',
        defaultVolume: 0.8,
      ),
      const Sound(
        id: 'forest',
        name: 'Forest',
        fileName: 'forest.mp3',
        category: 'Nature',
        iconPath: 'assets/icons/forest.png',
        defaultVolume: 0.7,
      ),
      const Sound(
        id: 'wind',
        name: 'Wind',
        fileName: 'wind.mp3',
        category: 'Wind',
        iconPath: 'assets/icons/wind.png',
        defaultVolume: 0.6,
      ),
      
      // White noise
      const Sound(
        id: 'white_noise',
        name: 'White Noise',
        fileName: 'white_noise.mp3',
        category: 'White Noise',
        iconPath: 'assets/icons/white_noise.png',
        defaultVolume: 0.5,
      ),
      const Sound(
        id: 'pink_noise',
        name: 'Pink Noise',
        fileName: 'pink_noise.mp3',
        category: 'White Noise',
        iconPath: 'assets/icons/pink_noise.png',
        defaultVolume: 0.5,
      ),
      const Sound(
        id: 'brown_noise',
        name: 'Brown Noise',
        fileName: 'brown_noise.mp3',
        category: 'White Noise',
        iconPath: 'assets/icons/brown_noise.png',
        defaultVolume: 0.5,
      ),
      
      // Ambient
      const Sound(
        id: 'fireplace',
        name: 'Fireplace',
        fileName: 'fireplace.mp3',
        category: 'Fire',
        iconPath: 'assets/icons/fireplace.png',
        defaultVolume: 0.7,
      ),
      const Sound(
        id: 'cafe',
        name: 'Café Ambience',
        fileName: 'cafe.mp3',
        category: 'Cafe',
        iconPath: 'assets/icons/cafe.png',
        defaultVolume: 0.6,
        isPremium: true,
      ),
      const Sound(
        id: 'library',
        name: 'Library',
        fileName: 'library.mp3',
        category: 'Ambient',
        iconPath: 'assets/icons/library.png',
        defaultVolume: 0.4,
        isPremium: true,
      ),
      _tavernSound,
      _piratesSound,
      _tavernSingingSound,
    ];
    
    for (final sound in defaultSounds) {
      await _soundsBox?.put(sound.id, sound);
    }

    _cachedSounds = List<Sound>.from(defaultSounds);
  }
  
  // Utility methods
  static Future<void> clearAllData() async {
    await _soundsBox?.clear();
    await _mixesBox?.clear();
    await _settingsBox?.clear();
    
    // Reinitialize with defaults
    await _initializeDefaultSounds();
    await _settingsBox?.put(_settingsKey, const AppSettings());
    await _refreshSoundCache();
  }
  
  static Future<void> exportData() async {
    // TODO: Implement data export functionality
    // This could export user mixes and settings to a JSON file
  }
  
  static Future<void> importData(Map<String, dynamic> data) async {
    // TODO: Implement data import functionality
    // This could import user mixes and settings from a JSON file
  }
  
  // Close all boxes (call this when app is closing)
  static Future<void> close() async {
    await _soundsBox?.close();
    await _mixesBox?.close();
    await _settingsBox?.close();
  }

  static Future<void> _refreshSoundCache() async {
    _cachedSounds = _soundsBox?.values.toList(growable: false) ?? [];
  }

  static Future<void> _ensureLatestDefaultSounds() async {
    if (_soundsBox == null) return;

    bool updated = false;

    if (!_soundsBox!.containsKey(_tavernSound.id)) {
      await _soundsBox!.put(_tavernSound.id, _tavernSound);
      updated = true;
    }

    if (!_soundsBox!.containsKey(_piratesSound.id)) {
      await _soundsBox!.put(_piratesSound.id, _piratesSound);
      updated = true;
    }

    if (!_soundsBox!.containsKey(_tavernSingingSound.id)) {
      await _soundsBox!.put(_tavernSingingSound.id, _tavernSingingSound);
      updated = true;
    }

    if (updated) {
      await _refreshSoundCache();
    }
  }
}