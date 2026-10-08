import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceHighlight = Color(0xFF2F2F2F);
  static const Color primary = Color(0xFFE50914); // Pulse Red
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9AA0B4);

  // Futuristic accent palette
  static const Color violet = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color magenta = Color(0xFFFF2E93);
  static const Color deepSpace = Color(0xFF05060F);
  static const Color glass = Color(0xFF12142A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, magenta, violet],
  );
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, violet, magenta],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
      ),
      // Rajdhani is highly readable but looks very technical/futuristic
      textTheme: GoogleFonts.rajdhaniTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        // Orbitron is the quintessential sci-fi/futuristic font for headers
        displayLarge: GoogleFonts.orbitron(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.rajdhani(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.orbitron(
          color: primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
