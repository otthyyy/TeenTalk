import 'package:flutter/material.dart';

/// Metrics for the floating glass bottom navigation that lives in [MainNavigationShell].
class BottomNavMetrics {
  BottomNavMetrics._();

  static const double _bottomNavigationBarHeight = kBottomNavigationBarHeight;
  static const double _glassVerticalPadding = 12.0;
  static const double _floatingBottomSpacing = 16.0;

  /// Height of the material navigation bar and its glass container.
  static const double barHeight =
      _bottomNavigationBarHeight + _glassVerticalPadding; // 56 + 12 = 68

  /// Total vertical footprint of the nav (including its floating offset) without safe-area insets.
  static const double height = barHeight + _floatingBottomSpacing; // 68 + 16 = 84

  /// The nav height plus the current device safe-area inset.
  static double safeAreaAwareHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + height;
  }

  /// Bottom padding to apply to FABs that use [FloatingActionButtonLocation.centerFloat].
  ///
  /// The Scaffold already provides 16px of margin (plus any safe-area inset).
  /// This value offsets the FAB above the nav and preserves a consistent gap.
  static double fabPadding({double margin = 16.0}) {
    return height + margin - 16.0;
  }

  /// Convenience helper for scroll views or bottom spacers that need to sit above the nav.
  static double scrollBottomPadding(BuildContext context, {double extra = 0}) {
    return safeAreaAwareHeight(context) + extra;
  }

  /// Bottom-only safe-area padding for children rendered inside the shell when they
  /// are not already wrapped in a Scaffold.
  static EdgeInsets childSafePadding(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    if (safeBottom == 0) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.only(bottom: safeBottom);
  }
}

extension BottomNavContext on BuildContext {
  double get bottomNavHeightWithSafeArea => BottomNavMetrics.safeAreaAwareHeight(this);
  double scrollPaddingAboveBottomNav({double extra = 0}) =>
      BottomNavMetrics.scrollBottomPadding(this, extra: extra);
}
