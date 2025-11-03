import 'dart:math';
import 'package:flutter/material.dart';

/// A subtle ambient visualizer that gently pulses when audio is playing.
/// Designed to be lightweight and performant.
class SoundVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double height;

  const SoundVisualizer({
    Key? key,
    required this.isPlaying,
    required this.color,
    this.barCount = 8, // Reduced from 12 for better performance
    this.height = 24,
  }) : super(key: key);

  @override
  State<SoundVisualizer> createState() => _SoundVisualizerState();
}

class _SoundVisualizerState extends State<SoundVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slower animation for less CPU usage
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _updatePlaybackState(initial: true);
  }

  @override
  void didUpdateWidget(covariant SoundVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      _updatePlaybackState();
    }
  }

  void _updatePlaybackState({bool initial = false}) {
    if (widget.isPlaying) {
      if (!initial) _controller.reset();
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color.withOpacity(isDark ? 0.6 : 0.5);
    final bgColor = widget.color.withOpacity(isDark ? 0.12 : 0.10);

    return SizedBox(
      height: widget.height,
      child: RepaintBoundary( // Add RepaintBoundary for better performance
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            // Simplified animation calculation
            return Row(
              mainAxisSize: MainAxisSize.max,
              children: List.generate(widget.barCount, (i) {
                final t = _pulse.value;
                final phase = (i / widget.barCount) * pi;
                final v = (sin(t * pi + phase) + 1) / 2.0; // 0..1
                final h = 6 + v * (widget.height - 12); // Reduced range for subtlety
                return Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container( // Changed from AnimatedContainer to reduce rebuilds
                      height: widget.isPlaying ? h : 6,
                      decoration: BoxDecoration(
                        color: widget.isPlaying ? baseColor : bgColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}