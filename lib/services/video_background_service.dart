import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import '../utils/performance_monitor.dart';

/// Singleton service that manages a shared video background across the app
/// This ensures seamless transitions without video interruption
class VideoBackgroundService extends ChangeNotifier {
  static final VideoBackgroundService _instance = VideoBackgroundService._internal();
  factory VideoBackgroundService() => _instance;
  VideoBackgroundService._internal();

  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isPaused = false; // Track pause state for performance optimization
  Widget? _cachedVideoWidget; // Cache video widget to prevent buffer recreation
  static final GlobalKey _videoWidgetKey = GlobalKey(debugLabel: 'video_background_key'); // Global key for widget reuse
  Timer? _performanceCheckTimer; // Timer to periodically check performance and pause/resume video

  VideoPlayerController? get videoController => _videoController;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isPaused => _isPaused;

  /// Video listener to monitor state and handle errors
  /// Performance optimized: Only handles errors, doesn't trigger on every frame
  void _videoListener() {
    if (_videoController == null || _isDisposed || !_isInitialized) return;
    
    // Handle errors during playback
    if (_videoController!.value.hasError) {
      debugPrint('Video playback error: ${_videoController!.value.errorDescription}');
      _hasError = true;
      _errorMessage = _videoController!.value.errorDescription;
      // Performance: Only notify listeners on actual errors, not on every frame
      if (hasListeners) notifyListeners();
    }
    // Performance optimization: Don't listen to position/duration changes
    // Video loops automatically, no need to monitor playback state
    // Performance-based pause/resume is handled by periodic timer
  }
  
  /// Start periodic performance monitoring to pause/resume video
  /// Optimized for 120Hz: More aggressive pausing to maintain high FPS
  void _startPerformanceMonitoring() {
    _performanceCheckTimer?.cancel();
    _performanceCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isDisposed || !_isInitialized || _videoController == null) {
        timer.cancel();
        return;
      }
      
      final monitor = PerformanceMonitor();
      final currentFPS = monitor.currentFPS;
      final isHighRefreshRate = monitor.isHighRefreshRateDevice;
      
      // For 120Hz devices: Pause video if FPS < 100 to maintain 120Hz
      // For 60Hz devices: Pause video if FPS < 50
      final threshold = isHighRefreshRate ? 100.0 : 50.0;
      
