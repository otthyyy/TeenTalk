import 'dart:ui';

import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppDecorations {
  const AppDecorations._();

  static BoxDecoration gradientBackground({
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppGradients.primary,
    );
  }

  static BoxDecoration surfaceGradientBackground({
    bool isDark = false,
  }) {
    final tokens = isDark ? AppColorTokens.dark : AppColorTokens.light;
    return BoxDecoration(
      gradient: tokens.surfaceGradient,
    );
  }

  static BoxDecoration glass({
    bool isDark = false,
    double borderRadius = AppRadii.lg,
    double opacity = 0.85,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: gradient ??
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? Colors.black : Colors.white)
                  .withOpacity(isDark ? 0.6 : 0.16),
              (isDark ? Colors.black : Colors.white)
                  .withOpacity(isDark ? 0.4 : 0.08),
            ],
          ),
      border: Border.all(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.2),
        width: 1.5,
      ),
      boxShadow: AppElevation.level4(Colors.black),
      backgroundBlendMode: BlendMode.srcOver,
    );
  }

  static Widget glassContainer({
    required Widget child,
    bool isDark = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.base),
    double borderRadius = AppRadii.xl,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration:
              AppDecorations.glass(isDark: isDark, borderRadius: borderRadius),
          child: child,
        ),
      ),
    );
  }

  static Widget gradientCard({
    required Widget child,
    Gradient? gradient,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
    List<BoxShadow>? shadows,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.accent,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.lg),
        boxShadow: shadows ?? AppElevation.colored(BrandColors.lightPurple),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  static Widget glowCard({
    required Widget child,
    Color color = BrandColors.vibrantPurple,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.lg),
        boxShadow: AppElevation.glow(color),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  static Widget heroBackground({
    required Widget child,
    Gradient? gradient,
    double heightFactor = 0.7,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient ?? AppGradients.primary,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.xxxl),
                    topRight: Radius.circular(AppSpacing.xxxl),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
