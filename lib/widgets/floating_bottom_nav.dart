import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// A floating bottom navigation bar with glassmorphism design
class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;
  final EdgeInsetsGeometry margin;
  final Duration animationDuration;

  const FloatingBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 80,
    this.margin = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<AnimationController> _itemControllers = [];
  List<Animation<double>> _itemAnimations = [];
  List<AnimationController> _itemHoverControllers = [];
  List<Animation<double>> _itemHoverAnimations = [];
  
  // Focus management for keyboard navigation
  late FocusNode _focusNode;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _focusNode = FocusNode();
    _focusedIndex = widget.currentIndex;
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize item animations
    for (int i = 0; i < widget.items.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
      
      final hoverController = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      final hoverAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: hoverController,
        curve: Curves.easeInOut,
      ));
      
      _itemControllers.add(controller);
      _itemAnimations.add(animation);
      _itemHoverControllers.add(hoverController);
      _itemHoverAnimations.add(hoverAnimation);
    }

    _animationController.forward();
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateSelection();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    for (final controller in _itemHoverControllers) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _focusedIndex = (_focusedIndex - 1).clamp(0, widget.items.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _focusedIndex = (_focusedIndex + 1).clamp(0, widget.items.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.space) {
        _handleTap(_focusedIndex);
      }
    }
  }

  void _animateSelection() {
    for (int i = 0; i < _itemControllers.length; i++) {
      if (i == widget.currentIndex) {
        _itemControllers[i].forward();
      } else {
        _itemControllers[i].reverse();
      }
    }
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: widget.margin,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey.shade400)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildGradient(isDark),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          widget.items.length,
                          (index) => _buildNavItem(index, isDark),
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

  LinearGradient _buildGradient(bool isDark) {
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.8));
    
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundColor.withOpacity(0.9),
        backgroundColor.withOpacity(0.7),
      ],
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    final theme = Theme.of(context);
    final accent = widget.selectedColor ?? theme.colorScheme.primary;
    
    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          if (!isSelected) {
            _itemHoverControllers[index].forward();
          }
        },
        onExit: (_) {
          if (!isSelected) {
            _itemHoverControllers[index].reverse();
          }
        },
        child: GestureDetector(
          onTap: () => _handleTap(index),
          child: Semantics(
            label: '${item.label} tab',
            hint: isSelected 
                ? 'Currently selected tab' 
                : 'Double tap to navigate to ${item.label}',
            selected: isSelected,
            button: true,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _itemAnimations[index],
                _itemHoverAnimations[index],
              ]),
              builder: (context, child) {
              final animationValue = _itemAnimations[index].value;
              final hoverValue = _itemHoverAnimations[index].value;
              final combinedValue = (animationValue + hoverValue).clamp(0.0, 1.0);
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 4 + (combinedValue * 2),
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16 + (combinedValue * 4)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(0.1 + (combinedValue * 0.2)),
                      accent.withOpacity(0.05 + (combinedValue * 0.1)),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withOpacity(0.2 + (combinedValue * 0.3)),
                    width: 1 + (combinedValue * 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.1 + (combinedValue * 0.2)),
                      blurRadius: 8 + (combinedValue * 12),
                      offset: Offset(0, 2 + (combinedValue * 4)),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1.0 + (hoverValue * 0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(6 + (combinedValue * 2)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(combinedValue * 0.2),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 20 + (combinedValue * 2),
                            color: Color.lerp(
                              isDark ? Colors.white70 : Colors.black54,
                              accent,
                              combinedValue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: 0.7 + (combinedValue * 0.3),
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10 + (combinedValue * 1),
                              fontWeight: isSelected || hoverValue > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: Color.lerp(
                                isDark ? Colors.white70 : Colors.black54,
                                accent,
                                combinedValue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }
}

/// Navigation item data class
class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}