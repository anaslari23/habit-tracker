import 'package:flutter/material.dart';

class AppColors {
  // Premium Signature Colors (Image Inspired)
  static const Color primary = Color(0xFF4DB1A7); // Premium Teal
  static const Color premiumBlack = Color(0xFF0F1115); // Background
  static const Color premiumCard = Color(0xFF1C1F26); // Card Surface
  static const Color premiumBorder = Color(0xFF2D323C); // Subtle Borders
  
  static const Color accent = Color(0xFFF8961E);  // Energy Orange
  static const Color slate = Color(0xFF1E293B);
  
  // Status Colors
  static const Color completed = Color(0xFF4DB1A7); 
  static const Color goal = Color(0xFF90BE6D);      
  static const Color skipped = Color(0xFFF94144);   
  static const Color pending = Color(0xFF333B45);   
  
  // Background & Surface
  static const Color background = premiumBlack;
  static const Color darkBackground = premiumBlack;
  static const Color surface = premiumCard;
  static const Color glassSurface = Color(0x1A4DB1A7); // Translucent teal
  static const Color glassWhite = Color(0x0DFFFFFF); // Extremely translucent white

  // Text Colors (High Contrast)
  static const Color textPrimary = Colors.white; 
  static const Color textSecondary = Color(0xFF94A3B8); // Muted Slate
  static const Color textTertiary = Color(0xFF64748B); 
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkSecondary = Color(0xFF94A3B8);
  
  // Gradients
  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFF4DB1A7), Color(0xFF3A8C84)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1C1F26), Color(0xFF0F1115)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Compatibility aliases
  static const Color secondary = accent;
  static const Color darkSurface = premiumCard;
  static const LinearGradient primaryGradient = activeGradient;
}
