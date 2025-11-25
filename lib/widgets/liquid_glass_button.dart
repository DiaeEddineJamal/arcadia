import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// A liquid glass button with Apple-style design and smooth animations
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool isActive;
  final bool isPlaying;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;

  const LiquidGlassButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.width = 120,
    this.height = 120,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 24,
    this.isActive = false,
    this.isPlaying = false,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late AnimationController _playingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _playingAnimation;

  @override
  void initState() {
    super.initState();
    
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _playingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _playingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _playingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiquidGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _playingController.repeat(reverse: true);
      } else {
        _playingController.stop();
        _playingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    _playingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    _hoverController.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _handleTapDown : null,
        onTapUp: widget.onPressed != null ? _handleTapUp : null,
        onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _hoverAnimation,
            _playingAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: _buildShadows(isDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildGradient(isDark),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(
                          color: _buildBorderColor(isDark),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Shine effect
                          _buildShineEffect(isDark),
                          
                          // Playing indicator
                          if (widget.isPlaying) _buildPlayingIndicator(),
                          
                          // Content
                          Center(child: widget.child),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadows(bool isDark) {
    final hoverIntensity = _hoverAnimation.value;
    final playingIntensity = _playingAnimation.value;
    
    return [
      // Main shadow
      BoxShadow(
        color: (isDark ? Colors.black : Colors.grey.shade400)
            .withOpacity(0.3 + (hoverIntensity * 0.2)),
        blurRadius: 20 + (hoverIntensity * 10),
        offset: Offset(0, 8 + (hoverIntensity * 4)),
      ),
      
      // Inner glow for active state
      if (widget.isActive || widget.isPlaying)
        BoxShadow(
          color: (widget.backgroundColor ?? Colors.blue)
              .withOpacity(0.3 + (playingIntensity * 0.2)),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
    ];
  }

  LinearGradient _buildGradient(bool isDark) {
    final hoverIntensity = _hoverAnimation.value;
    final baseColor = widget.backgroundColor ?? 
        (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8));
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.8 + (hoverIntensity * 0.1)),
        baseColor.withOpacity(0.4 + (hoverIntensity * 0.2)),
        baseColor.withOpacity(0.2 + (hoverIntensity * 0.1)),
      ],
    );
  }

  Color _buildBorderColor(bool isDark) {
    final hoverIntensity = _hoverAnimation.value;
    final baseColor = widget.borderColor ?? 
        (isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.6));
    
    return Color.lerp(
      baseColor,
      (widget.backgroundColor ?? Colors.blue).withOpacity(0.5),
      hoverIntensity,
    )!;
  }

  Widget _buildShineEffect(bool isDark) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withOpacity(isDark ? 0.2 : 0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              (widget.backgroundColor ?? Colors.blue)
                  .withOpacity(0.1 + (_playingAnimation.value * 0.2)),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}