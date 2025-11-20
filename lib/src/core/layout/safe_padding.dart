import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class SafeAreaSpacing {
  const SafeAreaSpacing._();

  static EdgeInsets of(
    BuildContext context, {
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    double minimum = 0.0,
    EdgeInsets? additional,
  }) {
    final mediaPadding = MediaQuery.paddingOf(context);
    final safeInsets = EdgeInsets.only(
      left: left ? mediaPadding.left : 0,
      top: top ? mediaPadding.top : 0,
      right: right ? mediaPadding.right : 0,
      bottom: bottom ? mediaPadding.bottom : 0,
    );

    final withMinimum = EdgeInsets.fromLTRB(
      safeInsets.left < minimum && left ? minimum : safeInsets.left,
      safeInsets.top < minimum && top ? minimum : safeInsets.top,
      safeInsets.right < minimum && right ? minimum : safeInsets.right,
      safeInsets.bottom < minimum && bottom ? minimum : safeInsets.bottom,
    );

    if (additional != null) {
      return EdgeInsets.fromLTRB(
        withMinimum.left + additional.left,
        withMinimum.top + additional.top,
        withMinimum.right + additional.right,
        withMinimum.bottom + additional.bottom,
      );
    }

    return withMinimum;
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
    bool applyHorizontalSafeArea = true,
    bool applyVerticalSafeArea = true,
  }) {
    final mediaPadding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      (applyHorizontalSafeArea ? mediaPadding.left : 0) + horizontal,
      (applyVerticalSafeArea ? mediaPadding.top : 0) + vertical,
      (applyHorizontalSafeArea ? mediaPadding.right : 0) + horizontal,
      (applyVerticalSafeArea ? mediaPadding.bottom : 0) + vertical,
    );
  }

  static EdgeInsets all(
    BuildContext context,
    double value, {
    bool includeSafeArea = true,
  }) {
    if (!includeSafeArea) {
      return EdgeInsets.all(value);
    }
    final mediaPadding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      mediaPadding.left + value,
      mediaPadding.top + value,
      mediaPadding.right + value,
      mediaPadding.bottom + value,
    );
  }

  static EdgeInsets only(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    bool includeSafeArea = true,
  }) {
    if (!includeSafeArea) {
      return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
    }
    final mediaPadding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      mediaPadding.left + left,
      mediaPadding.top + top,
      mediaPadding.right + right,
      mediaPadding.bottom + bottom,
    );
  }

  static EdgeInsets horizontal(
    BuildContext context,
    double value, {
    bool includeSafeArea = true,
  }) {
    if (!includeSafeArea) {
      return EdgeInsets.symmetric(horizontal: value);
    }
    final mediaPadding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      mediaPadding.left + value,
      0,
      mediaPadding.right + value,
      0,
    );
  }

  static EdgeInsets vertical(
    BuildContext context,
    double value, {
    bool includeSafeArea = true,
  }) {
    if (!includeSafeArea) {
      return EdgeInsets.symmetric(vertical: value);
    }
    final mediaPadding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      0,
      mediaPadding.top + value,
      0,
      mediaPadding.bottom + value,
    );
  }

  static EdgeInsets withContent({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    double contentHorizontal = AppSpacing.base,
    double contentVertical = AppSpacing.base,
  }) {
    return EdgeInsets.only(
      left: left ? contentHorizontal : 0,
      top: top ? contentVertical : 0,
      right: right ? contentHorizontal : 0,
      bottom: bottom ? contentVertical : 0,
    );
  }
}

extension SafeAreaPaddingContext on BuildContext {
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  double get safeAreaTop => safeAreaPadding.top;
  double get safeAreaBottom => safeAreaPadding.bottom;
  double get safeAreaLeft => safeAreaPadding.left;
  double get safeAreaRight => safeAreaPadding.right;

  EdgeInsets safeInsets({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    double minimum = 0.0,
  }) {
    return SafeAreaSpacing.of(
      this,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
    );
  }

  EdgeInsets safeWithContent({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    double contentHorizontal = AppSpacing.base,
    double contentVertical = AppSpacing.base,
  }) {
    final safe = safeInsets(left: left, top: top, right: right, bottom: bottom);
    return EdgeInsets.fromLTRB(
      safe.left + (left ? contentHorizontal : 0),
      safe.top + (top ? contentVertical : 0),
      safe.right + (right ? contentHorizontal : 0),
      safe.bottom + (bottom ? contentVertical : 0),
    );
  }
}
