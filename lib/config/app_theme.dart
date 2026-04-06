import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - Premium Apple-Inspired
  static const Color backgroundColor = Color(0xFF0A0F1E); // Deep Navy
  static const Color primaryColor = Color(0xFF7B5CF0); // Accent Purple
  static const Color secondaryColor = Color(0xFFA78BFA); // Lavender
  
  // Surface Colors for Glass Effects
  static const Color glassColor = Color(0x14FFFFFF); // White with 8% opacity
  static const Color glassBorderColor = Color(0x26FFFFFF); // White with 15% opacity

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Crucial for dark theme text handling
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor, // Background color for Material 3 surfaces
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Handled by BoxDecoration for gradients
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Fully rounded
          ),
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassColor,
        hintStyle: const TextStyle(color: Colors.white38),
        iconColor: primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: glassBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: glassBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800, // Extra bold for Apple style
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 17, // Standard Apple body size
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: textSecondary,
          fontWeight: FontWeight.w300, // Light for subtext
        ),
      ),
    );
  }
}
