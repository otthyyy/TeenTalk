import 'dart:ui';

import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppDecorations {
  const AppDecorations._();

  static BoxDecoration gradientBackground({
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? DesignTokens.primaryGradient,
    );
  }

  static BoxDecoration surfaceGradientBackground({
    bool isDark = false,
  }) {
    return BoxDecoration(
      gradient: isDark
          ? DesignTokens.darkSurfaceGradient
          : DesignTokens.surfaceGradient,
    );
  }

  static BoxDecoration glass({
    bool isDark = false,
    double borderRadius = DesignTokens.radiusLg,
    double opacity = 0.85,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: gradient ?? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDark ? 0.08 : 0.16),
          Colors.white.withOpacity(isDark ? 0.04 : 0.08),
        ],
      ),
      border: Border.all(
        color: Colors.white.withOpacity(isDark ? 0.12 : 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
          blurRadius: 24,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
      backgroundBlendMode: BlendMode.srcOver,
    );
  }

  static Widget glassContainer({
    required Widget child,
    bool isDark = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double borderRadius = DesignTokens.radiusXl,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: AppDecorations.glass(isDark: isDark, borderRadius: borderRadius),
          child: child,
        ),
      ),
    );
  }

  static Widget gradientCard({
    required Widget child,
    Gradient? gradient,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    List<BoxShadow>? shadows,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? DesignTokens.accentGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: shadows ?? [DesignTokens.coloredShadow(DesignTokens.lightPurple)],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  static Widget glowCard({
    required Widget child,
    Color color = DesignTokens.vibrantPurple,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [DesignTokens.glowShadow(color)],
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
              gradient: gradient ?? DesignTokens.primaryGradient,
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
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
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
