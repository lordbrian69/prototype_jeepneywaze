import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(JWColors.black);

    return base.copyWith(
      scaffoldBackgroundColor: JWColors.white,
      colorScheme: const ColorScheme.light(
        primary: JWColors.black,
        onPrimary: JWColors.white,
        secondary: JWColors.jeepneyYellow,
        onSecondary: JWColors.black,
        surface: JWColors.white,
        onSurface: JWColors.black,
        error: JWColors.siksikanRed,
        onError: JWColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: JWColors.white,
        foregroundColor: JWColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: JWColors.black, size: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JWColors.black,
          foregroundColor: JWColors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JWRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: JWColors.black,
          foregroundColor: JWColors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JWRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JWColors.black,
          side: const BorderSide(color: JWColors.black, width: 1),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JWRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JWColors.black,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JWColors.white,
        foregroundColor: JWColors.black,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JWColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: JWSpacing.lg,
          vertical: JWSpacing.lg,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: JWColors.mutedGray,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: JWColors.bodyGray,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JWRadius.card),
          borderSide: const BorderSide(color: JWColors.black, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JWRadius.card),
          borderSide: const BorderSide(color: JWColors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JWRadius.card),
          borderSide: const BorderSide(color: JWColors.black, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: JWColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JWRadius.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: JWColors.chipGray,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: JWColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(JWRadius.sheet),
            topRight: Radius.circular(JWRadius.sheet),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? JWColors.white : JWColors.white),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? JWColors.black : JWColors.mutedGray),
      ),
    );
  }

  static ThemeData get dark => light; // Phase 1: light only per design spec

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      // Display — splash, hero
      displayLarge: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.20,
        color: color,
      ),
      // Heading 1 — screen titles
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      ),
      // Heading 2 — card titles, ETAs
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        color: color,
      ),
      // Heading 3 — sub-section, modal titles
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      // Body Large — primary body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: color,
      ),
      // Body Regular — descriptions, metadata
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: JWColors.bodyGray,
      ),
      // Caption
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: JWColors.bodyGray,
      ),
      // Label — buttons, chips, nav
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      // Micro — badge counts, pin labels
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.60,
        color: color,
      ),
    );
  }
}
