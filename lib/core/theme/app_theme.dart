import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ✅ Light Theme
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
    
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.dark,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.dark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.darkGrey,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.grey,
      ),
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.dark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.dark,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.dark,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.darkGrey,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
      ),
      errorStyle: GoogleFonts.poppins(
        color: AppColors.error,
        fontSize: 12,
      ),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.darkGrey,
    ),
    
    // ✅ Fixed: CardThemeData instead of CardTheme
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.05),
      margin: const EdgeInsets.all(8),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightGrey,
      disabledColor: AppColors.grey,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
      contentTextStyle: GoogleFonts.poppins(
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
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
  
  // ✅ Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1A1A2E),
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Color(0xff16213E),
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.lightGrey,
      ),
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.white,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.white,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff2D2D44),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.lightGrey,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
      ),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.lightGrey,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // ✅ Fixed: CardThemeData instead of CardTheme
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xff2D2D44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.all(8),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff2D2D44),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}