import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_background_service.dart';

/// A reusable video background widget that provides consistent styling
/// across different screens with video background only
class SharedVideoBackground extends StatefulWidget {
  final bool isDark;
  final Color accentColor;
  final bool enableGrainOverlay;
  final double grainIntensity;

  const SharedVideoBackground({
    Key? key,
    required this.isDark,
    required this.accentColor,
    this.enableGrainOverlay = true,
    this.grainIntensity = 0.3,
  }) : super(key: key);

  @override
  State<SharedVideoBackground> createState() => _SharedVideoBackgroundState();
}

class _SharedVideoBackgroundState extends State<SharedVideoBackground>
    with TickerProviderStateMixin {
  AnimationController? _grainController;
  VideoBackgroundService? _videoService; // Cache service reference

  @override
  void initState() {
    super.initState();
    // Performance optimized: Initialize video asynchronously after first frame
    // Cache service reference to avoid context reads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _videoService ??= context.read<VideoBackgroundService>();
      if (!_videoService!.isInitialized && !_videoService!.isInitializing) {
        _videoService!.initialize();
      }
    });
    _configureGrainController();
  }

  void _configureGrainController() {
    if (widget.enableGrainOverlay) {
      _grainController ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      )..repeat();
    } else {
      _grainController?.stop();
      _grainController?.dispose();
      _grainController = null;
    }
  }

  @override
  void didUpdateWidget(covariant SharedVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableGrainOverlay != widget.enableGrainOverlay) {
      _configureGrainController();
    }
  }

  @override
  void dispose() {
    _grainController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Maximum frame rate optimization: Use Selector to rebuild only when video state changes
    // This prevents unnecessary rebuilds that could cause frame drops
    // Cached service reference prevents repeated context reads
    return Selector<VideoBackgroundService, bool>(
      selector: (_, service) => service.isInitialized,
      builder: (context, isInitialized, child) {
        // Use cached service or read once if not available
        _videoService ??= context.read<VideoBackgroundService>();
        final videoService = _videoService!;
        
        // Stack widget optimized for maximum frame rate
        // All layers use RepaintBoundary to prevent cross-layer repaints
        // Static widget tree - no dynamic rebuilds during video playback
        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Black background while video loads (prevents flashing)
              // Static - no repaints needed, completely stable
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              
              // Maximum performance: Video background with hardware acceleration
              // Video widget is already optimized with RepaintBoundary and GlobalKey
              // This ensures video rendering is completely isolated from UI rebuilds
              // Video renders directly to GPU surface - zero interference with Flutter frames
              // Single static widget instance prevents any buffer recreation
              if (isInitialized)
                Positioned.fill(
                  child: videoService.getVideoWidget(),
                ),
              
              // Color overlay - isolated in RepaintBoundary to prevent affecting video
              // Uses const where possible to prevent rebuilds
              Positioned.fill(
                child: RepaintBoundary(
                  child: _buildColorOverlay(),
                ),
              ),

              // Grain overlay - separate layer for independent rendering
              // Only rebuilds when animation changes, doesn't affect video
              if (widget.enableGrainOverlay && _grainController != null)
                Positioned.fill(
                  child: GrainOverlay(
                    intensity: widget.grainIntensity,
                    controller: _grainController!,
                  ),
                ),
              
              // Error retry button (only shown if video fails to load)
              // Static widget - only appears when needed
              if (videoService.hasError)
                _buildErrorRetryButton(videoService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOverlay() {
    // Pre-compute colors to avoid recalculation on every build
    final overlayColor = widget.isDark ? Colors.black : Colors.white;
    
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            overlayColor.withOpacity(0.1),
            Colors.transparent,
            widget.accentColor.withOpacity(0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRetryButton(VideoBackgroundService videoService) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: () => videoService.retry(),
          icon: Icon(
            Icons.refresh,
            color: widget.accentColor,
          ),
          tooltip: 'Retry video loading',
        ),
      ),
    );
  }
}

/// Grain overlay widget for visual texture
class GrainOverlay extends StatelessWidget {
  final double intensity;
  final AnimationController controller;

  const GrainOverlay({
    Key? key,
    required this.intensity,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                (controller.value - 0.5) * 2,
                (controller.value - 0.5) * 2,
              ),
              radius: 1.5,
              colors: [
                Colors.white.withOpacity(intensity * 0.02),
                Colors.transparent,
                Colors.black.withOpacity(intensity * 0.01),
              ],
            ),
          ),
        );
      },
    );
  }
}