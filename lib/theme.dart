import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define your core colors
  static const Color _darkPrimaryColor = Color(
    0xFF1A237E,
  ); // A deep indigo/blue for primary
  static const Color _darkPrimaryVariantColor = Color(
    0xFF303F9F,
  ); // A slightly lighter indigo

  static const Color _darkSecondaryColor = Color(
    0xFFF50057,
  ); // A vibrant pink (Pink Accent 400)
  static const Color _darkSecondaryVariantColor = Color(
    0xFFC51162,
  ); // A deeper pink accent

  static const Color _darkBackgroundColor = Color(
    0xFF121212,
  ); // Standard dark theme background
  static const Color _darkSurfaceColor = Color(
    0xFF1E1E1E,
  ); // Slightly lighter for cards, dialogs
  static const Color _darkErrorColor = Color(
    0xFFCF6679,
  ); // Standard dark theme error color

  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkOnSecondaryColor = Colors.white;
  static const Color _darkOnBackgroundColor = Colors.white;
  static const Color _darkOnSurfaceColor = Colors.white;
  static const Color _darkOnErrorColor = Colors.black;

  // Text Style
  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: _darkOnBackgroundColor,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: _darkOnBackgroundColor,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: _darkOnBackgroundColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: _darkOnBackgroundColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: _darkOnBackgroundColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: _darkOnBackgroundColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: _darkOnBackgroundColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: _darkOnBackgroundColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: _darkOnSurfaceColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: _darkOnSurfaceColor,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: _darkOnSecondaryColor,
    ), // For button text
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: _darkOnSurfaceColor.withOpacity(0.7),
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      color: _darkOnSurfaceColor.withOpacity(0.7),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackgroundColor,
    primaryColor: _darkPrimaryColor,
    // primaryColorDark: _darkPrimaryVariantColor, // Deprecated, use colorScheme.primaryContainer
    // primaryColorLight: _darkPrimaryColor, // Deprecated, use colorScheme.primary
    // accentColor: _darkSecondaryColor, // Deprecated, use colorScheme.secondary
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      primaryContainer:
          _darkPrimaryVariantColor, // Often a slightly lighter/darker shade of primary
      secondary: _darkSecondaryColor,
      secondaryContainer:
          _darkSecondaryVariantColor, // Often a slightly lighter/darker shade of secondary
      surface: _darkSurfaceColor,
      background: _darkBackgroundColor,
      error: _darkErrorColor,
      onPrimary: _darkOnPrimaryColor,
      onSecondary: _darkOnSecondaryColor,
      onSurface: _darkOnSurfaceColor,
      onBackground: _darkOnBackgroundColor,
      onError: _darkOnErrorColor,
    ),
    textTheme: _darkTextTheme,
    appBarTheme: AppBarTheme(
      color: _darkSurfaceColor, // Or _darkBackgroundColor
      elevation: 0,
      iconTheme: const IconThemeData(color: _darkOnSurfaceColor),
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
        color: _darkOnSurfaceColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkSecondaryColor,
        foregroundColor: _darkOnSecondaryColor, // Text color
        textStyle: _darkTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkSecondaryColor,
        textStyle: _darkTextTheme.labelLarge?.copyWith(
          color: _darkSecondaryColor,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkSecondaryColor,
        side: const BorderSide(color: _darkSecondaryColor, width: 1.5),
        textStyle: _darkTextTheme.labelLarge?.copyWith(
          color: _darkSecondaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor.withOpacity(
        0.5,
      ), // Slightly transparent surface
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkOnSurfaceColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _darkSecondaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkErrorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkErrorColor, width: 2.0),
      ),
      labelStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _darkOnSurfaceColor.withOpacity(0.7),
      ),
      hintStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _darkOnSurfaceColor.withOpacity(0.5),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      color: _darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkSecondaryColor,
      foregroundColor: _darkOnSecondaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedItemColor: _darkSecondaryColor,
      unselectedItemColor: _darkOnSurfaceColor.withOpacity(0.6),
      selectedLabelStyle: _darkTextTheme.bodySmall?.copyWith(
        color: _darkSecondaryColor,
      ),
      unselectedLabelStyle: _darkTextTheme.bodySmall?.copyWith(
        color: _darkOnSurfaceColor.withOpacity(0.6),
      ),
      type: BottomNavigationBarType.fixed, // Or .shifting
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceColor.withOpacity(0.8),
      disabledColor: _darkBackgroundColor.withOpacity(0.5),
      selectedColor: _darkSecondaryColor,
      secondarySelectedColor:
          _darkSecondaryColor, // For when checkmark is shown
      padding: const EdgeInsets.all(8.0),
      labelStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _darkOnSurfaceColor,
      ),
      secondaryLabelStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _darkOnSecondaryColor,
      ), // Text color when selected
      brightness: Brightness.dark,
      shape: StadiumBorder(
        side: BorderSide(color: _darkOnSurfaceColor.withOpacity(0.2)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: _darkOnSurfaceColor.withOpacity(0.12),
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: _darkTextTheme.titleLarge,
      contentTextStyle: _darkTextTheme.bodyMedium,
    ),
    // Add other theme properties as needed
  );

  // Prevent instantiation
  AppTheme._();
}
