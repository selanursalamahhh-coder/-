import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4F8A65);
  static const Color cream = Color(0xFFFFF7E0);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: cream,
      background: cream,
    ),
    cardColor: white,
    textTheme: GoogleFonts.poppinsTextTheme(),
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
