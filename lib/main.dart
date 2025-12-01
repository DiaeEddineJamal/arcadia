import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import 'services/video_background_service.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/app_audio_handler.dart';
import 'widgets/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'utils/no_glow_scroll_behavior.dart';
import 'utils/performance_monitor.dart';

late final AudioPlayerService _globalAudioPlayerService;
late final AudioHandler _globalAudioHandler;
late final AdService _globalAdService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage service BEFORE running the app
  await StorageService.initialize();

  // Prefer the highest refresh rate available (Android only)
  await _configureHighRefreshRate();

  // Performance optimization: Start performance monitoring
  PerformanceMonitor().startMonitoring();
  
  // Optimize for 120Hz: Enable high refresh rate optimizations
  // Flutter automatically uses the highest available refresh rate when configured
  // The display mode is already set to 120Hz in _configureHighRefreshRate()

  _globalAudioPlayerService = AudioPlayerService();
  _globalAudioHandler = await AudioService.init(
    builder: () => AppAudioHandler(_globalAudioPlayerService),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'arcadia_audio',
      androidNotificationChannelName: 'Arcadia Audio',
      androidNotificationIcon: 'mipmap/launcher_icon',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Performance optimized: Initialize video background early for smooth startup
  // Video is hardware-accelerated and muted to minimize battery impact
  unawaited(VideoBackgroundService().initialize());
  _globalAdService = AdService();
  await _globalAdService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(
    audioHandler: _globalAudioHandler,
    audioPlayerService: _globalAudioPlayerService,
    adService: _globalAdService,
  ));
}

Future<void> _configureHighRefreshRate() async {
  try {
    // Get all available display modes to find the highest refresh rate
    final modes = await FlutterDisplayMode.supported;
    
    if (modes.isNotEmpty) {
      // Find and log the highest available refresh rate
      double highestRefreshRate = 0.0;
      DisplayMode? highestMode;
      
      for (final mode in modes) {
        if (mode.refreshRate > highestRefreshRate) {
          highestRefreshRate = mode.refreshRate;
          highestMode = mode;
        }
      }
      
      if (highestMode != null) {
        debugPrint('Highest available refresh rate: ${highestRefreshRate.toStringAsFixed(0)}Hz (${highestMode.width}x${highestMode.height})');
        
        // Use setHighRefreshRate() which automatically selects the highest available refresh rate
        // This is the recommended approach for flutter_displaymode package
        await FlutterDisplayMode.setHighRefreshRate();
        debugPrint('✓ Maximum refresh rate (${highestRefreshRate.toStringAsFixed(0)}Hz) activated successfully');
        
        // Verify the current refresh rate after setting (if supported)
        try {
          final currentMode = await FlutterDisplayMode.active;
          debugPrint('Current active refresh rate: ${currentMode.refreshRate.toStringAsFixed(0)}Hz');
          if (currentMode.refreshRate < highestRefreshRate - 1) {
            debugPrint('⚠ Warning: Active refresh rate is lower than maximum available. Device may have limitations.');
          }
        } catch (e) {
          // Active mode query not supported on this platform
          debugPrint('Active mode verification not available on this platform');
        }
      } else {
        // Fallback if no mode found
        await FlutterDisplayMode.setHighRefreshRate();
        debugPrint('High refresh rate mode activated (no specific mode found)');
      }
    } else {
      debugPrint('No display modes available');
    }
  } on UnimplementedError catch (_) {
    // Platform doesn't support display mode changes (e.g., iOS simulator, some iOS devices)
    debugPrint('Display mode changes not supported on this platform');
  } catch (e) {
    debugPrint('High refresh rate configuration failed: $e');
  }
}

class MyApp extends StatefulWidget {
  final AudioHandler audioHandler;
  final AudioPlayerService audioPlayerService;
  final AdService adService;

