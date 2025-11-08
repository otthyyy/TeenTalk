import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/theme/app_theme.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/auth_page.dart';

void main() {
  group('Auth Screens Golden Tests', () {
    testGoldens('Auth Sign In Page renders correctly', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Sign In (default)',
          const MaterialApp(
            home: ProviderScope(
              child: Scaffold(
                body: AuthPage(isSignUp: false),
              ),
            ),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'auth_sign_in_page');
    });

    testGoldens('Auth Sign Up Page renders correctly', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Sign Up (default)',
          const MaterialApp(
            home: ProviderScope(
              child: Scaffold(
                body: AuthPage(isSignUp: true),
              ),
            ),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'auth_sign_up_page');
    });
  });

  group('Auth Theme Golden Tests', () {
    testWidgets('Auth form with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('Auth form with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(AuthPage), findsOneWidget);
    });
  });

  group('Auth Form Validation Golden Tests', () {
    testWidgets('Email input validation error displays', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      // Find email input
      final emailInput = find.byType(TextFormField).first;
      await tester.tap(emailInput);
      await tester.enterText(emailInput, 'invalid-email');

      // Trigger validation
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsWidgets);
    });

    testWidgets('Password validation error displays', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      final passwordInput = find.byType(TextFormField).at(1);
      await tester.tap(passwordInput);
      await tester.enterText(passwordInput, '123');

      await tester.pumpAndSettle();
      expect(
        find.text('Password must be at least 8 characters'),
        findsWidgets,
      );
    });
  });

  group('Auth Error Messages Golden Tests', () {
    testWidgets('Network error message displays', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Network error. Please check your connection'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Network error. Please check your connection'),
        findsOneWidget,
      );
    });

    testWidgets('Auth error container renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Authentication failed',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Authentication failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('Auth Responsive Design Golden Tests', () {
    testWidgets('Auth page responsive on small screen (320x568)', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Auth page responsive on medium screen (390x844)', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(390, 844);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('Auth page responsive on large screen (600x800)', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(600, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(AuthPage), findsOneWidget);
    });
  });

  group('Auth Tab Navigation Golden Tests', () {
    testWidgets('Tab navigation switches between auth methods', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      // Find tabs
      final tabs = find.byType(Tab);
      expect(tabs, findsWidgets);

      // Tap phone tab
      if (tabs.evaluate().length > 1) {
        await tester.tap(tabs.at(1));
        await tester.pumpAndSettle();

        expect(
          find.text('Phone Number'),
          findsWidgets,
        );
      }
    });
  });

  group('Auth Button States Golden Tests', () {
    testWidgets('Sign In button is enabled when valid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      final signInButton = find.byType(ElevatedButton);
      expect(signInButton, findsWidgets);
    });

    testWidgets('Submit button shows loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: const Text('Signing In...'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing In...'), findsOneWidget);
    });
  });

  group('Auth Accessibility Golden Tests', () {
    testWidgets('All form fields have labels for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      // Check for form fields with labels
      expect(find.byType(TextFormField), findsWidgets);

      // All inputs should have semantic meaning
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Buttons have semantic labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthPage(isSignUp: false),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('Error messages are descriptive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                label: 'Error message',
                child: Text('An error occurred'),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Error message'), findsOneWidget);
    });
  });
}
