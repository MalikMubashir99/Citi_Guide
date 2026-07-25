import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xff0984E3);
  static const Color primaryLight = Color(0xff74B9FF);
  static const Color primaryDark = Color(0xff0652DD);
  
  // Secondary Colors
  static const Color secondary = Color(0xff00CEC9);
  static const Color secondaryLight = Color(0xff81ECEC);
  static const Color secondaryDark = Color(0xff00A8A4);
  
  // Accent Colors
  static const Color accent = Color(0xffFDCB6E);
  static const Color success = Color(0xff00B894);
  static const Color warning = Color(0xffFDCB6E);
  static const Color error = Color(0xffE17055);
  static const Color info = Color(0xff0984E3);
  
  // Neutral Colors
  static const Color dark = Color(0xff2D3436);
  static const Color darkGrey = Color(0xff636E72);
  static const Color grey = Color(0xffB2BEC3);
  static const Color lightGrey = Color(0xffDFE6E9);
  static const Color background = Color(0xffF8F9FA);
  static const Color white = Colors.white;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff0984E3),
      Color(0xff00CEC9),
    ],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff2D3436),
      Color(0xff636E72),
    ],
  );
  
  // Shadows
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}