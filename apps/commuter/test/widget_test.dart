// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeepneywaze_commuter/features/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initial phone step (OTP not sent yet).
    expect(find.text('Mag-sign in'), findsOneWidget);
    expect(find.text('Humingi ng Code'), findsOneWidget);
  });
}
