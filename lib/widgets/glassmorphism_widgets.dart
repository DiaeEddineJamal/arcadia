import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/performance_monitor.dart';

/// A glassmorphism container with blur effect and subtle borders
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark 
        ? Color.fromRGBO(255, 255, 255, opacity)
        : Color.fromRGBO(0, 0, 0, opacity);

    // Performance optimization: Use adaptive blur quality based on performance metrics
    final monitor = PerformanceMonitor();
    final adaptiveBlur = blur * monitor.adaptiveBlurQuality;
    final shouldDisableBackdrop = monitor.shouldDisableBackdropFilter;

    // Build the glassmorphic effect using native Flutter widgets instead of the problematic package
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? defaultColor).withValues(alpha: 0.1),
            (color ?? defaultColor).withValues(alpha: 0.05),
          ],
        ),
        border: border ?? Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: shouldDisableBackdrop ? 5 : (10 * monitor.adaptiveBlurQuality),
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
              ],
            ),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
    
    // Only apply BackdropFilter if performance allows
    if (shouldDisableBackdrop) {
      return container;
    }
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: adaptiveBlur, sigmaY: adaptiveBlur),
        child: container,
      ),
    );
  }
}

/// A glassmorphism card with enhanced visual effects
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? accentColor;
  final String? semanticLabel;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.onTap,
    this.isSelected = false,
    this.accentColor,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin { // Changed from TickerProviderStateMixin
  late AnimationController _animationController; // Single controller for all animations
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Single animation controller for better performance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Optimized for smoothness
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Subtle scale effect
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
    // Disabled hover animation to prevent glow effect
    // _hoverController.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });
    // Disabled hover animation to prevent glow effect
    // _hoverController.reverse();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    // Disabled focus animation to prevent glow effect
    // if (hasFocus) {
    //   _hoverController.forward();
    // } else {
    //   _hoverController.reverse();
    // }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (widget.onTap != null && 
        (event.logicalKey == LogicalKeyboardKey.enter || 
         event.logicalKey == LogicalKeyboardKey.space)) {
      if (event is KeyDownEvent) {
        _animationController.forward();
      } else if (event is KeyUpEvent) {
        _animationController.reverse();
        widget.onTap!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor ?? theme.colorScheme.primary;

    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final hoverValue = 0.0; // Disabled hover glow effect
          
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Semantics(
                button: true,
                enabled: widget.onTap != null,
                label: widget.semanticLabel ?? 'Glass card',
                hint: widget.onTap != null ? 'Double tap to activate' : null,
                child: Focus(
                  focusNode: _focusNode,
                  onFocusChange: _handleFocusChange,
                  onKeyEvent: (node, event) {
                    _handleKeyEvent(event);
                    return KeyEventResult.handled;
                  },
                  child: MouseRegion(
                    onEnter: _handleHoverEnter,
                    onExit: _handleHoverExit,
                    child: GestureDetector(
                      onTapDown: widget.onTap != null ? _handleTapDown : null,
                      onTapUp: widget.onTap != null ? _handleTapUp : null,
                      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isSelected
                                ? [
                                    accent.withValues(alpha: 0.2 + (hoverValue * 0.1)),
                                    accent.withValues(alpha: 0.1 + (hoverValue * 0.05)),
                                  ]
                                : [
                                    isDark
                                        ? Color.fromRGBO(255, 255, 255, 0.1 + (hoverValue * 0.05))
                                        : Color.fromRGBO(0, 0, 0, 0.05 + (hoverValue * 0.03)),
                                    isDark
                                        ? Color.fromRGBO(255, 255, 255, 0.05 + (hoverValue * 0.03))
                                        : Color.fromRGBO(0, 0, 0, 0.02 + (hoverValue * 0.02)),
                                  ],
                          ),
                          border: Border.all(
                            color: widget.isSelected || _isFocused
                                ? accent.withValues(alpha: 0.3 + (hoverValue * 0.2))
                                : Color.fromRGBO(255, 255, 255, 0.2 + (hoverValue * 0.1)),
                            width: _isFocused ? 2.0 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1 + (hoverValue * 0.05)),
                              blurRadius: 10 + (hoverValue * 5),
                              offset: Offset(0, 4 + (hoverValue * 2)),
                            ),
                            if (widget.isSelected || _isHovered || _isFocused)
                              BoxShadow(
                                color: accent.withValues(alpha: 0.2 + (hoverValue * 0.1)),
                                blurRadius: 20 + (hoverValue * 10),
                                offset: Offset(0, 8 + (hoverValue * 4)),
                              ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          child: Builder(
                            builder: (context) {
                              final monitor = PerformanceMonitor();
                              final shouldDisableBackdrop = monitor.shouldDisableBackdropFilter;
                              final baseBlur = (10 + (hoverValue * 5)) * monitor.adaptiveBlurQuality;
                              
                              final content = Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(255, 255, 255, 0.1 + (hoverValue * 0.05)),
                                      Color.fromRGBO(255, 255, 255, 0.05 + (hoverValue * 0.03)),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: widget.padding ?? const EdgeInsets.all(16),
                                  child: widget.child,
                                ),
                              );
                              
                              if (shouldDisableBackdrop) {
                                return content;
                              }
                              
                              return BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: baseBlur,
                                  sigmaY: baseBlur,
                                ),
                                child: content,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
   
        },
      ),
    );
  }
}

