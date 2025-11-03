import 'package:flutter/material.dart';

/// Disables the default GlowingOverscrollIndicator on scrollables.
class NoGlowScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return the child directly to prevent the glow effect at scroll bounds.
    return child;
  }
}