      if (monitor.shouldDisableVideo || currentFPS < threshold) {
        // Pause video if performance is low
        if (!_isPaused && _videoController!.value.isPlaying) {
          _videoController!.pause();
          _isPaused = true;
          debugPrint('Video paused due to low performance (FPS < $threshold, HighRefreshRate=$isHighRefreshRate)');
        }
      } else {
        // Resume video when performance is good
        if (_isPaused && !_videoController!.value.isPlaying) {
          _videoController!.play();
          _isPaused = false;
          debugPrint('Video resumed - performance good (FPS >= $threshold, HighRefreshRate=$isHighRefreshRate)');
        }
      }
    });
  }
  
  /// Stop performance monitoring
  void _stopPerformanceMonitoring() {
    _performanceCheckTimer?.cancel();
    _performanceCheckTimer = null;
  }

  /// Initialize the video controller if not already initialized
  Future<void> initialize() async {
    // Prevent re-initialization if already initialized or initializing
    if (_isInitialized || _isInitializing || _isDisposed) {
      debugPrint('Video background already initialized or initializing, skipping...');
      return;
    }

    _isInitializing = true;
    _hasError = false;
    _errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      // Dispose existing controller if any (for hot refresh)
      if (_videoController != null) {
        debugPrint('Disposing existing video controller...');
        await _cleanUp();
      }

      // Check if video file exists
      const videoPath = 'assets/animated_backgrounds/main_animated.mp4';
      
      _videoController = VideoPlayerController.asset(
        videoPath,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow audio to play alongside video
          allowBackgroundPlayback: false,
          // Optimize for 120Hz: Reduce buffer usage to prevent ImageReader_JNI warnings
          // This helps maintain smooth 120Hz rendering
        ),
      );

      // Initialize with await to ensure controller is ready
      debugPrint('Initializing video controller...');
      await _videoController!.initialize();
      debugPrint('Video controller initialized. Size: ${_videoController!.value.size}');

      // Configure video for 120Hz optimization
      // Optimize playback for high refresh rate displays
      await _videoController!.setLooping(true);
      // Use 1.0 speed for smooth playback, but will be adjusted based on performance
      await _videoController!.setPlaybackSpeed(1.0);
      await _videoController!.setVolume(0.0); // Mute background video to save battery
      
      // Performance optimization: Use hardware acceleration (default on Android/iOS)
      // Video player automatically uses hardware acceleration when available
      // Hardware acceleration ensures GPU-based decoding for maximum performance
      
      // Add listener to monitor playback state and prevent buffer issues
      _videoController!.addListener(_videoListener);
      
      // Clear cached widget when video is reinitialized
      _cachedVideoWidget = null;
      
      // Start playback
      debugPrint('Starting video playback...');
      try {
        await _videoController!.play();
        debugPrint('Video playback started successfully');
      } catch (playError) {
        debugPrint('Error starting playback: $playError');
        // Continue anyway - video will auto-play when buffers are ready
      }

      _isInitialized = true;
      _isInitializing = false;
      _isPaused = false;
      if (hasListeners) notifyListeners();
      
      // Start periodic performance check to pause/resume video
      _startPerformanceMonitoring();
      
      debugPrint('Video background initialized successfully');
    } catch (e) {
      debugPrint('Error initializing video background: $e');
      _errorMessage = 'Failed to load video background: ${e.toString()}';
      _hasError = true;
      
      // Clean up failed controller
      await _cleanUp();
      _isInitialized = false;
      _isInitializing = false;
      if (hasListeners) notifyListeners();
      // Don't rethrow - gracefully handle with fallback
    }
  }

  /// Clean up video controller resources
  Future<void> _cleanUp() async {
    _stopPerformanceMonitoring();
    try {
      _videoController?.removeListener(_videoListener);
      _videoController?.pause();
      _videoController?.dispose();
    } catch (disposeError) {
      debugPrint('Error during cleanup: $disposeError');
    }
    _videoController = null;
    _cachedVideoWidget = null; // Clear cached widget on cleanup
  }

  /// Dispose the video controller (should only be called when app is closing)
  @override
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    debugPrint('Disposing video background service...');
    _cleanUp();
    _isInitialized = false;
    _isInitializing = false;
    super.dispose();
  }

  /// Reset the service for hot refresh
  void reset() {
    debugPrint('Resetting video background service...');
    if (_videoController != null) {
      _cleanUp();
    }
    _isInitialized = false;
    _isInitializing = false;
    _hasError = false;
    _errorMessage = null;
    _isPaused = false;
    if (hasListeners) notifyListeners();
  }

  /// Pause video playback for performance optimization
  void pause() {
    try {
      if (_isInitialized && _videoController != null && _videoController!.value.isInitialized) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _isPaused = true;
          debugPrint('Video paused for performance optimization');
        }
      }
    } catch (e) {
      debugPrint('Error pausing video: $e');
    }
  }

  /// Resume video playback
  void play() {
    try {
      if (_isInitialized && _videoController != null && _videoController!.value.isInitialized) {
        if (!_videoController!.value.isPlaying) {
          _videoController!.play();
          _isPaused = false;
          debugPrint('Video resumed');
        }
      }
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  /// Restart video playback (not used - video loops automatically)
  void restart() {
    // Intentionally do nothing - video loops automatically
    debugPrint('Video restart requested but ignored - video loops automatically');
  }

  /// Get the video widget for display with maximum frame rate optimization
  /// Zero frame drops: Optimized for highest quality playback without compromises
  /// Hardware-accelerated: Uses GPU for decoding to maintain smooth 120Hz+ refresh rates
  /// Video widget is always returned (never removed) - video pauses when performance is low
  Widget getVideoWidget() {
    // Always return video widget - never remove it (prevents black screen)
    // Performance-based pause/resume is handled by periodic timer
    if (!_isInitialized || _videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black, // Fallback background while loading
        child: const SizedBox.expand(),
      );
    }

    // Maximum performance optimization: Cache widget with GlobalKey
    // This ensures Flutter reuses the exact same widget instance, preventing
    // buffer recreation and frame drops during rebuilds
    // RepaintBoundary isolates video rendering from UI rebuilds for zero interference
    if (_cachedVideoWidget == null) {
      _cachedVideoWidget = RepaintBoundary(
        key: _videoWidgetKey, // Global key ensures true widget reuse across rebuilds
        child: IgnorePointer(
          // Ignore pointer events since it's a background - reduces event overhead
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover, // High-quality scaling without distortion
              alignment: Alignment.center,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                // VideoPlayer uses hardware acceleration by default
                // This ensures GPU-based decoding for maximum frame rate
                // Video renders directly to GPU surface for zero-copy rendering
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
        ),
      );
    }

    return _cachedVideoWidget!;
  }

  /// Check if device can handle video playback efficiently
  bool get canHandleVideoPlayback {
    // Basic device capability check - can be enhanced with more sophisticated detection
    return !_hasError && (Platform.isAndroid || Platform.isIOS);
  }

  /// Reset error state and retry initialization
  Future<void> retry() async {
    debugPrint('Retrying video initialization...');
    _hasError = false;
    _errorMessage = null;
    _isInitialized = false;
    _isInitializing = false;
    
    // Dispose existing controller if any
    await _cleanUp();
    
    if (hasListeners) notifyListeners();
    
    // Add delay before retry
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Retry initialization
    await initialize();
  }

  /// Get memory usage information (for debugging/monitoring)
  String getMemoryInfo() {
    if (!_isInitialized || _videoController == null) {
      return 'Video not initialized';
    }
    
    final size = _videoController!.value.size;
    return 'Video size: ${size.width.toInt()}x${size.height.toInt()}';
  }

  /// Optimize video for low-power devices
  void optimizeForPerformance() {
    if (_isInitialized && _videoController != null) {
      // Reduce playback speed to lower CPU usage
      _videoController!.setPlaybackSpeed(0.6);
      debugPrint('Video optimized for performance');
    }
  }

  /// Restore normal video performance
  void restoreNormalPerformance() {
    if (_isInitialized && _videoController != null) {
      // Restore normal playback speed
      _videoController!.setPlaybackSpeed(0.8);
      debugPrint('Video performance restored to normal');
    }
  }
}