// lib/core/theme/app_theme.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ✅ Light Theme - Premium Warm Earth Tones
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background, // Warm Linen
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface, // Pure White for cards/inputs
      error: AppColors.error,     // Burnt Sienna
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.dark,  // Rich Dark Brown text
      onError: AppColors.white,
    ),
    
    // ✅ Typography with Google Fonts
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.dark,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
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
        color: AppColors.darkGrey, // Warm Charcoal
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.dark,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.darkGrey,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.grey, // Warm Grey
        height: 1.5,
      ),
    ),
    
    // ✅ AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.background, // Matches scaffold
      foregroundColor: AppColors.dark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.dark,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.dark,
      ),
    ),
    
    // ✅ ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Flat modern style
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    
    // ✅ OutlinedButton Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.primaryLight, // Softer border
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // ✅ TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark, // Darker brown for better readability on light BG
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // ✅ Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface, // Pure white
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
        borderSide: BorderSide(
          color: AppColors.lightGrey, // Warm Mist border
          width: 1,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.darkGrey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.poppins(
        color: AppColors.error,
        fontSize: 12,
      ),
      prefixIconColor: AppColors.secondaryDark, // Golden hint
      suffixIconColor: AppColors.darkGrey,
    ),
    
    // ✅ Card Theme
    cardTheme: CardThemeData(
      elevation: 0, // Modern flat cards
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.lightGrey.withValues(alpha: 0.5), // Subtle warm border instead of shadow
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    ),
    
    // ✅ Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondaryLight, // Pale Peach - much softer than grey
      disabledColor: AppColors.lightGrey,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      secondarySelectedColor: AppColors.secondaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.3), // Subtle golden border
          width: 1,
        ),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      ),
      brightness: Brightness.light,
    ),
    
    // ✅ Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.lightGrey.withValues(alpha: 0.7),
      thickness: 1,
      space: 20,
    ),
    
    // ✅ SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.white,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.dark, // Rich dark brown
      elevation: 4,
    ),
    
    // ✅ Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    ),
    
    // ✅ Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Squircle instead of perfect circle for modern look
      ),
    ),
    
    // ✅ Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    ),
    
    // ✅ Bottom Sheet Theme
   bottomSheetTheme: const BottomSheetThemeData(
  backgroundColor: AppColors.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(24),
    ),
  ),
  elevation: 0,
),
    // ✅ Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // ✅ Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return null;
      }),
    ),
    
    // ✅ Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.surface;
        }
        return AppColors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary; // Rich cognac when on
        }
        return AppColors.lightGrey; // Warm mist when off
      }),
    ),
  );
  
  // ✅ Dark Theme - Deep Espresso & Midnight Brown
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1410), // Deep midnight brown
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary, // Use lighter Sand/Gold for dark theme primary actions
      secondary: AppColors.secondaryLight,
      surface: Color(0xFF2A1E18), // Rich dark card surface
      error: AppColors.error,
      onPrimary: AppColors.dark,
      onSecondary: AppColors.dark,
      onSurface: AppColors.secondaryLight, // Pale peach for main text
      onError: AppColors.white,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.3,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.secondaryLight, // Easy on the eyes
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.grey,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.darkGrey,
        height: 1.5,
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
        letterSpacing: 0.3,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.white,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A1E18), // Matches surface
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
        borderSide: BorderSide(
          color: AppColors.darkGrey.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.secondary, // Golden focus ring
          width: 2,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.darkGrey,
        fontSize: 14,
      ),
      prefixIconColor: AppColors.secondary,
      suffixIconColor: AppColors.grey,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: AppColors.secondary, // Golden button stands out in dark mode
        foregroundColor: AppColors.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF2A1E18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.darkGrey.withValues(alpha: 0.3), // Subtle warm border
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2A1E18),
      selectedItemColor: AppColors.secondary, // Golden selected state
      unselectedItemColor: AppColors.darkGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.dark,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.secondary, // Golden snackbar
      elevation: 4,
    ),
    
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.dark;
        }
        return AppColors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.secondary;
        }
        return AppColors.darkGrey;
      }),
    ),
  );
}