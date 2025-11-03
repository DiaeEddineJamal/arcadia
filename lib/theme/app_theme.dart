import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Color palette
  static const Color primaryDark = Color(0xFF0A0A0F);
  static const Color primaryLight = Color(0xFFF8F9FA);
  
  // Surface colors for better depth
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantDark = Color(0xFF16213E);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  
  // Accent colors inspired by app icon
  static const Color accentLime = Color(0xFFAFFF00); // Bright lime green from icon
  static const Color accentPurple = Color(0xFF5E2B8C); // Deep purple from icon
  static const Color accentMagenta = Color(0xFF8C3D9F); // Magenta from icon
  static const Color accentOrange = Color(0xFFE08C4D); // Orange from icon
  static const Color accentYellow = Color(0xFFFFC000); // Bright yellow from icon
  static const Color accentCoral = Color(0xFFFF6B9D); // Keep coral
  static const Color accentMint = Color(0xFF81C784); // Keep mint
  static const Color accentPeach = Color(0xFFFFAB91); // Keep peach
  
  // Semantic colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Glass colors with improved accessibility contrast
  static const Color glassDark = Color(0x26FFFFFF);
  static const Color glassLight = Color(0x26000000);
  static const Color glassAccentDark = Color(0x40FFFFFF);
  static const Color glassAccentLight = Color(0x40000000);
  
  // Gradient colors
  static const List<Color> darkGradient = [
    Color(0xFF0A0A0F),
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ];
  
  static const List<Color> lightGradient = [
    Color(0xFFF8F9FA),
    Color(0xFFE9ECEF),
    Color(0xFFDEE2E6),
  ];
  
  // Typography constants
  static const String fontFamily = 'Inter';
  static const double baseLetterSpacing = 0.0;
  static const double headingLetterSpacing = -0.5;
  static const double bodyLetterSpacing = 0.25;
  
  // Get accent color by name
  static Color getAccentColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'lime':
        return accentLime;
      case 'purple':
        return accentPurple;
      case 'magenta':
        return accentMagenta;
      case 'orange':
        return accentOrange;
      case 'yellow':
        return accentYellow;
      case 'coral':
        return accentCoral;
      case 'mint':
        return accentMint;
      case 'peach':
        return accentPeach;
      default:
        return accentLime; // Default to lime green
    }
  }
  
  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentLime,
        secondary: accentCoral,
        tertiary: accentPurple,
        surface: surfaceDark,
        surfaceVariant: surfaceVariantDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        error: errorColor,
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: glassDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Text theme with improved hierarchy
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: baseLetterSpacing,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.45,
        ),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: accentLime,
        inactiveTrackColor: Colors.white24,
        thumbColor: accentLime,
        overlayColor: accentLime.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentLime,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentLime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentLime,
          side: const BorderSide(color: accentLime, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentLime,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentLime, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: glassDark,
        selectedColor: accentLime.withValues(alpha: 0.3),
        disabledColor: Colors.white12,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: primaryLight,
      colorScheme: const ColorScheme.light(
        primary: accentLime,
        secondary: accentCoral,
        tertiary: accentPurple,
        surface: surfaceLight,
        surfaceVariant: surfaceVariantLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onSurfaceVariant: Colors.black54,
        error: errorColor,
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: glassLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Text theme with improved hierarchy
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: headingLetterSpacing,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: baseLetterSpacing,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: baseLetterSpacing,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: bodyLetterSpacing,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black54,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: bodyLetterSpacing,
          height: 1.45,
        ),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: accentLime,
        inactiveTrackColor: Colors.black26,
        thumbColor: accentLime,
        overlayColor: accentLime.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.black,
        size: 24,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentLime,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentLime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentLime,
          side: const BorderSide(color: accentLime, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: bodyLetterSpacing,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentLime,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentLime, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: glassLight,
        selectedColor: accentLime.withValues(alpha: 0.3),
        disabledColor: Colors.black12,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}