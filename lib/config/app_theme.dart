import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Ethereal & Calming
  static const Color primaryCharcoal = Color(0xFF2D312E);
  static const Color softObsidian = Color(0xFF121418);
  static const Color deepForest = Color(0xFF1E2824);
  
  // Light Mode Tokens
  static const Color lightBlue = Color(0xFFE8ECE5);
  static const Color lightSage = Color(0xFFF4F7F6);
  static const Color warmSand = Color(0xFFF3EAE3);

  // Legacy/Missing Colors (Map to existing or new defaults)
  static const Color backgroundColor = softObsidian;
  static const Color primaryColor = Color(0xFF7B5CF0);
  static const Color secondaryColor = Color(0xFF818CF8);
  static const Color textPrimary = Colors.white;

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B5CF0), // Keep accent for highlights
        surface: lightSage,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primaryCharcoal,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryCharcoal,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: primaryCharcoal,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: primaryCharcoal.withOpacity(0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B5CF0),
        brightness: Brightness.dark,
        surface: softObsidian,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
      ),
    );
  }
}
