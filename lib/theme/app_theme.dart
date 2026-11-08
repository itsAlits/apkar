import 'package:flutter/material.dart';

class AppTheme {
  // Clean Solid Balinese Yellow & Minimal Dark Theme
  static const Color primaryColor = Color(0xFFFFC107); // Solid Clean Yellow (Kuning Bali)
  static const Color secondaryColor = Color(0xFFFFD54F); // Light Yellow Accent
  static const Color accentColor = Color(0xFFFFE082); // Soft Yellow Tint
  static const Color goldLight = Color(0xFFFFC107); // Solid Yellow
  static const Color backgroundColor = Color(0xFF0F1115); // Clean Dark Slate
  static const Color surfaceColor = Color(0xFF181B22); // Solid Card Surface
  static const Color surfaceElevated = Color(0xFF222733);
  static const Color errorColor = Color(0xFFFF5252);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyLarge: TextStyle(
          color: Colors.white70,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
        bodyMedium: TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
    );
  }
}
