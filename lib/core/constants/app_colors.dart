// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 🟤 Primary Brown Colors
  static const Color primary = Color(0xff8D6E63);      // Warm Brown
  static const Color primaryLight = Color(0xffA1887F);  // Light Brown
  static const Color primaryDark = Color(0xff5D4037);   // Dark Brown
  
  // 🟤 Secondary Colors
  static const Color secondary = Color(0xffD7A86E);     // Golden Brown
  static const Color secondaryLight = Color(0xffF5D6B3); // Cream
  static const Color secondaryDark = Color(0xffBF8F4A);  // Dark Gold
  
  // 🟤 Accent Colors
  static const Color accent = Color(0xffE8C9A0);        // Warm Cream
  static const Color success = Color(0xff6B8E6B);       // Earthy Green
  static const Color warning = Color(0xffD4A055);       // Golden
  static const Color error = Color(0xffC0392B);         // Deep Red
  static const Color info = Color(0xff5D7D9A);          // Muted Blue
  
  // 🟤 Neutral Colors - Warm Tones
  static const Color dark = Color(0xff3E2723);          // Dark Brown
  static const Color darkGrey = Color(0xff6D4C41);      // Brown Grey
  static const Color grey = Color(0xffA1887F);          // Warm Grey
  static const Color lightGrey = Color(0xffD7CCC8);     // Light Warm Grey
  static const Color background = Color(0xffFAF0E6);    // Linen
  static const Color white = Colors.white;
  
  // 🟤 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff8D6E63),
      Color(0xffD7A86E),
    ],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff3E2723),
      Color(0xff6D4C41),
    ],
  );
  
  // 🟤 Warm Shadow
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.brown.shade900.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.brown.shade900.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.brown.shade900.withValues(alpha: 0.18),
      blurRadius: 25,
      offset: const Offset(0, 12),
    ),
  ];
}