import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color green700 = Color(0xFF15803d);
  static const Color green600 = Color(0xFF16a34a);
  static const Color green50 = Color(0xFFf0fdf4);
  static const Color green100 = Color(0xFFdcfce7);
  static const Color green200 = Color(0xFFbbf7d0);
  static const Color green400 = Color(0xFF4ade80);
  static const Color green500 = Color(0xFF22c55e);
  static const Color slate50 = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1e293b);
  static const Color slate900 = Color(0xFF0f172a);
  static const Color orange50 = Color(0xFFfff7ed);
  static const Color orange500 = Color(0xFFf97316);
  static const Color orange600 = Color(0xFFea580c);
  static const Color blue50 = Color(0xFFeff6ff);
  static const Color blue600 = Color(0xFF2563eb);
  static const Color red50 = Color(0xFFfef2f2);
  static const Color red200 = Color(0xFFfecaca);
  static const Color red500 = Color(0xFFef4444);
  static const Color red600 = Color(0xFFdc2626);
  static const Color amber400 = Color(0xFFfbbf24);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: slate50,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green700,
        primary: green700,
        surface: Colors.white,
        background: slate50,
      ),
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.notoSans(color: slate900, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.notoSans(color: slate700),
        bodyMedium: GoogleFonts.notoSans(color: slate500),
        labelLarge: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: slate900),
        titleTextStyle: TextStyle(color: slate900, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: slate900,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: green700,
        primary: green600,
        surface: slate800,
        background: slate900,
      ),
      textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.notoSans(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.notoSans(color: slate200),
        bodyMedium: GoogleFonts.notoSans(color: slate400),
        labelLarge: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slate800,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
