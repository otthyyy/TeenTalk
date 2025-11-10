import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/color_contrast_matcher.dart';

void main() {
  group('Color Contrast Tests', () {
    test('primary color has sufficient contrast with white', () {
      const primaryColor = Color(0xFF9333EA);
      const backgroundColor = Colors.white;

      expect(
        primaryColor,
        hasSufficientContrastWith(backgroundColor, ratio: 4.5),
        reason: 'Primary color must have at least 4.5:1 contrast with white background',
      );
    });

    test('secondary color has sufficient contrast with white', () {
      const secondaryColor = Color(0xFFEC4899);
      const backgroundColor = Colors.white;

      expect(
        secondaryColor,
        hasSufficientContrastWith(backgroundColor, ratio: 4.5),
        reason: 'Secondary color must have at least 4.5:1 contrast with white background',
      );
    });

    test('text on dark background has sufficient contrast', () {
      const textColor = Colors.white;
      const backgroundColor = Colors.black;

      expect(
        textColor,
        hasSufficientContrastWith(backgroundColor, ratio: 7.0),
        reason: 'White text on black background should have high contrast',
      );
    });

    test('error color has sufficient contrast with white', () {
      const errorColor = Color(0xFFEF4444);
      const backgroundColor = Colors.white;

      expect(
        errorColor,
        hasSufficientContrastWith(backgroundColor, ratio: 4.5),
        reason: 'Error color must be visible on white background',
      );
    });

    test('light grey text fails contrast check on white', () {
      const lightGrey = Color(0xFFCCCCCC);
      const backgroundColor = Colors.white;

      expect(
        lightGrey,
        isNot(hasSufficientContrastWith(backgroundColor, ratio: 4.5)),
        reason: 'Light grey on white should fail WCAG AA contrast requirements',
      );
    });

    test('color contrast matcher provides helpful error message', () {
      const poorContrast = Color(0xFFDDDDDD);
      const backgroundColor = Colors.white;

      try {
        expect(
          poorContrast,
          hasSufficientContrastWith(backgroundColor, ratio: 4.5),
        );
        fail('Expected test to fail');
      } catch (e) {
        expect(e.toString(), contains('contrast ratio'));
      }
    });
  });

  group('Theme Color Contrast', () {
    testWidgets('ThemeData colors have sufficient contrast', (tester) async {
      final theme = ThemeData.light();

      expect(
        theme.colorScheme.primary,
        hasSufficientContrastWith(theme.colorScheme.background, ratio: 3.0),
        reason: 'Primary color must be visible on background',
      );
    });

    testWidgets('Dark theme colors have sufficient contrast', (tester) async {
      final theme = ThemeData.dark();

      expect(
        theme.colorScheme.onBackground,
        hasSufficientContrastWith(theme.colorScheme.background, ratio: 4.5),
        reason: 'Text color must be readable on dark background',
      );
    });
  });
}
