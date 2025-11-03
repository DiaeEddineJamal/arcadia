import 'package:flutter/material.dart';

/// Custom page transitions for smooth navigation animations
class PageTransitions {
  
  /// Smooth fade transition with optional slide effect
  static PageRouteBuilder<T> fadeTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
    bool slideFromRight = false,
    bool slideFromBottom = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Create fade animation
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // Create slide animation if requested
        if (slideFromRight || slideFromBottom) {
          final slideAnimation = Tween<Offset>(
            begin: slideFromRight 
                ? const Offset(1.0, 0.0) 
                : const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          ));

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        }

        // Pure fade transition
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  /// Smooth slide transition from right
  static PageRouteBuilder<T> slideFromRight<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.7, curve: curve),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Smooth slide transition from bottom
  static PageRouteBuilder<T> slideFromBottom<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.8, curve: curve),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition with fade effect
  static PageRouteBuilder<T> scaleTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
    double initialScale = 0.8,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: initialScale,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Rotation transition with fade effect
  static PageRouteBuilder<T> rotationTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.3, 1.0, curve: curve),
        ));

        return RotationTransition(
          turns: rotationAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Custom glassmorphism-style transition
  static PageRouteBuilder<T> glassmorphismTransition<T extends Object?>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combine multiple animations for a premium feel
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.8, curve: curve),
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}