import 'package:flutter/material.dart';

/// Design-system driven theme.
/// Tokens: pastel accents, dark controls, heavy typography, layered shadows.
class AppTheme {
  // ── Backgrounds ──
  static const appBackground = Color(0xFFE8E8EE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF5F5F7);

  // ── Foreground ──
  static const fgPrimary = Color(0xFF0A0A0A);
  static const fgSecondary = Color(0xFF5A5A5A);
  static const fgTertiary = Color(0xFF9A9A9A);

  // ── Controls ──
  static const controlDark = Color(0xFF1A1A1A);

  // ── Accent palette ──
  static const accentBlue = Color(0xFFC8E6F0);
  static const accentGreen = Color(0xFFC8ECD8);
  static const accentYellow = Color(0xFFF5ECC8);
  static const accentPurple = Color(0xFFDDD8F0);

  // ── Border radii ──
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusFull = 9999;

  // ── Shadows ──
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
  static List<BoxShadow> get shadowFloat => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: controlDark,
        secondary: accentBlue,
        tertiary: accentGreen,
        error: Color(0xFFD32F2F),
        surface: surface,
      ),
      scaffoldBackgroundColor: appBackground,

      // ── App bar: flat, no elevation, blends with background ──
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: fgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: fgPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: fgPrimary, size: 24),
      ),

      // ── Elevated button: dark pill ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: controlDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // ── Outlined button: pill with dark border ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: controlDark,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: controlDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // ── Card: white, rounded, subtle shadow ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── FAB: dark pill ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: controlDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: fgPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Typography ──
      textTheme: const TextTheme(
        // Hero heading — 40/900
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: fgPrimary,
          letterSpacing: -1.0,
          height: 1.1,
        ),
        // Section heading — 32/800
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: fgPrimary,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        // Sub-heading — 22/700
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: fgPrimary,
          letterSpacing: -0.4,
          height: 1.2,
        ),
        // Title — 18/700
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: fgPrimary,
          letterSpacing: -0.3,
        ),
        // Card title — 16/600
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: fgPrimary,
          letterSpacing: -0.2,
        ),
        // Body — 15/400
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: fgSecondary,
        ),
        // Secondary body — 14/400
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: fgTertiary,
        ),
        // Label — 13/500
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: fgSecondary,
          letterSpacing: 0.1,
        ),
        // Caption — 11/400
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: fgTertiary,
          letterSpacing: 0.2,
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 24,
      ),
    );
  }
}
