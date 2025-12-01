import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../widgets/glassmorphism_widgets.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/video_background_service.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../models/app_settings.dart';
import '../providers/app_settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  // Removed continuous background animation for performance
  
  @override
  void initState() {
    super.initState();
    
    // Ensure video service is playing when settings screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoService = context.read<VideoBackgroundService>();
      if (videoService.isInitialized) {
        videoService.play();
      }
    });
  }
  
  @override
  void dispose() {
    // No animation controller to dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Performance: Use Selector to only rebuild when settings change
    // Include masterVolume so the slider updates when changed
    return Selector<AppSettingsProvider, ({String accentColor, bool isDarkMode, double masterVolume})>(
      selector: (_, provider) => (
        accentColor: provider.settings.accentColor,
        isDarkMode: provider.settings.isDarkMode,
        masterVolume: provider.settings.masterVolume,
      ),
      builder: (context, settings, _) {
        final settingsProvider = context.read<AppSettingsProvider>();
        final accentColor = AppTheme.getAccentColor(settings.accentColor);
        final audioService = context.read<AudioPlayerService>();
        return _buildSettingsContent(context, theme, settingsProvider, accentColor, audioService);
      },
    );
  }
  
  Widget _buildSettingsContent(
    BuildContext context,
    ThemeData theme,
    AppSettingsProvider settingsProvider,
    Color accentColor,
    AudioPlayerService audioService,
  ) {
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.all(20),
            // Optimize scrolling performance
            cacheExtent: 1000,
            physics: const ClampingScrollPhysics(),
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 250),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 20.0,
                child: FadeInAnimation(
                  duration: const Duration(milliseconds: 200),
                  child: RepaintBoundary(child: widget),
                ),
              ),
              children: [
                const SizedBox(height: 20),
                
                // Appearance section
                _buildAppearanceSection(settingsProvider, theme, accentColor),
                
                const SizedBox(height: 24),
                
                // Audio section
                _buildAudioSection(settingsProvider, theme, accentColor, audioService),
                
                const SizedBox(height: 24),
                
                // Timer section
                _buildTimerSection(settingsProvider, theme, accentColor, audioService),
                
                const SizedBox(height: 24),
                
                // Data section
                _buildDataSection(theme, accentColor),
                
                const SizedBox(height: 24),
                
                // About section
                _buildAboutSection(theme, accentColor),
                
                const SizedBox(height: 24),
                
                // Settings Banner Ad
                const _SettingsBannerAdSlot(),
                
                const SizedBox(height: 120), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSection(
    AppSettingsProvider settingsProvider,
    ThemeData theme,
    Color accentColor,
  ) {
    return GlassMixPanel(
      title: 'Appearance',
      child: _buildAccentColorSection(settingsProvider, theme, accentColor),
    );
  }
  
  Widget _buildAudioSection(
    AppSettingsProvider settingsProvider,
    ThemeData theme,
    Color accentColor,
    AudioPlayerService audioService,
  ) {
    return GlassMixPanel(
      title: 'Audio',
      child: Column(
        children: [
          // Master volume
          GlassSlider(
            label: 'Master Volume',
            value: settingsProvider.settings.masterVolume,
            onChanged: (value) {
              settingsProvider.setMasterVolume(value);
              unawaited(audioService.setMasterVolume(value));
            },
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          // Background play toggle
          _buildSettingRow(
            icon: Icons.play_circle_outline,
            title: 'Background Playback',
            subtitle: 'Continue playing when app is minimized',
            trailing: Semantics(
              label: 'Background playback toggle',
              hint: settingsProvider.settings.enableBackgroundPlay 
                  ? 'Currently enabled, tap to disable background playback'
                  : 'Currently disabled, tap to enable background playback',
              child: Switch(
                value: settingsProvider.settings.enableBackgroundPlay,
                onChanged: (_) {
                  final newValue = !settingsProvider.settings.enableBackgroundPlay;
                  settingsProvider.toggleBackgroundPlay();
                  unawaited(audioService.setBackgroundPlaybackEnabled(newValue));
                },
                activeColor: accentColor,
              ),
            ),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          // Fade in/out toggle
          _buildSettingRow(
            icon: Icons.volume_up,
            title: 'Fade In/Out',
            subtitle: 'Smooth volume transitions',
            trailing: Semantics(
              label: 'Fade in and out toggle',
              hint: settingsProvider.settings.enableFadeInOut 
                  ? 'Currently enabled, tap to disable smooth volume transitions'
                  : 'Currently disabled, tap to enable smooth volume transitions',
              child: Switch(
                value: settingsProvider.settings.enableFadeInOut,
                onChanged: (_) {
                  final newValue = !settingsProvider.settings.enableFadeInOut;
                  settingsProvider.toggleFadeInOut();
                  audioService.setFadeConfig(enabled: newValue);
                },
                activeColor: accentColor,
              ),
            ),
            theme: theme,
            accentColor: accentColor,
          ),
          
          // Fade duration settings
          if (settingsProvider.settings.enableFadeInOut) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fade In: ${settingsProvider.settings.fadeInDuration}s',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Slider(
                        value: settingsProvider.settings.fadeInDuration.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) {
                          final fadeIn = value.round();
                          settingsProvider.setFadeDurations(
                            fadeIn,
                            settingsProvider.settings.fadeOutDuration,
                          );
                          audioService.setFadeConfig(fadeInSeconds: fadeIn);
                        },
                        activeColor: accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fade Out: ${settingsProvider.settings.fadeOutDuration}s',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Slider(
                        value: settingsProvider.settings.fadeOutDuration.toDouble(),
                        min: 1,
                        max: 15,
                        divisions: 14,
                        onChanged: (value) {
                          final fadeOut = value.round();
                          settingsProvider.setFadeDurations(
                            settingsProvider.settings.fadeInDuration,
                            fadeOut,
                          );
                          audioService.setFadeConfig(fadeOutSeconds: fadeOut);
                        },
                        activeColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTimerSection(
    AppSettingsProvider settingsProvider,
    ThemeData theme,
    Color accentColor,
    AudioPlayerService audioService,
  ) {
    return GlassMixPanel(
      title: 'Sleep Timer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default Timer Duration',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [15, 30, 45, 60, 90].map((minutes) {
              final isSelected = settingsProvider.settings.defaultSleepTimer == minutes;
              return GlassButton(
                onPressed: () {
                  settingsProvider.setSleepTimer(minutes);
                  audioService.setSleepTimer(minutes);
                },
                isSelected: isSelected,
                accentColor: accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${minutes}m',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? accentColor : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataSection(ThemeData theme, Color accentColor) {
    return GlassMixPanel(
      title: 'Data',
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Export your mixes and settings',
            onTap: () => _showComingSoonDialog('Export Data'),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.upload,
            title: 'Import Data',
            subtitle: 'Import mixes and settings',
            onTap: () => _showComingSoonDialog('Import Data'),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Reset app to default state',
            onTap: () => _showClearDataDialog(),
            theme: theme,
            accentColor: Colors.red,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection(ThemeData theme, Color accentColor) {
    return GlassMixPanel(
      title: 'About',
      child: Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData 
                  ? snapshot.data!.version 
                  : '0.0.1';
              final buildNumber = snapshot.hasData 
                  ? snapshot.data!.buildNumber 
                  : '1';
              return _buildInfoRow(
                icon: Icons.info,
                title: 'Version',
                value: '$version+$buildNumber',
                theme: theme,
                accentColor: accentColor,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.code,
            title: 'Credits',
            subtitle: 'Developed by Luziv',
            onTap: () => _openGitHub(),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => _showComingSoonDialog('Privacy Policy'),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'App usage terms and conditions',
            onTap: () => _showComingSoonDialog('Terms of Service'),
            theme: theme,
            accentColor: accentColor,
          ),
          
          const SizedBox(height: 16),
          
          _buildActionRow(
            icon: Icons.favorite,
            title: 'Rate Arcadia',
            subtitle: 'Help us improve with your feedback',
            onTap: () => _showComingSoonDialog('Rate App'),
            theme: theme,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccentColorSection(
    AppSettingsProvider settingsProvider,
    ThemeData theme,
    Color currentAccentColor,
  ) {
    final colors = {
      'Lime': AppTheme.accentLime,
      'Purple': AppTheme.accentPurple,
      'Magenta': AppTheme.accentMagenta,
      'Orange': AppTheme.accentOrange,
      'Yellow': AppTheme.accentYellow,
      'Coral': AppTheme.accentCoral,
      'Mint': AppTheme.accentMint,
      'Peach': AppTheme.accentPeach,
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: colors.entries.map((entry) {
            final colorName = entry.key;
            final color = entry.value;
            final isSelected = settingsProvider.settings.accentColor.toLowerCase() == colorName.toLowerCase();
            
            return Semantics(
              button: true,
              enabled: true,
              label: '$colorName accent color',
              hint: isSelected 
                  ? 'Currently selected accent color'
                  : 'Double tap to select $colorName as accent color',
              selected: isSelected,
              child: GestureDetector(
                onTap: () => settingsProvider.setAccentColor(colorName.toLowerCase()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required ThemeData theme,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: accentColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
  
  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    required Color accentColor,
    bool isDestructive = false,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      label: title,
      hint: 'Double tap to $subtitle',
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : accentColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: accentColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Future<void> _openGitHub() async {
    final url = Uri.parse('https://github.com/DiaeEddineJamal');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open GitHub page')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening GitHub: $e')),
        );
      }
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$feature will be available in a future update.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Clear All Data',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete all your custom mixes and reset settings to default. This action cannot be undone.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      onPressed: () async {
                        try {
                          await StorageService.clearAllData();
                          
                          // Reset settings provider
                          final settingsProvider = context.read<AppSettingsProvider>();
                          await settingsProvider.updateSettings(const AppSettings());
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data cleared successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error clearing data: $e'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsBannerAdSlot extends StatelessWidget {
  const _SettingsBannerAdSlot();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdService>(
      builder: (_, adService, __) {
        final banner = adService.settingsBannerAd;
        if (banner == null) {
          return const SizedBox.shrink();
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        );
      },
    );
  }
}