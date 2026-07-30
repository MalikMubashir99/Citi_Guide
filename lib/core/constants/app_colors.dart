// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // =========================================================
  // 🌅 PRIMARY PALETTE - Rich Cognac & Espresso
  // =========================================================
  static const Color primary = Color(0xFF7B5B3A);        // Rich Cognac Brown (Main actions, headers)
  static const Color primaryLight = Color(0xFF9E7E5D);    // Soft Camel (Hover states, highlights)
  static const Color primaryDark = Color(0xFF5C3D24);     // Deep Espresso (Deepest accents)
  static const Color primarySurface = Color(0xFFFBF6F1);  // Ultra-light warm tint (For primary containers)

  // =========================================================
  // ✨ SECONDARY PALETTE - Golden Hour / Sand
  // =========================================================
  static const Color secondary = Color(0xFFD4A574);       // Warm Sand (Secondary buttons, tags)
  static const Color secondaryLight = Color(0xFFF2DCC8);  // Pale Peach (Light backgrounds, dividers)
  static const Color secondaryDark = Color(0xFFB8864E);   // Deep Gold (Active states)

  // =========================================================
  // 🎨 ACCENT & STATUS COLORS - Earthy & Calming
  // =========================================================
  static const Color accent = Color(0xFFC9956B);          // Terracotta (Special highlights)
  static const Color success = Color(0xFF7D9F85);         // Sage Green (Success states - earthy, not neon)
  static const Color warning = Color(0xFFE4A853);         // Marigold (Warnings - warm yellow)
  static const Color error = Color(0xFFC75B4A);           // Burnt Sienna (Errors - softer than pure red)
  static const Color info = Color(0xFF6B8BA4);            // Dusty Blue (Info - cool contrast to warm theme)

  // =========================================================
  // 📝 NEUTRAL PALETTE - Warm Tones (Perfect for Text & BGs)
  // =========================================================
  static const Color dark = Color(0xFF2C1810);            // Rich Dark Brown (Main text - softer than black)
  static const Color darkGrey = Color(0xFF7D6653);        // Warm Charcoal (Secondary text)
  static const Color grey = Color(0xFFB8A99A);            // Warm Grey (Placeholder text, disabled)
  static const Color lightGrey = Color(0xFFE8E0D8);       // Warm Mist (Borders, inactive tracks)
  static const Color background = Color(0xFFFAF6F1);      // Warm Linen (App background - easier on eyes)
  static const Color surface = Color(0xFFFFFFFF);         // Pure White (Cards, Dialogs, Inputs)
  static const Color surfaceWarm = Color(0xFFFDF9F5);     // Off-White (Alternate card backgrounds)
  static const Color white = Color(0xFFFFFFFF);

  // =========================================================
  // 📱 SPLASH SCREEN SPECIFIC COLORS
  // =========================================================
  static const Color splashOverlayDark = Color(0xFF1A110A); // Deep dark brown for splash gradient bottom
  static const Color splashIconBg = Color(0xFF6D5D4E);      // The exact grey-brown for the location circle

  // =========================================================
  // 🌈 GRADIENTS
  // =========================================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7B5B3A), // Cognac
      Color(0xFFD4A574), // Sand
    ],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFD4A574), // Sand
      Color(0xFFC9956B), // Terracotta
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C1810), // Rich Dark
      Color(0xFF5C3D24), // Espresso
    ],
  );

  // =========================================================
  // 💡 SHADOWS (Warm toned instead of stark black)
  // =========================================================
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: const Color(0xFF2C1810).withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF2C1810).withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: const Color(0xFF2C1810).withValues(alpha: 0.15),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get warmGlow => [
        BoxShadow(
          color: const Color(0xFFD4A574).withValues(alpha: 0.4), // Golden glow
          blurRadius: 25,
          offset: const Offset(0, 8),
        ),
      ];
}