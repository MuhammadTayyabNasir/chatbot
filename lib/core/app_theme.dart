import 'package:flutter/material.dart';

// Custom theme extension for additional colors not in the default ThemeData
extension CustomColorScheme on ColorScheme {
  Color get userBubble => brightness == Brightness.light
      ? const Color(0xFFE3F2FD) // A light, friendly blue for light mode
      : const Color(0xFF1A3D6F); // A deep blue for dark mode

  Color get botBubble => brightness == Brightness.light
      ? const Color(0xFFFFFFFF) // Clean white for light mode
      : const Color(0xFF303134); // A dark grey for dark mode

  Color get replyBanner => brightness == Brightness.light
      ? Colors.blue.withOpacity(0.1)
      : Colors.blue.withOpacity(0.15);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);
    final colorScheme = baseTheme.colorScheme.copyWith(
      primary: const Color(0xFF1976D2), // Google Blue
      secondary: const Color(0xFF4285F4),
      surface: const Color(0xFFF5F5F7), // Main background
      background: const Color(0xFFF5F5F7),
    );

    return baseTheme.copyWith(
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: Colors.grey[800], // Icon/title color
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // --- NEW: Added ChipThemeData for consistent chip styling ---
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(color: Colors.grey.shade800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto', displayColor: Colors.black, bodyColor: Colors.black87),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final colorScheme = baseTheme.colorScheme.copyWith(
      primary: const Color(0xFF64B5F6), // A lighter blue for contrast
      secondary: const Color(0xFF8AB4F8),
      surface: const Color(0xFF303134), // Card/bubble background
      background: const Color(0xFF202124), // Main background
      brightness: Brightness.dark,
    );

    return baseTheme.copyWith(
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: Colors.grey[300],
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // --- NEW: Added ChipThemeData for consistent chip styling ---
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF424242),
        labelStyle: TextStyle(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.onSurface.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
        ),
      ),
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto', displayColor: Colors.white, bodyColor: Colors.white70),
    );
  }
}