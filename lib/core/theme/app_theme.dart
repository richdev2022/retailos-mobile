import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RetailOS design system.
///
/// Color palette: deep emerald primary (retail/finance trust), warm amber
/// accent, neutral surfaces. Modern minimal aesthetic with subtle shadows
/// and rounded corners.
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color _primaryLight = Color(0xFF0B7A4D); // deep emerald
  static const Color _primaryDark = Color(0xFF1FA170);
  static const Color _secondaryLight = Color(0xFFF59E0B); // amber
  static const Color _secondaryDark = Color(0xFFFBBF24);
  static const Color _dangerLight = Color(0xFFDC2626);
  static const Color _successLight = Color(0xFF16A34A);
  static const Color _warningLight = Color(0xFFEAB308);
  static const Color _infoLight = Color(0xFF0284C7);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryLight,
      brightness: Brightness.light,
      primary: _primaryLight,
      secondary: _secondaryLight,
      error: _dangerLight,
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1A1F2E),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      secondary: _secondaryDark,
      error: const Color(0xFFF87171),
      surface: const Color(0xFF0F1419),
      onSurface: const Color(0xFFE6EAF2),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseText = GoogleFonts.inter();
    final headingText = GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0A0E13) : const Color(0xFFF7F8FA),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: headingText.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: scheme.onSurface, letterSpacing: -0.5),
        displayMedium: headingText.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: scheme.onSurface, letterSpacing: -0.3),
        headlineMedium: headingText.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onSurface),
        titleLarge: headingText.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface),
        titleMedium: headingText.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface),
        bodyLarge: baseText.copyWith(fontSize: 16, color: scheme.onSurface),
        bodyMedium: baseText.copyWith(fontSize: 14, color: scheme.onSurface),
        bodySmall: baseText.copyWith(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: headingText.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF1F2630) : const Color(0xFFEAECF0),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF151B23) : const Color(0xFFF1F3F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: headingText.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline, width: 1),
          textStyle: headingText.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: scheme.primary,
          textStyle: headingText.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1A2028) : const Color(0xFFF1F5F9),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF1F2630) : const Color(0xFFEAECF0),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1F2630) : const Color(0xFF1A1F2E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Semantic colors (for status indicators)
  static Color get danger => _dangerLight;
  static Color get success => _successLight;
  static Color get warning => _warningLight;
  static Color get info => _infoLight;
}
