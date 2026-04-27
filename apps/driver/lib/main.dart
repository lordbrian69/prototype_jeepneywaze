import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: JeepneyWazeDriverApp()),
  );
}

class JeepneyWazeDriverApp extends StatelessWidget {
  const JeepneyWazeDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeepneyWaze Driver',
      debugShowCheckedModeBanner: false,
      theme: DriverTheme.light,
      home: const HomeScreen(),
    );
  }
}
