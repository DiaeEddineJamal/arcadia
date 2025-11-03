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

  bool _isMonitoring = false;
  double _adaptiveBlurQuality = 1.0; // 1.0 = full quality, 0.5 = reduced quality
  void Function(List<FrameTiming>)? _frameTimingsCallback;

  /// Get current adaptive blur quality (reduced during performance issues)
  double get adaptiveBlurQuality => _adaptiveBlurQuality;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateFPS();
      _updateAdaptiveQuality();
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
    _frameCount += timings.length;
    _lastFrameTime = DateTime.now();
  }

  void _updateFPS() {
    if (_lastFrameTime == null) {
      _currentFPS = 0.0;
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastFrameTime!);
    
    if (elapsed.inSeconds > 0) {
      _currentFPS = _frameCount / elapsed.inSeconds;
      _frameCount = 0;
      _lastFrameTime = now;

      // Keep history for analysis
      _fpsHistory.add(_currentFPS);
      if (_fpsHistory.length > maxHistorySize) {
        _fpsHistory.removeAt(0);
      }
    }
  }

  void _updateAdaptiveQuality() {
    if (_fpsHistory.isEmpty) return;

    // Calculate average FPS over last 5 seconds
    final recentFPS = _fpsHistory.length >= 5
        ? _fpsHistory.sublist(_fpsHistory.length - 5).reduce((a, b) => a + b) / 5
        : _currentFPS;

    // Adjust blur quality based on FPS
    // Below 30 FPS: reduce quality significantly
    // Below 50 FPS: reduce quality moderately
    // Above 55 FPS: full quality
    if (recentFPS < 30) {
      _adaptiveBlurQuality = 0.4; // Heavy reduction for poor performance
    } else if (recentFPS < 45) {
      _adaptiveBlurQuality = 0.6; // Moderate reduction
    } else if (recentFPS < 55) {
      _adaptiveBlurQuality = 0.8; // Light reduction
    } else {
      _adaptiveBlurQuality = 1.0; // Full quality
    }

    if (kDebugMode && _fpsHistory.length % 10 == 0) {
      print('PerformanceMonitor: FPS=$recentFPS, Quality=${(_adaptiveBlurQuality * 100).toStringAsFixed(0)}%');
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
  }
}

