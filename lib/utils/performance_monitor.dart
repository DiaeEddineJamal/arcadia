import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitor for tracking frame rates, memory, and operation times
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _currentFPS = 0.0;
  Timer? _fpsTimer;
  final List<double> _fpsHistory = [];
  static const int maxHistorySize = 60; // Keep last 60 seconds of FPS data
  bool _hasLoggedWaiting = false; // Track if we've logged the waiting message

  bool _isMonitoring = false;
  double _adaptiveBlurQuality = 1.0; // 1.0 = full quality, 0.5 = reduced quality
  void Function(List<FrameTiming>)? _frameTimingsCallback;
  bool _isLowEndDevice = false;
  bool _shouldDisableBackdropFilter = false;
  bool _shouldDisableVideo = false;
  bool _isHighRefreshRateDevice = false; // Track if device supports 120Hz+

  /// Get current adaptive blur quality (reduced during performance issues)
  double get adaptiveBlurQuality => _adaptiveBlurQuality;
  
  /// Check if device is low-end and should use reduced effects
  bool get isLowEndDevice => _isLowEndDevice;
  
  /// Check if BackdropFilter should be disabled for performance
  bool get shouldDisableBackdropFilter => _shouldDisableBackdropFilter;
  
  /// Check if video background should be disabled for performance
  bool get shouldDisableVideo => _shouldDisableVideo;
  
  /// Check if device supports high refresh rate (120Hz+)
  bool get isHighRefreshRateDevice => _isHighRefreshRateDevice;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    if (kDebugMode) {
      print('PerformanceMonitor: Starting performance monitoring...');
    }
    
    // Detect low-end device on startup
    _detectDeviceCapability();

    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateFPS();
      _updateAdaptiveQuality();
      _updateDeviceCapability();
    });

    // Monitor frame performance
    // Note: addTimingsCallback doesn't have a remove method in Flutter, 
    // so we use a flag to control processing
    _frameTimingsCallback = (List<FrameTiming> timings) {
      if (_isMonitoring) {
        _onFrameTimings(timings);
      }
    };
    SchedulerBinding.instance.addTimingsCallback(_frameTimingsCallback!);
  }

  /// Stop monitoring performance
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _fpsTimer?.cancel();
    _fpsTimer = null;
    // Note: Flutter doesn't provide removeTimingsCallback, but we use a flag
    // to prevent processing when not monitoring
    _frameTimingsCallback = null;
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    _frameCount += timings.length;
    
    // Initialize _lastFrameTime on first frame
    if (_lastFrameTime == null) {
      _lastFrameTime = DateTime.now();
      if (kDebugMode) {
        print('PerformanceMonitor: First frame received');
      }
    }
  }

  void _updateFPS() {
    // Initialize _lastFrameTime if we haven't received any frames yet
    if (_lastFrameTime == null) {
      _currentFPS = 0.0;
      // Only log once when waiting for first frame
      if (kDebugMode && !_hasLoggedWaiting) {
        print('PerformanceMonitor: Waiting for first frame...');
        _hasLoggedWaiting = true;
      }
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastFrameTime!);
    
    // Update FPS every second (1000ms)
    if (elapsed.inMilliseconds >= 1000) {
      if (_frameCount > 0) {
        _currentFPS = _frameCount / (elapsed.inMilliseconds / 1000.0);
      } else {
        // No frames in this period
        _currentFPS = 0.0;
      }
      
      // Keep history for analysis (only if we got valid FPS)
      if (_currentFPS > 0) {
        _fpsHistory.add(_currentFPS);
        if (_fpsHistory.length > maxHistorySize) {
          _fpsHistory.removeAt(0);
        }
        
        // Log first few FPS readings to verify it's working
        if (kDebugMode && _fpsHistory.length <= 3) {
          print('PerformanceMonitor: FPS reading #${_fpsHistory.length}: ${_currentFPS.toStringAsFixed(1)} FPS');
        }
      }
      
      // Reset for next period
      _frameCount = 0;
      _lastFrameTime = now;
    }
  }

  void _detectDeviceCapability() {
    // Start with optimizations enabled for better initial performance
    // Will adjust based on actual FPS measurements
    _isLowEndDevice = false;
    // BackdropFilter is always enabled (user preference)
    _shouldDisableBackdropFilter = false;
    _shouldDisableVideo = false;
    // Start with optimized blur quality for 120Hz targeting
    _adaptiveBlurQuality = 0.6;
    
    if (kDebugMode) {
      print('PerformanceMonitor: Initialized - BlurQuality=${(_adaptiveBlurQuality * 100).toStringAsFixed(0)}%');
    }
  }
  
  void _updateDeviceCapability() {
    if (_fpsHistory.isEmpty) {
      // Keep initial settings until we have data
      // Don't spam logs - only log once
      return;
    }
    
    final recentFPS = _fpsHistory.length >= 5
        ? _fpsHistory.sublist(_fpsHistory.length - 5).reduce((a, b) => a + b) / 5
        : _currentFPS;
    
    // Optimized thresholds for 120Hz targeting
    // Mark as low-end if consistently below 60 FPS (was 50)
    _isLowEndDevice = recentFPS < 60;
    
    // Detect high refresh rate device (120Hz+) if FPS can reach 90+
    // This helps optimize specifically for flagship devices
    _isHighRefreshRateDevice = recentFPS >= 90 || _isHighRefreshRateDevice;
    
    // BackdropFilter is always enabled (user preference)
    // We only adjust blur quality, not disable the effect
    _shouldDisableBackdropFilter = false;
    
    // For 120Hz devices: Pause video if FPS drops below 100 to maintain 120Hz
    // For 60Hz devices: Pause video if FPS drops below 50
    // This allows video to pause earlier to maintain higher FPS on high-end devices
    if (_isHighRefreshRateDevice) {
      _shouldDisableVideo = recentFPS < 100; // More aggressive for 120Hz devices
    } else {
      _shouldDisableVideo = recentFPS < 50; // Standard threshold for 60Hz devices
    }
    
    // Log performance metrics every 3 seconds (more frequent for debugging)
    if (kDebugMode && _fpsHistory.length % 3 == 0) {
      print('PerformanceMonitor: FPS=${recentFPS.toStringAsFixed(1)}, LowEnd=$_isLowEndDevice, HighRefreshRate=$_isHighRefreshRateDevice, NoBackdrop=$_shouldDisableBackdropFilter, NoVideo=$_shouldDisableVideo, BlurQuality=${(_adaptiveBlurQuality * 100).toStringAsFixed(0)}%');
    }
  }

  void _updateAdaptiveQuality() {
    if (_fpsHistory.isEmpty) {
      // Start with reduced quality until we have performance data
      _adaptiveBlurQuality = 0.7;
      return;
    }

    // Calculate average FPS over last 5 seconds
    final recentFPS = _fpsHistory.length >= 5
        ? _fpsHistory.sublist(_fpsHistory.length - 5).reduce((a, b) => a + b) / 5
        : _currentFPS;

    // Optimized for 120Hz: More aggressive blur reduction to achieve 120 FPS
    // Target 120 FPS on high-end devices, maintain 60 FPS on mid-range
    if (recentFPS < 30) {
      _adaptiveBlurQuality = 0.15; // Heavy reduction for poor performance
    } else if (recentFPS < 45) {
      _adaptiveBlurQuality = 0.25; // Moderate reduction
    } else if (recentFPS < 60) {
      _adaptiveBlurQuality = 0.4; // Light reduction to reach 60 FPS
    } else if (recentFPS < 90) {
      _adaptiveBlurQuality = 0.5; // Medium reduction to reach 90 FPS
    } else if (recentFPS < 110) {
      _adaptiveBlurQuality = 0.6; // Light reduction to reach 110 FPS
    } else {
      // At 110+ FPS, still reduce blur by 40% to maintain 120 FPS consistently
      _adaptiveBlurQuality = 0.6; // Optimized for 120Hz devices
    }
  }

  /// Get current FPS
  double get currentFPS => _currentFPS;

  /// Get average FPS over specified duration
  double getAverageFPS({int seconds = 5}) {
    if (_fpsHistory.isEmpty) return 0.0;
    
    final count = seconds.clamp(1, _fpsHistory.length);
    final recent = _fpsHistory.sublist(_fpsHistory.length - count);
    return recent.reduce((a, b) => a + b) / recent.length;
  }

  /// Measure execution time of an async operation
  static Future<T> measureTime<T>(
    Future<T> Function() operation, {
    String? label,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      if (kDebugMode && label != null) {
        print('$label took ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode && label != null) {
        print('$label failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Measure execution time of a sync operation
  static T measureSyncTime<T>(
    T Function() operation, {
    String? label,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      if (kDebugMode && label != null) {
        print('$label took ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode && label != null) {
        print('$label failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Check if performance is currently degraded
  bool get isPerformanceDegraded {
    if (_fpsHistory.isEmpty) return false;
    return getAverageFPS() < 45;
  }

  /// Reset monitoring data
  void reset() {
    _frameCount = 0;
    _lastFrameTime = null;
    _currentFPS = 0.0;
    _fpsHistory.clear();
    _adaptiveBlurQuality = 1.0;
    _isLowEndDevice = false;
    _shouldDisableBackdropFilter = false;
    _shouldDisableVideo = false;
  }
}

