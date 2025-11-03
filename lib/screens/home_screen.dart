import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_widgets.dart';
import '../widgets/floating_bottom_nav.dart';
import '../widgets/sound_visualizer.dart';
import '../widgets/main_navigation.dart';
import '../widgets/player_bar.dart';
import 'sound_library_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({
    super.key,
    this.showBottomNav = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // Sample sound categories with icons
  final List<Map<String, dynamic>> _soundCategories = [
    {
      'name': 'Rain',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'sounds': 12,
    },
    {
      'name': 'Nature',
      'icon': Icons.nature,
      'color': Colors.green,
      'sounds': 18,
    },
    {
      'name': 'Wind',
      'icon': Icons.air,
      'color': Colors.cyan,
      'sounds': 8,
    },
    {
      'name': 'Fire',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'sounds': 6,
    },
    {
      'name': 'Ocean',
      'icon': Icons.waves,
      'color': Colors.lightBlue,
      'sounds': 10,
    },
    {
      'name': 'Fantasy',
      'icon': Icons.auto_awesome,
      'color': Colors.deepPurpleAccent,
      'sounds': 4,
    },
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<AppSettingsProvider>();
    final audioService = context.watch<AudioPlayerService>();
    final accentColor = AppTheme.getAccentColor(settingsProvider.settings.accentColor);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Arcadia',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        actions: [
          // Sleep timer indicator
          if (audioService.sleepTimerMinutes > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: GestureDetector(
                  onTap: () => _showTimerDialog(context, accentColor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${audioService.sleepTimerMinutes}m',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            // Professional apps use higher cache extent for smoother scrolling
            cacheExtent: 1000,
            // Use ClampingScrollPhysics for smoother, less bouncy scrolling
            physics: const ClampingScrollPhysics(),
            // Optimize for performance
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 250),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 20.0,
                child: FadeInAnimation(
                  duration: const Duration(milliseconds: 200),
                  child: RepaintBoundary(child: widget),
                ),
              ),
              children: [
                // Greeting section
                _buildGreetingSection(theme, accentColor, isDark),
                
                const SizedBox(height: 24),
                
                // Now Playing / Quick Controls
                _buildNowPlayingSection(audioService, theme, accentColor, isDark),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActions(audioService, theme, accentColor, isDark),
                
                const SizedBox(height: 32),
                
                // Sound Categories
                _buildSectionHeader('Sound Categories', theme, accentColor),
                const SizedBox(height: 16),
                _buildSoundCategories(theme, accentColor, isDark),
                
                const SizedBox(height: 32),
                
                // Featured Sounds
                _buildSectionHeader('Featured Sounds', theme, accentColor),
                const SizedBox(height: 16),
                _buildFeaturedSounds(theme, accentColor, isDark),
                
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? FloatingBottomNav(
        currentIndex: _currentNavIndex,
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
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune,
            label: 'Mix',
          ),
          FloatingNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ) : null,
    );
  }

  Widget _buildGreetingSection(ThemeData theme, Color accentColor, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              greetingIcon,
              color: accentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to relax?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingSection(
    AudioPlayerService audioService,
    ThemeData theme,
    Color accentColor,
    bool isDark,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Now Playing',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Subtle visualizer pulse when playing
          SoundVisualizer(
            isPlaying: audioService.isMasterPlaying,
            color: accentColor,
            height: 24,
          ),
          
          const SizedBox(height: 12),
          
          // Master Volume
          Row(
            children: [
              Icon(
                audioService.masterVolume > 0.5
                    ? Icons.volume_up
                    : Icons.volume_down,
                size: 20,
                color: theme.iconTheme.color?.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ThrottledMasterVolumeSlider(
                  value: audioService.masterVolume,
                  audioService: audioService,
                  sliderTheme: theme.sliderTheme.copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  activeColor: accentColor,
                  inactiveColor: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
              ),
              Text(
                '${(audioService.masterVolume * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.play_arrow,
                label: 'Play',
                onTap: () {
                  if (!audioService.isMasterPlaying) {
                    audioService.resumeAll();
                  }
                },
                accentColor: accentColor,
                theme: theme,
              ),
              _buildControlButton(
                icon: Icons.pause,
                label: 'Pause',
                onTap: () => audioService.pauseAll(),
                accentColor: Colors.red,
                theme: theme,
              ),
              _buildControlButton(
                icon: Icons.timer,
                label: 'Timer',
                onTap: () => _showTimerDialog(context, accentColor),
                accentColor: Colors.blue,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: accentColor.withOpacity(0.3),
        highlightColor: accentColor.withOpacity(0.15),
        child: GlassCard(
          onTap: null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    AudioPlayerService audioService,
    ThemeData theme,
    Color accentColor,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => _showTimerDialog(context, accentColor),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timer,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Timer',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        audioService.sleepTimerMinutes > 0
                            ? '${audioService.sleepTimerMinutes}m active'
                            : 'Not set',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: audioService.sleepTimerMinutes > 0
                              ? Colors.blue
                              : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSoundCategories(ThemeData theme, Color accentColor, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.75,
      ),
      itemCount: _soundCategories.length,
      itemBuilder: (context, index) {
        final category = _soundCategories[index];
        final dynamicCount = StorageService.getSoundsByCategory(category['name']).length;
        return RepaintBoundary(
          child: GlassCard(
          onTap: () {
            final categoryName = category['name'] as String;
            final handled = MainNavigation.openLibraryCategory(context, categoryName);
            if (!handled) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SoundLibraryScreen(initialCategory: categoryName),
                ),
              );
            }
          },
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                category['name'],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                '$dynamicCount sounds',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontSize: 9.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildFeaturedSounds(ThemeData theme, Color accentColor, bool isDark) {
    final featuredSounds = [
      {
        'name': 'Light Rain',
        'category': 'Rain',
        'duration': '∞',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'name': 'Ocean Waves',
        'category': 'Ocean',
        'duration': '∞',
        'icon': Icons.waves,
        'color': Colors.lightBlue,
      },
      {
        'name': 'Forest',
        'category': 'Nature',
        'duration': '∞',
        'icon': Icons.nature,
        'color': Colors.green,
      },
    ];

    return Column(
      children: featuredSounds.map((sound) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RepaintBoundary(
            child: GlassCard(
            onTap: () {
              final name = sound['name'] as String;
              final audioService = context.read<AudioPlayerService>();
              try {
                final found = StorageService.getAllSounds().firstWhere(
                  (s) => s.name == name,
                );
                audioService.initializeSound(found).then((_) async {
                  await audioService.setSoundVolume(found.id, found.defaultVolume);
                  await audioService.playSound(found.id);
                });
              } catch (_) {
                // If not found, do nothing
              }
            },
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (sound['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sound['icon'] as IconData,
                    color: sound['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound['name'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sound['category']} • ${sound['duration']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      }).toList(),
    );
  }

  void _showTimerDialog(BuildContext context, Color accentColor) {
    print('🔧 DEBUG: _showTimerDialog called');
    print('🔧 DEBUG: Context type: ${context.runtimeType}');
    print('🔧 DEBUG: Context mounted: ${context.mounted}');
    
    try {
      final audioService = context.read<AudioPlayerService>();
      print('🔧 DEBUG: AudioService obtained successfully');
      _showSleepTimerDialog(context, audioService, accentColor);
    } catch (e, stackTrace) {
      print('🔧 DEBUG ERROR in _showTimerDialog: $e');
      print('🔧 DEBUG STACK: $stackTrace');
    }
  }

  void _showSleepTimerDialog(
    BuildContext context,
    AudioPlayerService audioService,
    Color accentColor,
  ) {
    print('🔧 DEBUG: _showSleepTimerDialog called');
    print('🔧 DEBUG: Context type: ${context.runtimeType}');
    print('🔧 DEBUG: Context mounted: ${context.mounted}');
    print('🔧 DEBUG: AudioService sleepTimerMinutes: ${audioService.sleepTimerMinutes}');
    
    try {
      // Convert current timer minutes to hours and minutes
      int totalMinutes = audioService.sleepTimerMinutes > 0 
          ? audioService.sleepTimerMinutes 
          : 30;
      int selectedHours = totalMinutes ~/ 60;
      int selectedMinutes = totalMinutes % 60;
      
      print('🔧 DEBUG: Timer values - Hours: $selectedHours, Minutes: $selectedMinutes');
      
      // Guard to prevent double dismissal causing route pop
      bool isDialogClosing = false;

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (BuildContext dialogContext) {
          print('🔧 DEBUG: Dialog builder called');
          print('🔧 DEBUG: DialogContext type: ${dialogContext.runtimeType}');
          print('🔧 DEBUG: DialogContext mounted: ${dialogContext.mounted}');
          
          try {
            return Material(
              type: MaterialType.transparency,
              child: WillPopScope(
                onWillPop: () async {
                  print('🔧 DEBUG: WillPopScope onWillPop called');
                  return true;
                },
                child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  content: StatefulBuilder(
                  builder: (BuildContext builderContext, StateSetter setState) {
                    print('🔧 DEBUG: StatefulBuilder called');
                    print('🔧 DEBUG: BuilderContext type: ${builderContext.runtimeType}');
                    print('🔧 DEBUG: BuilderContext mounted: ${builderContext.mounted}');
                    
                    try {
                      final dialogWidth = MediaQuery.of(dialogContext).size.width * 0.85 > 350 
                          ? 350.0 
                          : MediaQuery.of(dialogContext).size.width * 0.85;
                      
                      print('🔧 DEBUG: Dialog width calculated: $dialogWidth');
                      print('🔧 DEBUG: About to return dialog content widget');
                      
                      return SingleChildScrollView(
                child: SizedBox(
                  width: dialogWidth,
                  child: GlassContainer(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Sleep Timer',
                          style: Theme.of(dialogContext).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set a timer to automatically stop all sounds',
                          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // Dual Wheel Picker (Hours and Minutes)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(dialogContext).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            children: [
                              // Hours picker (0-23)
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: selectedHours,
                                  ),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (int index) {
                                    print('🔧 DEBUG: Hours picker changed to: $index');
                                    setState(() {
                                      selectedHours = index;
                                    });
                                  },
                                  children: List.generate(24, (index) {
                                    return Center(
                                      child: Text(
                                        '$index',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(dialogContext).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              
                              // "h" label
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'h',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              
                              // Minutes picker (0-59)
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: selectedMinutes,
                                  ),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (int index) {
                                    print('🔧 DEBUG: Minutes picker changed to: $index');
                                    setState(() {
                                      selectedMinutes = index;
                                    });
                                  },
                                  children: List.generate(60, (index) {
                                    return Center(
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(dialogContext).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              
                              // "min" label
                              Padding(
                                padding: const EdgeInsets.only(left: 8, right: 12),
                                child: Text(
                                  'min',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Set Timer Button
                        SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: GlassButton(
                            onPressed: () {
                              if (isDialogClosing) {
                                print('🔧 DEBUG: Set Timer ignored, dialog already closing');
                                return;
                              }
                              print('🔧 DEBUG: Set Timer button pressed');
                              try {
                                final totalMins = (selectedHours * 60) + selectedMinutes;
                                print('🔧 DEBUG: Total minutes calculated: $totalMins');
                                
                                if (totalMins > 0) {
                                  print('🔧 DEBUG: Getting navigator and scaffold messenger');
                                  final nav = Navigator.of(dialogContext);
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  
                                  String timeText = '';
                                  if (selectedHours > 0 && selectedMinutes > 0) {
                                    timeText = '$selectedHours h $selectedMinutes min';
                                  } else if (selectedHours > 0) {
                                    timeText = '$selectedHours h';
                                  } else {
                                    timeText = '$selectedMinutes min';
                                  }
                                  
                                  print('🔧 DEBUG: Setting sleep timer');
                                  audioService.setSleepTimer(totalMins);
                                  
                                  isDialogClosing = true;
                                  print('🔧 DEBUG: Popping dialog');
                                  nav.pop();
                                  
                                  print('🔧 DEBUG: Showing snackbar');
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Sleep timer set for $timeText'),
                                      backgroundColor: accentColor.withValues(alpha: 0.8),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  print('🔧 DEBUG: Set Timer button completed successfully');
                                }
                              } catch (e, stackTrace) {
                                print('🔧 DEBUG ERROR in Set Timer button: $e');
                                print('🔧 DEBUG STACK: $stackTrace');
                              }
                            },
                            accentColor: accentColor,
                            child: Center(
                              child: Text(
                                'Set Timer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(dialogContext).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Stop Timer button (if active)
                        if (audioService.sleepTimerMinutes > 0)
                          SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: GlassButton(
                              onPressed: () {
                                if (isDialogClosing) {
                                  print('🔧 DEBUG: Stop Timer ignored, dialog already closing');
                                  return;
                                }
                                print('🔧 DEBUG: Stop Timer button pressed');
                                try {
                                  final nav = Navigator.of(dialogContext);
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  
                                  print('🔧 DEBUG: Stopping sleep timer');
                                  audioService.setSleepTimer(0);
                                  
                                  isDialogClosing = true;
                                  print('🔧 DEBUG: Popping dialog');
                                  nav.pop();
                                  
                                  print('🔧 DEBUG: Showing stop timer snackbar');
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Sleep timer stopped'),
                                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  print('🔧 DEBUG: Stop Timer button completed successfully');
                                } catch (e, stackTrace) {
                                  print('🔧 DEBUG ERROR in Stop Timer button: $e');
                                  print('🔧 DEBUG STACK: $stackTrace');
                                }
                              },
                              accentColor: Colors.red,
                              child: Center(
                                child: Text(
                                  'Stop Timer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(dialogContext).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        if (audioService.sleepTimerMinutes > 0)
                          const SizedBox(height: 10),
                        
                        // Cancel button
                        SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: GlassButton(
                            onPressed: () {
                              if (isDialogClosing) {
                                print('🔧 DEBUG: Cancel ignored, dialog already closing');
                                return;
                              }
                              print('🔧 DEBUG: Cancel button pressed');
                              try {
                                print('🔧 DEBUG: Getting navigator from dialogContext');
                                isDialogClosing = true;
                                Navigator.of(dialogContext).pop();
                                print('🔧 DEBUG: Cancel button completed successfully');
                              } catch (e, stackTrace) {
                                print('🔧 DEBUG ERROR in Cancel button: $e');
                                print('🔧 DEBUG STACK: $stackTrace');
                              }
                            },
                            child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(dialogContext).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  );
                    } catch (e, stackTrace) {
                      print('🔧 DEBUG ERROR in StatefulBuilder: $e');
                      print('🔧 DEBUG STACK: $stackTrace');
                      return Container(
                        width: 300,
                        height: 200,
                        color: Colors.red,
                        child: Center(
                          child: Text(
                            'Error in StatefulBuilder: $e',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                },
              ),
            ),
          ),
        );
           } catch (e, stackTrace) {
             print('🔧 DEBUG ERROR in Dialog builder: $e');
             print('🔧 DEBUG STACK: $stackTrace');
             return Container(
               width: 300,
               height: 200,
               color: Colors.blue,
               child: Center(
                 child: Text(
                   'Error in Dialog builder: $e',
                   style: TextStyle(color: Colors.white),
                 ),
               ),
             );
           }
        },
      );
    } catch (e, stackTrace) {
      print('🔧 DEBUG ERROR in _showSleepTimerDialog: $e');
      print('🔧 DEBUG STACK: $stackTrace');
    }
  }
}
