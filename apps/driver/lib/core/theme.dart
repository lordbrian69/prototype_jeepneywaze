import 'package:flutter/material.dart';

class DriverTheme {
  static const _yellow = Color(0xFFFFCC00);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _yellow,
          brightness: Brightness.light,
        ),
      );
}
