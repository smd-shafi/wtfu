import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color darkBg = Color(0xFF0F0E17);
  static const Color darkCard = Color(0xFF1F1E26);
  static const Color primaryPurple = Color(0xFF8D72E1);
  static const Color accentCyan = Color(0xFF00ADB5);
  static const Color neonAmber = Color(0xFFFF9F1C);
  static const Color alarmRed = Color(0xFFFF4A5A);
  static const Color textLight = Color(0xFFFFEFFF);
  static const Color textDark = Color(0xFF2D3142);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentCyan,
        surface: darkCard,
        error: alarmRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F5F9),
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentCyan,
        surface: Colors.white,
        error: alarmRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
