import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced floating bottom navigation bar with smooth animations
class EnhancedFloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final List<FloatingNavItem> items;
  final Function(int) onTap;
  final Color? selectedColor;

  const EnhancedFloatingBottomNav({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.selectedColor,
  }) : super(key: key);

  @override
  State<EnhancedFloatingBottomNav> createState() => _EnhancedFloatingBottomNavState();
}

class _EnhancedFloatingBottomNavState extends State<EnhancedFloatingBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Reduced from 300ms
    );
    _indicatorAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOut, // Changed to easeOut
    ));
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(EnhancedFloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateIndicator();
    }
  }

  void _animateIndicator() {
    _indicatorAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOut, // Changed to easeOut
    ));

    _indicatorController.reset();
    _indicatorController.forward();
    _previousIndex = widget.currentIndex;
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
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
    final accent = widget.selectedColor ?? theme.colorScheme.primary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Increase horizontal margins to slightly reduce overall nav bar width
    const double horizontalMargin = 40.0;

    return RepaintBoundary( // Wrap in RepaintBoundary to reduce repaints
      child: Container(
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomPadding > 0 ? 20 : 30),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.15), // Reduced opacity
              blurRadius: 20, // Reduced blur
              offset: const Offset(0, 8), // Reduced offset
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08), // Reduced opacity
              blurRadius: 25, // Reduced blur
              offset: const Offset(0, 12), // Reduced offset
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Reduced blur
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.4),
                        ]
                      : [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                ),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.8),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Navigation items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      widget.items.length,
                      (index) => _buildNavItem(index, isDark, accent),
                    ),
                  ),
                  
                  // Animated indicator - centered beneath icons
                  AnimatedBuilder(
                    animation: _indicatorAnimation,
                    builder: (context, child) {
                      final screenWidth = MediaQuery.of(context).size.width - (horizontalMargin * 2); // Minus horizontal margins
                      final itemWidth = screenWidth / widget.items.length;
                      final indicatorWidth = itemWidth * 0.3;
                      // Center the indicator: item center minus half indicator width
                      final indicatorLeft = (_indicatorAnimation.value * itemWidth) + (itemWidth / 2) - (indicatorWidth / 2);
                      
                      return Positioned(
                        bottom: 8,
                        left: indicatorLeft,
                        child: Container(
                          width: indicatorWidth,
                          height: 3,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark, Color accent) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;

    return Expanded(
      child: RepaintBoundary( // Wrap each nav item in RepaintBoundary
        child: GestureDetector(
          onTap: () => _handleTap(index),
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            label: '${item.label} tab',
            hint: isSelected 
                ? 'Currently selected' 
                : 'Double tap to open ${item.label}',
            selected: isSelected,
            button: true,
            child: Container(
              height: 70,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200), // Reduced from 300ms
                curve: Curves.easeOut, // Changed to easeOut
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? accent.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: isSelected ? 26 : 22,
                  color: isSelected 
                      ? accent
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

