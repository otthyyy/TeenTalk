// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_app/main.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app/services/auth_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AuthService(),
        child: const MyApp(),
      ),
    );

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Auth screen UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AuthService(),
        child: const MyApp(),
      ),
    );

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Look for authentication elements (should be present when not authenticated)
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}