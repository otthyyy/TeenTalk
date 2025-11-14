import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:teen_talk_app/src/core/theme/app_theme.dart';
import 'package:teen_talk_app/src/core/theme/design_tokens.dart';
import 'package:teen_talk_app/src/core/theme/decorations.dart';

void main() {
  group('App theme golden tests', () {
    testGoldens('Light theme component showcase', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Light components',
          _ThemeShowcase(
            themeData: AppTheme.lightTheme,
            isDark: false,
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(420, 880),
      );

      await screenMatchesGolden(tester, 'theme_components_light');
    });

    testGoldens('Dark theme component showcase', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Dark components',
          _ThemeShowcase(
            themeData: AppTheme.darkTheme,
            isDark: true,
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(420, 880),
      );

      await screenMatchesGolden(tester, 'theme_components_dark');
    });

    testGoldens('Bottom navigation styles', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Bottom nav light',
          _BottomNavPreview(themeData: AppTheme.lightTheme),
        )
        ..addScenario(
          'Bottom nav dark',
          _BottomNavPreview(themeData: AppTheme.darkTheme),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(420, 360),
      );

      await screenMatchesGolden(tester, 'theme_bottom_navigation_styles');
    });
  });

  group('Color contrast compliance', () {
    test('Light theme onPrimary contrast', () {
      final contrast = _contrastRatio(
        DesignTokens.vibrantPurple,
        DesignTokens.lightOnPrimary,
      );
      expect(contrast, greaterThan(4.5));
    });

    test('Dark theme onPrimary contrast', () {
      final contrast = _contrastRatio(
        DesignTokens.vibrantPurple,
        DesignTokens.darkOnPrimary,
      );
      expect(contrast, greaterThan(4.5));
    });

    test('Light theme body contrast', () {
      final contrast = _contrastRatio(
        DesignTokens.lightBackground,
        DesignTokens.lightOnBackground,
      );
      expect(contrast, greaterThan(4.5));
    });

    test('Dark theme body contrast', () {
      final contrast = _contrastRatio(
        DesignTokens.darkBackground,
        DesignTokens.darkOnBackground,
      );
      expect(contrast, greaterThan(4.5));
    });
  });
}

class _ThemeShowcase extends StatelessWidget {
  const _ThemeShowcase({
    required this.themeData,
    required this.isDark,
  });

  final ThemeData themeData;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: AppDecorations.surfaceGradientBackground(isDark: isDark),
          child: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Display Large', style: textTheme.displayLarge),
                    const SizedBox(height: DesignTokens.spacingSm),
                    Text('Headline Medium', style: textTheme.headlineMedium),
                    const SizedBox(height: DesignTokens.spacing),
                    Text('Body Large - TeenTalk brings vibrant conversations to life.', style: textTheme.bodyLarge),
                    const SizedBox(height: DesignTokens.spacingLg),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Primary action'),
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Secondary action'),
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Tertiary action'),
                    ),
                    const SizedBox(height: DesignTokens.spacingLg),
                    const Wrap(
                      spacing: DesignTokens.spacingSm,
                      runSpacing: DesignTokens.spacingSm,
                      children: [
                        Chip(label: Text('Trending')),
                        Chip(label: Text('Self Care')),
                        Chip(label: Text('Music')),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacingLg),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingLg),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Glass card', style: textTheme.titleMedium),
                                  const SizedBox(height: DesignTokens.spacingSm),
                                  Text(
                                    'Use for featured content or highlighted stats.',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacing),
                        Expanded(
                          child: AppDecorations.gradientCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gradient card', style: textTheme.titleMedium?.copyWith(color: DesignTokens.lightOnPrimary)),
                                const SizedBox(height: DesignTokens.spacingSm),
                                Text(
                                  'Showcases brand gradients for energetic vibes.',
                                  style: textTheme.bodyMedium?.copyWith(color: DesignTokens.lightOnPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavPreview extends StatelessWidget {
  const _BottomNavPreview({required this.themeData});

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    final isDark = themeData.brightness == Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: AppDecorations.surfaceGradientBackground(isDark: isDark),
          child: const Center(child: Text('TeenTalk Navigation')),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppDecorations.glassContainer(
            isDark: isDark,
            borderRadius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: 1,
              backgroundColor: Colors.transparent,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  activeIcon: Icon(Icons.message_rounded),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double _contrastRatio(Color color1, Color color2) {
  final lum1 = _relativeLuminance(color1);
  final lum2 = _relativeLuminance(color2);
  final lighter = lum1 > lum2 ? lum1 : lum2;
  final darker = lum1 > lum2 ? lum2 : lum1;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  final r = _toLinear(color.red / 255);
  final g = _toLinear(color.green / 255);
  final b = _toLinear(color.blue / 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _toLinear(double value) {
  if (value <= 0.03928) {
    return value / 12.92;
  }
  return pow((value + 0.055) / 1.055, 2.4).toDouble();
}
