import 'package:flutter/material.dart';

class AppTheme {
  static const Color accentYellow = Color(0xFFFFD500);
  static const Color accentYellowLight = Color(0xFFFFD500);
  static const Color accentYellowDark = Color(0xFFFFB700);
  static const Color ink = Color(0xFF111111);
  static const Color mutedInk = Color(0xFF555555);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color softSurface = Color(0xFFF7F7F4);
  static const Color border = Color(0xFFE7E2D8);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentYellow,
      brightness: Brightness.light,
      primary: ink,
      secondary: accentYellow,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: null,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentYellow.withValues(alpha: 0.35),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: ink,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 42,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: mutedInk,
        ),
      ),
    );
  }
}
