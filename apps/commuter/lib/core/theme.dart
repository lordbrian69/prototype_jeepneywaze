import 'package:flutter/material.dart';

class AppTheme {
  static const _orange = Color(0xFFE8401C);
  static const _darkBg = Color(0xFF1A1A1A);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _orange,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: _darkBg,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
        ),
        fontFamily: 'JeepneyWaze',
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _orange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _darkBg,
        fontFamily: 'JeepneyWaze',
      );
}
