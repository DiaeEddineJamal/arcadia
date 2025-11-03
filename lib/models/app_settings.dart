import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends Equatable {
  @HiveField(0)
  final bool isDarkMode;
  
  @HiveField(1)
  final double masterVolume;
  
  @HiveField(2)
  final bool enableBackgroundPlay;
  
  @HiveField(3)
  final bool enableNotifications;
  
  @HiveField(4)
  final int defaultSleepTimer; // in minutes
  
  @HiveField(5)
  final bool enableFadeInOut;
  
  @HiveField(6)
  final int fadeInDuration; // in seconds
  
  @HiveField(7)
  final int fadeOutDuration; // in seconds
  
  @HiveField(8)
  final bool enableGrainOverlay;
  
  @HiveField(9)
  final double grainIntensity;
  
  @HiveField(10)
  final String accentColor;
  
  @HiveField(11)
  final bool isOnboardingCompleted;

  const AppSettings({
    this.isDarkMode = true,
    this.masterVolume = 0.8,
    this.enableBackgroundPlay = true,
    this.enableNotifications = true,
    this.defaultSleepTimer = 30,
    this.enableFadeInOut = false, // Disabled by default for better performance
    this.fadeInDuration = 3,
    this.fadeOutDuration = 5,
    this.enableGrainOverlay = true,
    this.grainIntensity = 0.3,
    this.accentColor = 'lime',
    this.isOnboardingCompleted = false,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    double? masterVolume,
    bool? enableBackgroundPlay,
    bool? enableNotifications,
    int? defaultSleepTimer,
    bool? enableFadeInOut,
    int? fadeInDuration,
    int? fadeOutDuration,
    bool? enableGrainOverlay,
    double? grainIntensity,
    String? accentColor,
    bool? isOnboardingCompleted,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      masterVolume: masterVolume ?? this.masterVolume,
      enableBackgroundPlay: enableBackgroundPlay ?? this.enableBackgroundPlay,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      defaultSleepTimer: defaultSleepTimer ?? this.defaultSleepTimer,
      enableFadeInOut: enableFadeInOut ?? this.enableFadeInOut,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      enableGrainOverlay: enableGrainOverlay ?? this.enableGrainOverlay,
      grainIntensity: grainIntensity ?? this.grainIntensity,
      accentColor: accentColor ?? this.accentColor,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        masterVolume,
        enableBackgroundPlay,
        enableNotifications,
        defaultSleepTimer,
        enableFadeInOut,
        fadeInDuration,
        fadeOutDuration,
        enableGrainOverlay,
        grainIntensity,
        accentColor,
        isOnboardingCompleted,
      ];
}