/// A glassmorphism panel for mix controls
class GlassMixPanel extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const GlassMixPanel({
    Key? key,
    required this.child,
    required this.title,
    this.trailing,
    this.padding,
    this.margin,
    this.isExpanded = true,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Semantics(
              button: onToggle != null,
              enabled: onToggle != null,
              label: '$title section',
              hint: onToggle != null 
                  ? (isExpanded ? 'Double tap to collapse' : 'Double tap to expand')
                  : null,
              expanded: isExpanded,
              child: GestureDetector(
                onTap: onToggle,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                    if (onToggle != null)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glassmorphism slider with enhanced visuals
class GlassSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String? label;
  final Color? accentColor;
  final bool showValue;

  const GlassSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.accentColor,
    this.showValue = true,
  }) : super(key: key);

  @override
  State<GlassSlider> createState() => _GlassSliderState();
}

class _GlassSliderState extends State<GlassSlider> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      double step = (widget.max - widget.min) * 0.05; // 5% step
      double newValue = widget.value;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        newValue = (widget.value - step).clamp(widget.min, widget.max);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                 event.logicalKey == LogicalKeyboardKey.arrowUp) {
        newValue = (widget.value + step).clamp(widget.min, widget.max);
      } else if (event.logicalKey == LogicalKeyboardKey.home) {
        newValue = widget.min;
      } else if (event.logicalKey == LogicalKeyboardKey.end) {
        newValue = widget.max;
      }

      if (newValue != widget.value) {
        widget.onChanged(newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accentColor ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      slider: true,
      value: '${(widget.value * 100).round()}%',
      label: widget.label ?? 'Glass slider',
      hint: 'Use arrow keys to adjust value',
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: _handleFocusChange,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.label!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.showValue)
                      Text(
                        '${(widget.value * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.05)
                        : const Color.fromRGBO(0, 0, 0, 0.03),
                    isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.02)
                        : const Color.fromRGBO(0, 0, 0, 0.01),
                  ],
                ),
                border: Border.all(
                        color: _isFocused
                            ? accent.withValues(alpha: 0.4)
                            : const Color.fromRGBO(255, 255, 255, 0.2),
                        width: _isFocused ? 2.0 : 1.0,
                      ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Builder(
                  builder: (context) {
                    final monitor = PerformanceMonitor();
                    final shouldDisableBackdrop = monitor.shouldDisableBackdropFilter;
                    final adaptiveBlur = 5 * monitor.adaptiveBlurQuality;
                    
                    final sliderContent = SliderTheme(
                    data: theme.sliderTheme.copyWith(
                      activeTrackColor: accent,
                      inactiveTrackColor: isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.3)
                          : const Color.fromRGBO(0, 0, 0, 0.2),
                      thumbColor: accent,
                      overlayColor: accent.withValues(alpha: 0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 4,
                      ),
                    ),
                    child: Slider(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      min: widget.min,
                      max: widget.max,
                    ),
                      );
                    
                    if (shouldDisableBackdrop) {
                      return sliderContent;
                    }
                    
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: adaptiveBlur, sigmaY: adaptiveBlur),
                      child: sliderContent,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glassmorphism button with glow effects
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? accentColor;
  final bool isSelected;
  final bool showGlow;
  final String? semanticLabel;
  // When false, the button skips the heavy BackdropFilter to reduce GPU load
  final bool useBackdrop;

  const GlassButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 16.0,
    this.accentColor,
    this.isSelected = false,
    this.showGlow = false,
    this.semanticLabel,
    this.useBackdrop = true,
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isFocused = false;
  bool _isPressed = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (widget.onPressed != null && 
        (event.logicalKey == LogicalKeyboardKey.enter || 
         event.logicalKey == LogicalKeyboardKey.space)) {
      if (event is KeyDownEvent) {
        setState(() {
          _isPressed = true;
        });
      } else if (event is KeyUpEvent) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed!();
      }
    }
  }

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accentColor ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticLabel ?? 'Glass button',
      hint: widget.onPressed != null ? 'Double tap to activate' : null,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: _handleFocusChange,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isSelected
                  ? [
                      accent.withValues(alpha: 0.3),
                      accent.withValues(alpha: 0.1),
                    ]
                  : [
                      isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.1)
                          : const Color.fromRGBO(0, 0, 0, 0.05),
                      isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.05)
                          : const Color.fromRGBO(0, 0, 0, 0.02),
                    ],
            ),
            border: Border.all(
              color: widget.isSelected || _isFocused
                  ? accent.withValues(alpha: 0.4)
                  : const Color.fromRGBO(255, 255, 255, 0.2),
              width: _isFocused ? 2.0 : 1.5,
            ),
            boxShadow: [
              if (widget.showGlow || widget.isSelected || _isFocused)
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: (() {
                  final content = AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      child: Padding(
                        padding: widget.padding ?? const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: widget.child,
                      ),
                    ),
                  );
                  if (!widget.useBackdrop) {
                    return content;
                  }
                  final monitor = PerformanceMonitor();
                  final shouldDisableBackdrop = monitor.shouldDisableBackdropFilter;
                  
                  if (shouldDisableBackdrop) {
                    return content;
                  }
                  
                  final adaptiveBlur = 8 * monitor.adaptiveBlurQuality;
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: adaptiveBlur, sigmaY: adaptiveBlur),
                    child: content,
                  );
                })(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}