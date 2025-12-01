import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../models/sound.dart';
import '../utils/performance_monitor.dart';
import 'glassmorphism_widgets.dart';

/// Spotify-style expandable player bar with mini-mixer
class PlayerBar extends StatefulWidget {
  const PlayerBar({Key? key}) : super(key: key);

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Optimized for 120Hz
    );
    // Use easeOutCubic for smoother, more natural feeling animation (like Spotify/Apple Music)
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Align with EnhancedFloatingBottomNav sizing
    const navHeight = 70.0;
    final navBottomMargin = bottomPadding > 0 ? 20.0 : 30.0;

    final allSounds = StorageService.getAllSounds();
    
    return Selector<AudioPlayerService, ({List<String> activeIds, Map<String, bool> playingStates, bool isMasterPlaying})>(
      selector: (_, service) => (
        activeIds: service.activeSoundIds,
        playingStates: service.playingStates,
        isMasterPlaying: service.isMasterPlaying,
      ),
      builder: (context, audioData, child) {
        final audioService = context.read<AudioPlayerService>();
        final activeSounds = allSounds.where((s) => audioData.activeIds.contains(s.id)).toList();
        final playingCount = audioData.playingStates.values.where((e) => e == true).length;

        // Collapsed height sits above the bottom nav (which is ~70px)
        // Increase to avoid 11px overflow from icon button min constraints
        const collapsedHeight = 80.0;
        const mixerPaddingTop = 12.0;
        const soundRowHeight = 110.0; // Estimated row height with metadata + slider
        const mixerFooterHeight = 72.0; // SizedBox + add sound button spacing

        final estimatedMixerHeight = (activeSounds.length * soundRowHeight) + mixerFooterHeight;
        final rawExpandedHeight = collapsedHeight + mixerPaddingTop + estimatedMixerHeight;
        final screenSize = MediaQuery.of(context).size;
        final maxExpandedHeight = screenSize.height * 0.55;
        final targetExpandedHeight = math.min(maxExpandedHeight, rawExpandedHeight);
        final availableMixerHeight = math.max(0.0, targetExpandedHeight - collapsedHeight);
        final enableScrolling = rawExpandedHeight > maxExpandedHeight;

        // Performance optimization: Pre-compute decoration outside animation builder
        final isDarkTheme = theme.brightness == Brightness.dark;
        final cachedDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDarkTheme ? 0.25 : 0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: -5,
            ),
          ],
        );
        
        final bar = RepaintBoundary(
          child: Semantics(
            label: 'Player controls bar',
            child: AnimatedBuilder(
              animation: _expandAnim,
              builder: (context, child) {
                // Performance optimization: Cache height calculation
                final h = collapsedHeight + (_expandAnim.value * (targetExpandedHeight - collapsedHeight));
                
                return RepaintBoundary(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, navHeight + navBottomMargin + 8),
                    height: h,
                    decoration: cachedDecoration,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Builder(
                        builder: (context) {
                          final monitor = PerformanceMonitor();
                          final shouldDisableBackdrop = monitor.shouldDisableBackdropFilter;
                          final adaptiveBlur = 20 * monitor.adaptiveBlurQuality;
                          
                          final glassContent = GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Column(
                              children: [
                                _buildCollapsedRow(context, audioService, accent, activeSounds.length, playingCount, audioData.isMasterPlaying),
                                Flexible(
                                  child: SizeTransition(
                                    sizeFactor: _expandAnim,
                                    axisAlignment: -1.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _buildMiniMixer(
                                        context,
                                        audioService,
                                        allSounds,
                                        activeSounds,
                                        enableScrolling,
                                        availableMixerHeight,
                                        accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldDisableBackdrop) {
                            return glassContent;
                          }
                          
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: adaptiveBlur, sigmaY: adaptiveBlur),
                            child: glassContent,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        final collapsedTotalHeight = collapsedHeight + navHeight + navBottomMargin + 8;
        final containerHeight = _expanded ? screenSize.height : collapsedTotalHeight;

        return SizedBox(
          height: containerHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_expanded)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleExpanded,
                    child: const SizedBox.expand(),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: bar,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollapsedRow(
    BuildContext context,
    AudioPlayerService audioService,
    Color accent,
    int activeCount,
    int playingCount,
    bool isMasterPlaying,
  ) {
    final theme = Theme.of(context);
    final subtitle = _buildQueueSubtitle(activeCount, playingCount);
    return Row(
      children: [
        // Master play/pause
        IconButton(
          tooltip: isMasterPlaying ? 'Pause all' : 'Play all',
          icon: Icon(
            isMasterPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 28,
            color: accent,
          ),
          onPressed: () async {
            if (isMasterPlaying) {
              await audioService.pauseAll();
            } else {
              await audioService.resumeAll();
            }
          },
        ),
        const SizedBox(width: 12),
        // Title + active count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Queue',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Expand/collapse chevron
        IconButton(
          tooltip: _expanded ? 'Collapse mini-mixer' : 'Expand mini-mixer',
          icon: Icon(_expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: theme.iconTheme.color),
          onPressed: _toggleExpanded,
        ),
      ],
    );
  }

  String _buildQueueSubtitle(int queuedCount, int playingCount) {
    if (queuedCount == 0) return 'No sounds in queue';
    final queueLabel = '$queuedCount sound${queuedCount == 1 ? '' : 's'} queued';
    if (playingCount == 0) {
      return queueLabel;
    }
    final playingLabel = '$playingCount playing';
    return '$playingLabel · $queueLabel';
  }

  Widget _buildMiniMixer(
    BuildContext context,
    AudioPlayerService audioService,
    List<Sound> allSounds,
    List<Sound> activeSounds,
    bool enableScrolling,
    double maxHeight,
    Color accent,
  ) {
    final theme = Theme.of(context);

    // Performance optimization: Pre-compute theme values to avoid repeated lookups
    final isDark = theme.brightness == Brightness.dark;
    final circleBackgroundOpacity = isDark ? 0.24 : 0.18;
    
    final mixerChildren = [
      ...activeSounds.map((sound) {
        final isPlaying = audioService.playingStates[sound.id] == true;
        final volume = audioService.volumes[sound.id] ?? sound.defaultVolume;
        final baseIconColor = accent;
        final circleBackground = accent.withOpacity(circleBackgroundOpacity);
        return RepaintBoundary(
          key: ValueKey(sound.id), // Use stable keys for better widget recycling
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleBackground,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.music_note,
                        size: 20,
                        color: baseIconColor,
                        // Performance: Cache icon to reduce rebuilds
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sound.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            sound.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent.withOpacity(0.85),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: baseIconColor,
                        size: 26,
                      ),
                      tooltip: isPlaying ? 'Pause ${sound.name}' : 'Play ${sound.name}',
                      onPressed: () async {
                        await audioService.toggleSound(sound.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconTheme.color?.withOpacity(0.7)),
                      tooltip: 'Remove ${sound.name}',
                      onPressed: () async {
                        await audioService.removeSound(sound.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 52, right: 8),
                  child: _ThrottledVolumeSlider(
                    value: volume,
                    soundId: sound.id,
                    audioService: audioService,
                    sliderTheme: theme.sliderTheme.copyWith(
                      trackHeight: 3,
                      activeTrackColor: baseIconColor,
                      inactiveTrackColor: baseIconColor.withOpacity(0.2),
                      thumbColor: baseIconColor,
                      overlayColor: baseIconColor.withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _showAddSheet(context, audioService, allSounds),
          style: TextButton.styleFrom(foregroundColor: accent),
          icon: const Icon(Icons.add),
          label: Text(
            'Add sound',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ];

    Widget content;
    if (enableScrolling && maxHeight > 0) {
      content = SizedBox(
        height: maxHeight,
        child: ListView(
          padding: EdgeInsets.zero,
          // Use ClampingScrollPhysics for smoother, less bouncy scrolling (like professional apps)
          physics: const ClampingScrollPhysics(),
          // Increase cache extent for better pre-rendering during fast scrolling
          cacheExtent: 1000,
          // Disable automatic keep-alives for better performance
          addAutomaticKeepAlives: false,
          // Disable repaint boundaries for smoother scrolling (we already have RepaintBoundary around content)
          addRepaintBoundaries: false,
          children: mixerChildren,
        ),
      );
    } else if (maxHeight > 0) {
      // When not explicitly scrolling but height is constrained, use constrained scroll view
      content = SizedBox(
        height: maxHeight,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: mixerChildren,
          ),
        ),
      );
    } else {
      // Fallback: use constrained column to prevent overflow
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight > 0 ? maxHeight : double.infinity,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: mixerChildren,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: content,
    );
  }

  void _showAddSheet(BuildContext context, AudioPlayerService audioService, List<Sound> allSounds) {
    final theme = Theme.of(context);
    // Use Material modal with optimized settings for smooth animations
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true, // Smooth drag-to-dismiss
      useRootNavigator: false, // Better performance
      barrierColor: Colors.black.withOpacity(0.5), // Optimized backdrop
      builder: (ctx) => _buildModalContent(ctx, theme, audioService, allSounds),
    );
  }

  Widget _buildModalContent(BuildContext ctx, ThemeData theme, AudioPlayerService audioService, List<Sound> allSounds) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a sound', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Expanded(
                  child: RepaintBoundary(
                    child: ListView.builder(
                      itemCount: allSounds.length,
                      // Professional apps use higher cache extent for smoother scrolling
                      cacheExtent: 1000,
                      // Disable keep-alives for better performance
                      addAutomaticKeepAlives: false,
                      // Disable repaint boundaries (we wrap each item instead)
                      addRepaintBoundaries: false,
                      // Use ClampingScrollPhysics for smoother scrolling
                      physics: const ClampingScrollPhysics(),
                      // Performance: Use itemExtent for better scrolling performance
                      itemExtent: 72.0, // Fixed height for ListTile improves performance
                      itemBuilder: (context, index) {
                        final s = allSounds[index];
                        // Cache volume percentage computation
                        final volumePercent = (s.defaultVolume * 100).round();
                        // Use const where possible to reduce rebuilds
                        return RepaintBoundary(
                          key: ValueKey('sound_${s.id}'), // Stable keys
                          child: ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(s.name),
                            subtitle: Text(s.category),
                            trailing: Text('$volumePercent%'),
                            onTap: () {
                              // Optimize: Non-blocking sound initialization for smooth modal dismiss
                              // Dismiss modal immediately for instant feedback
                              if (Navigator.of(ctx).canPop()) {
                                Navigator.of(ctx).pop();
                              }
                              // Initialize and play sound asynchronously without blocking UI
                              audioService.initializeSound(s).then((_) {
                                audioService.setSoundVolume(s.id, s.defaultVolume);
                                audioService.playSound(s.id);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Throttled volume slider that prevents excessive rebuilds during dragging
/// Updates the visual slider immediately but throttles actual volume updates
class _ThrottledVolumeSlider extends StatefulWidget {
  final double value;
  final String soundId;
  final AudioPlayerService audioService;
  final SliderThemeData sliderTheme;

  const _ThrottledVolumeSlider({
    required this.value,
    required this.soundId,
    required this.audioService,
    required this.sliderTheme,
  });

  @override
  State<_ThrottledVolumeSlider> createState() => _ThrottledVolumeSliderState();
}

/// Throttled master volume slider for the now playing section
class ThrottledMasterVolumeSlider extends StatefulWidget {
  final double value;
  final AudioPlayerService audioService;
  final SliderThemeData sliderTheme;
  final Color activeColor;
  final Color inactiveColor;

  const ThrottledMasterVolumeSlider({
    Key? key,
    required this.value,
    required this.audioService,
    required this.sliderTheme,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  State<ThrottledMasterVolumeSlider> createState() => _ThrottledMasterVolumeSliderState();
}

class _ThrottledVolumeSliderState extends State<_ThrottledVolumeSlider> {
  late ValueNotifier<double> _localValue;
  Timer? _throttleTimer;
  double? _pendingValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _localValue = ValueNotifier<double>(widget.value);
  }

  @override
  void didUpdateWidget(_ThrottledVolumeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local value if it's different and we're not dragging
    // This prevents jumping when the actual volume updates from elsewhere
    if (!_isDragging && widget.value != _localValue.value) {
      _localValue.value = widget.value;
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _localValue.dispose();
    super.dispose();
  }

  void _onChanged(double newValue) {
    // Update local value immediately for smooth visual feedback
    _localValue.value = newValue;
    _isDragging = true;
    _pendingValue = newValue;

    // Cancel previous timer
    _throttleTimer?.cancel();

    // Throttle actual volume updates to every 50ms
    _throttleTimer = Timer(const Duration(milliseconds: 50), () {
      _commitVolume();
    });
  }

  void _onChangeEnd(double newValue) {
    _isDragging = false;
    _throttleTimer?.cancel();
    _pendingValue = newValue;
    // Always commit final value immediately when drag ends and trigger notification
    if (_pendingValue != null) {
      final valueToCommit = _pendingValue!;
      _pendingValue = null;
      // Final commit - trigger notification for UI sync
      widget.audioService.setSoundVolume(widget.soundId, valueToCommit, skipNotification: false);
    }
  }

  void _commitVolume() {
    if (_pendingValue != null) {
      final valueToCommit = _pendingValue!;
      _pendingValue = null;
      // Update volume with skipNotification=true during drag, only notify on final commit
      widget.audioService.setSoundVolume(widget.soundId, valueToCommit, skipNotification: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _localValue,
      builder: (context, localValue, child) {
        return SliderTheme(
          data: widget.sliderTheme,
          child: Slider(
            value: localValue,
            min: 0.0,
            max: 1.0,
            onChanged: _onChanged,
            onChangeEnd: _onChangeEnd,
          ),
        );
      },
    );
  }
}

class _ThrottledMasterVolumeSliderState extends State<ThrottledMasterVolumeSlider> {
  late ValueNotifier<double> _localValue;
  Timer? _throttleTimer;
  double? _pendingValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _localValue = ValueNotifier<double>(widget.value);
  }

  @override
  void didUpdateWidget(ThrottledMasterVolumeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local value if it's different and we're not dragging
    if (!_isDragging && widget.value != _localValue.value) {
      _localValue.value = widget.value;
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _localValue.dispose();
    super.dispose();
  }

  void _onChanged(double newValue) {
    // Update local value immediately for smooth visual feedback
    _localValue.value = newValue;
    _isDragging = true;
    _pendingValue = newValue;

    // Cancel previous timer
    _throttleTimer?.cancel();

    // Throttle actual volume updates to every 50ms
    _throttleTimer = Timer(const Duration(milliseconds: 50), () {
      _commitVolume();
    });
  }

  void _onChangeEnd(double newValue) {
    _isDragging = false;
    _throttleTimer?.cancel();
    _pendingValue = newValue;
    // Always commit final value immediately when drag ends and trigger notification
    if (_pendingValue != null) {
      final valueToCommit = _pendingValue!;
      _pendingValue = null;
      // Final commit - trigger notification for UI sync
      widget.audioService.setMasterVolume(valueToCommit);
    }
  }

  void _commitVolume() {
    if (_pendingValue != null) {
      final valueToCommit = _pendingValue!;
      _pendingValue = null;
      // Update master volume with skipNotification=true during drag
      widget.audioService.setMasterVolume(valueToCommit, skipNotification: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _localValue,
      builder: (context, localValue, child) {
        return SliderTheme(
          data: widget.sliderTheme,
          child: Slider(
            value: localValue,
            min: 0.0,
            max: 1.0,
            onChanged: _onChanged,
            onChangeEnd: _onChangeEnd,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
          ),
        );
      },
    );
  }
}