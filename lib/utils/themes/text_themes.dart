import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watr/utils/themes/colors.dart';

class AppTextThemes {
  static TextTheme lightTextTheme = TextTheme(
    // Display and Headline sizes
    headlineLarge: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 57.0, // Standard size for display large
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    headlineMedium: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 45.0, // Standard size for display medium
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    headlineSmall: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 36.0, // Standard size for display small
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
    ),
    // Body text sizes
    bodyLarge: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 18.0, // Standard size for body large
        fontWeight: FontWeight.normal,
      ),
    ),
    bodyMedium: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16.0, // Standard size for body medium
        fontWeight: FontWeight.normal,
        color: Colors.black54,
      ),
    ),
    bodySmall: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 14.0, // Standard size for body small
        fontWeight: FontWeight.normal,
      ),
    ),
    // Button and caption sizes
    labelLarge: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 14.0, // Standard size for label large
        fontWeight: FontWeight.w500,
        color: AppColors.buttons,
      ),
    ),
    labelMedium: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 12.0, // Standard size for label medium
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
    ),
    labelSmall: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 11.0, // Standard size for label small
        fontWeight: FontWeight.normal,
        color: Colors.black45,
      ),
    ),
    // Display sizes for larger text
    displayLarge: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 57.0, // Standard size for display large
        fontWeight: FontWeight.bold,
      ),
    ),
    displayMedium: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 45.0, // Standard size for display medium
        fontWeight: FontWeight.bold,
        color: AppColors.buttons,
      ),
    ),
    displaySmall: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 36.0, // Standard size for display small
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    // Subheading and overline sizes
    titleMedium: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 16.0, // Standard size for subtitle1
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
    titleSmall: GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontSize: 14.0, // Standard size for subtitle2
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
    ),
  );
}
