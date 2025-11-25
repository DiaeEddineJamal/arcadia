import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/sound_library_screen.dart';
// Removed MixBuilder screen; mixing is now integrated into Library and PlayerBar
import '../screens/settings_screen.dart';
import '../services/ad_service.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import 'enhanced_floating_bottom_nav.dart';
import 'shared_video_background.dart';
import 'player_bar.dart';

/// Main navigation wrapper that provides persistent bottom nav across all screens
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  final String? initialLibraryCategory;

  const MainNavigation({Key? key, this.initialIndex = 0, this.initialLibraryCategory}) : super(key: key);

  static bool openLibraryCategory(BuildContext context, String category) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    if (state == null) {
      return false;
    }
    state.navigateToLibrary(category);
    return true;
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late List<Widget> _screens;
  final GlobalKey<SoundLibraryScreenState> _libraryKey = GlobalKey<SoundLibraryScreenState>();

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    
    if (index == 1) {
      context.read<AdService>().maybeShowLibraryInterstitial();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void navigateToLibrary(String category) {
    setState(() {
      _currentIndex = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _libraryKey.currentState?.selectCategory(category);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const HomeScreenContent(),
      SoundLibraryScreen(
        key: _libraryKey,
        initialCategory: widget.initialLibraryCategory ?? 'All',
      ),
      const SettingsScreen(),
    ];

    if (widget.initialLibraryCategory != null && widget.initialLibraryCategory != 'All') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _libraryKey.currentState?.selectCategory(widget.initialLibraryCategory!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<AppSettingsProvider>();
    final accentColor = AppTheme.getAccentColor(settingsProvider.settings.accentColor);
    final isDark = settingsProvider.settings.isDarkMode;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          RepaintBoundary(
            child: SharedVideoBackground(
              isDark: isDark,
              accentColor: accentColor,
              enableGrainOverlay: settingsProvider.settings.enableGrainOverlay,
              grainIntensity: settingsProvider.settings.grainIntensity,
            ),
          ),
          // The actual screen content wrapped in RepaintBoundary
          RepaintBoundary(
            child: _screens[_currentIndex],
          ),
          // Fixed player bar overlay - hidden on Settings page with smooth animation
          if (_currentIndex != 2) // Hide on Settings page (index 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RepaintBoundary(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200), // Reduced from 300ms
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1), // Slide from bottom
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut, // Changed to easeOut
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: const PlayerBar(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: EnhancedFloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        selectedColor: accentColor,
        items: const [
          FloatingNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          FloatingNavItem(
            icon: Icons.library_music_outlined,
            activeIcon: Icons.library_music,
            label: 'Library',
          ),
          FloatingNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Wrapper for home screen content without its own scaffold
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the home screen content without the floating nav
    return const HomeScreen(showBottomNav: false);
  }
}