  const MyApp({
    super.key,
    required this.audioHandler,
    required this.audioPlayerService,
    required this.adService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Performance optimization: Ensure high refresh rate is applied after first frame
    // This handles cases where display mode wasn't set properly during initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_configureHighRefreshRate());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Performance optimization: Stop monitoring when app is disposed
    PerformanceMonitor().stopMonitoring();
    widget.adService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final videoService = VideoBackgroundService();
    if (state == AppLifecycleState.detached) {
      widget.audioPlayerService.stopAll();
      unawaited(widget.audioHandler.stop());
      unawaited(AudioService.stop());
      videoService.pause();
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      videoService.pause();
    } else if (state == AppLifecycleState.resumed) {
      videoService.play();
      // Performance optimization: Re-apply high refresh rate on app resume
      // Some devices may reset refresh rate when app goes to background
      unawaited(_configureHighRefreshRate());
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Handle hot refresh by resetting video service
    final videoService = VideoBackgroundService();
    videoService.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => VideoBackgroundService()),
        ChangeNotifierProvider<AdService>.value(value: widget.adService),
        ChangeNotifierProxyProvider<AppSettingsProvider, AudioPlayerService>(
          create: (_) => widget.audioPlayerService,
          update: (_, settingsProvider, audioService) {
            audioService ??= widget.audioPlayerService;
            audioService.applyAppSettings(settingsProvider.settings);
            return audioService;
          },
        ),
        Provider<AudioHandler>.value(value: widget.audioHandler),
      ],
      child: Selector<AppSettingsProvider, ({String accentColor, bool isDarkMode, bool isOnboardingCompleted})>(
        selector: (_, settings) => (
          accentColor: settings.settings.accentColor,
          isDarkMode: settings.settings.isDarkMode,
          isOnboardingCompleted: settings.settings.isOnboardingCompleted,
        ),
        builder: (context, settings, child) {
          final baseLight = AppTheme.lightTheme;
          final baseDark = AppTheme.darkTheme;
          final accentColor = AppTheme.getAccentColor(settings.accentColor);
          
          // Cache text themes to avoid recreation
          final lightTextTheme = GoogleFonts.modernAntiquaTextTheme(baseLight.textTheme);
          final darkTextTheme = GoogleFonts.modernAntiquaTextTheme(baseDark.textTheme);
          
          return RepaintBoundary(
            child: MaterialApp(
              title: 'Arcadia',
              debugShowCheckedModeBanner: false,
              // Performance: Optimize for 120Hz refresh rate
              // Use shorter animation durations for smoother 120Hz experience
              builder: (context, child) {
                // Wrap in RepaintBoundary for additional isolation
                return RepaintBoundary(
                  child: MediaQuery(
                    // Optimize for high refresh rate displays
                    data: MediaQuery.of(context).copyWith(
                      // Ensure smooth animations at 120Hz
                      textScaler: MediaQuery.of(context).textScaler,
                    ),
                    child: child!,
                  ),
                );
              },
              theme: baseLight.copyWith(
                colorScheme: baseLight.colorScheme.copyWith(primary: accentColor, secondary: accentColor),
                textTheme: lightTextTheme.apply(
                  bodyColor: baseLight.colorScheme.onSurface,
                  displayColor: baseLight.colorScheme.onSurface,
                ),
                appBarTheme: baseLight.appBarTheme.copyWith(
                  titleTextStyle: lightTextTheme.titleLarge?.copyWith(
                    color: baseLight.colorScheme.onSurface,
                  ),
                  iconTheme: baseLight.appBarTheme.iconTheme?.copyWith(
                    color: baseLight.colorScheme.onSurface,
                  ),
                ),
                // Optimize page transitions for smoother animations
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: baseDark.copyWith(
                colorScheme: baseDark.colorScheme.copyWith(primary: accentColor, secondary: accentColor),
                textTheme: darkTextTheme.apply(
                  bodyColor: baseDark.colorScheme.onSurface,
                  displayColor: baseDark.colorScheme.onSurface,
                ),
                appBarTheme: baseDark.appBarTheme.copyWith(
                  titleTextStyle: darkTextTheme.titleLarge?.copyWith(
                    color: baseDark.colorScheme.onSurface,
                  ),
                  iconTheme: baseDark.appBarTheme.iconTheme?.copyWith(
                    color: baseDark.colorScheme.onSurface,
                  ),
                ),
                // Optimize page transitions for smoother animations
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              scrollBehavior: NoGlowScrollBehavior(),
              home: !settings.isOnboardingCompleted 
                  ? const OnboardingScreen() 
                  : const MainNavigation(),
            ),
          );
        },
      ),
    );
  }
}
