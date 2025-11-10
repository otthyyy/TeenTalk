import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:test/test.dart';

Matcher hasSufficientContrastWith(Color background, {double ratio = 4.5}) {
  return _ColorContrastMatcher(background, ratio);
}

double _relativeLuminance(Color color) {
  double channelTransform(int value) {
    final channel = value / 255.0;
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channelTransform(color.red);
  final g = channelTransform(color.green);
  final b = channelTransform(color.blue);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final luminance1 = _relativeLuminance(a);
  final luminance2 = _relativeLuminance(b);
  final brightest = math.max(luminance1, luminance2);
  final darkest = math.min(luminance1, luminance2);
  return (brightest + 0.05) / (darkest + 0.05);
}

class _ColorContrastMatcher extends Matcher {
  const _ColorContrastMatcher(this.background, this.minimumRatio);

  final Color background;
  final double minimumRatio;

  @override
  Description describe(Description description) {
    return description.add(
      'Color with contrast ratio >= $minimumRatio against background $background',
    );
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! Color) return false;
    final ratio = _contrastRatio(item, background);
    matchState['ratio'] = ratio;
    return ratio >= minimumRatio;
  }

  @override
  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is! Color) {
      return mismatchDescription.add('is not a Color');
    }
    final ratio = matchState['ratio'] as double? ?? _contrastRatio(item, background);
    return mismatchDescription.add('has contrast ratio ${ratio.toStringAsFixed(2)}');
  }
}
