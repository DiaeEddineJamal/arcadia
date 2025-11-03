import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/glassmorphism_widgets.dart';
import '../theme/app_theme.dart';
import '../providers/app_settings_provider.dart';
import '../services/video_background_service.dart';
import '../widgets/main_navigation.dart';
import '../utils/page_transitions.dart';
import '../services/audio_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _currentVideoController; // Only one video at a time
  bool _videoInitialized = false;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Find Your Peace',
      subtitle: 'Escape Mental Noise',
      description: 'Transform overwhelming thoughts into harmonious tranquility with scientifically-designed soundscapes.',
      features: [
        'Instant mental relief',
        'Calming soundscapes'
      ],
      icon: Icons.spa,
      videoAsset: 'assets/animated_backgrounds/Animated1.mp4',
    ),
    OnboardingPage(
      title: 'Mix Like a Pro',
      subtitle: 'Layer Perfect Sounds',
      description: 'Create complex audio environments with intuitive controls and real-time mixing.',
      features: [
        'Multi-track mixing',
        'Save & share creations'
      ],
      icon: Icons.tune,
      videoAsset: 'assets/animated_backgrounds/Animated2.mp4',
    ),
    OnboardingPage(
      title: 'Smart Timers',
      subtitle: 'Effortless Transitions',
      description: 'Gentle fade-outs for peaceful sleep and focused productivity sessions.',
      features: [
        'Sleep timers',
        'Focus tracking'
      ],
      icon: Icons.bedtime,
      videoAsset: 'assets/animated_backgrounds/Animated3.mp4',
    ),
    OnboardingPage(
      title: 'Beautiful Design',
      subtitle: 'Premium Experience',
      description: 'Award-winning glassmorphism interface with smooth animations and customizable themes.',
      features: [
        'Glassmorphism UI',
        'Custom themes'
      ],
      icon: Icons.palette,
      videoAsset: 'assets/animated_backgrounds/animated4.mp4',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeCurrentVideo();
  }

  void _initializeCurrentVideo() async {
    await _disposeCurrentVideo();
    
    final currentPage = _pages[_currentPage];
    try {
      _currentVideoController = VideoPlayerController.asset(currentPage.videoAsset);
      await _currentVideoController!.initialize();
      await _currentVideoController!.setLooping(true);
      await _currentVideoController!.setVolume(0.0);
      await _currentVideoController!.play();
      
      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _videoInitialized = false;
        });
      }
    }
  }

  Future<void> _disposeCurrentVideo() async {
    if (_currentVideoController != null) {
      try {
        await _currentVideoController!.pause();
        _currentVideoController!.dispose();
      } catch (e) {
        debugPrint('Error disposing video controller: $e');
      }
      _currentVideoController = null;
    }
    _videoInitialized = false;
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _disposeCurrentVideo();
    super.dispose();
  }
  
  void _switchVideoBackground(int index) {
    setState(() {
      _currentPage = index;
    });
    _initializeCurrentVideo();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _completeOnboarding() async {
    final settingsProvider = context.read<AppSettingsProvider>();
    final videoService = context.read<VideoBackgroundService>();
    
    // Ensure video service is initialized before transition
    if (!videoService.isInitialized && !videoService.isInitializing) {
      await videoService.initialize();
    }
    
    await settingsProvider.completeOnboarding();

    if (!mounted) return;

    // Save references before async operations to prevent accessing deactivated widget
    final audioService = context.read<AudioPlayerService>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await _requestPermissions(audioService, scaffoldMessenger);

    if (!mounted) return;

    navigator.pushReplacement(
      PageTransitions.fadeTransition(
        page: const MainNavigation(),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _requestPermissions(AudioPlayerService audioService, ScaffoldMessengerState scaffoldMessenger) async {
    final snackBarDuration = const Duration(seconds: 4);

    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              duration: snackBarDuration,
              content: const Text('Notifications are needed for background playback controls.'),
            ),
          );
        }
      }

      try {
        // Optional: Request exact alarm permission for sleep timer feature
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (_) {
        // Ignore if the permission isn't supported on this device.
      }
      
      // Battery optimization: NOT requesting ignoreBatteryOptimizations
      // so the app properly exits when removed from recent apps
    }

    await audioService.enableBackgroundPlayback();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<AppSettingsProvider>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Video background - full screen
          Positioned.fill(
            child: _buildVideoBackground(),
          ),
          
          // Grain overlay for texture - full screen
          if (settingsProvider.settings.enableGrainOverlay)
            Positioned.fill(
              child: _buildGrainOverlay(settingsProvider.settings.grainIntensity),
            ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with logo and skip button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60),
                      Text(
                        'Arcadia',
                        style: GoogleFonts.modernAntiqua(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.modernAntiqua(
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Spacer to push content to bottom
                Expanded(child: Container()),
                
                // Main content container - full width
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Page view content
                            SizedBox(
                              height: 185,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                  _switchVideoBackground(index);
                                },
                                itemCount: _pages.length,
                                itemBuilder: (context, index) {
                                  return AnimationLimiter(
                                    child: _buildOnboardingContent(_pages[index], theme),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Page indicators with enhanced design
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _pages.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: _currentPage == index ? 32 : 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: _currentPage == index
                                        ? LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    color: _currentPage == index
                                        ? null
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _currentPage == index
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: _currentPage == index
                                      ? Center(
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Navigation buttons
                            Row(
                              children: [
                                // Previous button
                                if (_currentPage > 0)
                                  Expanded(
                                    child: GlassButton(
                                      onPressed: _previousPage,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_ios,
                                            size: 16,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Previous',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                
                                if (_currentPage > 0) const SizedBox(width: 16),
                                
                                // Next/Get Started button
                                Expanded(
                                  flex: _currentPage == 0 ? 1 : 1,
                                  child: GlassButton(
                                    onPressed: _nextPage,
                                    isSelected: true,
                                    accentColor: AppTheme.primaryLight,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentPage == _pages.length - 1
                                              ? 'Get Started'
                                              : 'Next',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _currentPage == _pages.length - 1
                                              ? Icons.check
                                              : Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVideoBackground() {
    if (!_videoInitialized || _currentVideoController == null) {
      // Show simple black background while video is loading
      return Container(
        color: Colors.black,
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _currentVideoController!.value.size.width,
          height: _currentVideoController!.value.size.height,
          child: VideoPlayer(_currentVideoController!),
        ),
      ),
    );
  }
  
  Widget _buildGrainOverlay(double intensity) {
    return Opacity(
      opacity: intensity * 0.3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.02),
              Colors.transparent,
              Colors.white.withOpacity(0.01),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOnboardingContent(OnboardingPage page, ThemeData theme) {
    return AnimationConfiguration.staggeredList(
      position: _currentPage,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              // Title with enhanced prominence
              Text(
                page.title,
                style: GoogleFonts.modernAntiqua(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontSize: 32,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle with refined styling
              Text(
                page.subtitle,
                style: GoogleFonts.modernAntiqua(
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.3,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Description text for more context
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  page.description,
                  style: GoogleFonts.modernAntiqua(
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.2,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final IconData icon;
  final String videoAsset;
  
  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.icon,
    required this.videoAsset,
  });
}