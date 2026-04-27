import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Auth — skip when using placeholder credentials
  if (!AppConstants.supabaseUrl.contains('your-project')) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init skipped: $e');
    }
  }

  // Firebase (push notifications) — requires firebase_options.dart, skip in dev
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: JeepneyWazeApp(),
    ),
  );
}
