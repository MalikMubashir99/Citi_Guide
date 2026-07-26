// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // 🟤 Light Theme - Brownish
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.dark,
      onError: AppColors.white,
    ),
    
    textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
      // Using Playfair Display for elegant look
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
        letterSpacing: 0.3,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      titleSmall: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: AppColors.dark,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: AppColors.darkGrey,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: AppColors.grey,
        height: 1.5,
      ),
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.dark,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.dark,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.lato(
        color: AppColors.darkGrey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.lato(
        color: AppColors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.lato(
        color: AppColors.error,
        fontSize: 12,
      ),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.darkGrey,
    ),
    
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.brown.shade900.withValues(alpha: 0.08),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightGrey,
      disabledColor: AppColors.grey,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      brightness: Brightness.light,
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.lightGrey,
      thickness: 1,
      space: 20,
    ),
    
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentTextStyle: GoogleFonts.lato(
        fontSize: 14,
        color: AppColors.white,
      ),
      backgroundColor: AppColors.dark,
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
  
  // 🟤 Dark Theme - Brownish
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1A1410),
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Color(0xff2C1F1A),
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),
    
    textTheme: GoogleFonts.playfairDisplayTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.3,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: AppColors.white,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: AppColors.lightGrey,
        height: 1.6,
      ),
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.white,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.white,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff2C1F1A),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.lato(
        color: AppColors.lightGrey,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.lato(
        color: AppColors.grey,
        fontSize: 14,
      ),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.lightGrey,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xff2C1F1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff2C1F1A),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}