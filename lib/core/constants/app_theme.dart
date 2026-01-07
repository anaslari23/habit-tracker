import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        background: const Color(0xFFF8FAFC),
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w900, 
          letterSpacing: -0.5, 
          color: Color(0xFF0F172A),
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w900, 
          color: Color(0xFF0F172A),
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w600, 
          color: Color(0xFF0F172A),
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w500, 
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.premiumCard,
        background: AppColors.premiumBlack,
        onSurface: Colors.white,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.premiumBlack,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: AppColors.premiumCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF2D323C), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w900, 
          letterSpacing: -0.8, 
          color: Colors.white,
          fontSize: 32,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w900, 
          color: Colors.white,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w700, 
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w500, 
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
    );
  }
}
