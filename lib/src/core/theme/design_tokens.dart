import 'dart:ui';

import 'package:flutter/material.dart';

/// Brand color constants shared across light and dark palettes.
class BrandColors {
  const BrandColors._();

  static const Color vibrantPurple = Color(0xFF000000);
  static const Color deepPurple = Color(0xFF1A1A1A);
  static const Color lightPurple = Color(0xFF4A4A4A);

  static const Color vibrantPink = Color(0xFFFF6B6B);
  static const Color deepPink = Color(0xFFFF5252);
  static const Color lightPink = Color(0xFFFF8A80);

  static const Color vibrantCyan = Color(0xFF4ECDC4);
  static const Color deepCyan = Color(0xFF45B7AF);
  static const Color lightCyan = Color(0xFF80DEEA);

  static const Color vibrantYellow = Color(0xFFFFE66D);
  static const Color vibrantOrange = Color(0xFFFF9F43);

  static const Color neonGreen = Color(0xFF6BCF7F);
  static const Color limeGreen = Color(0xFF95E1A4);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
}

/// Light/dark specific color system aligned with Material 3 [`ColorScheme`].
class AppColorTokens {
  const AppColorTokens({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.shadowColor,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color shadowColor;

  ColorScheme get colorScheme => brightness == Brightness.dark
      ? ColorScheme.dark(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          tertiary: tertiary,
          onTertiary: onTertiary,
          tertiaryContainer: tertiaryContainer,
          onTertiaryContainer: onTertiaryContainer,
          error: BrandColors.error,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
        )
      : ColorScheme.light(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          tertiary: tertiary,
          onTertiary: onTertiary,
          tertiaryContainer: tertiaryContainer,
          onTertiaryContainer: onTertiaryContainer,
          error: BrandColors.error,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceVariant,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
        );

  LinearGradient get surfaceGradient => brightness == Brightness.dark
      ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BrandColors.vibrantPurple.withOpacity(0.1),
            Colors.transparent,
          ],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BrandColors.vibrantPurple.withOpacity(0.05),
            Colors.transparent,
          ],
        );

  Color get focusColor =>
      primary.withOpacity(brightness == Brightness.dark ? 0.18 : 0.2);
  Color get hoverColor =>
      primary.withOpacity(brightness == Brightness.dark ? 0.12 : 0.08);

  static const AppColorTokens light = AppColorTokens(
    brightness: Brightness.light,
    primary: BrandColors.vibrantPurple,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.lightPurple,
    onPrimaryContainer: BrandColors.deepPurple,
    secondary: BrandColors.vibrantPink,
    onSecondary: Colors.white,
    secondaryContainer: BrandColors.lightPink,
    onSecondaryContainer: BrandColors.deepPink,
    tertiary: BrandColors.vibrantCyan,
    onTertiary: Colors.white,
    tertiaryContainer: BrandColors.lightCyan,
    onTertiaryContainer: BrandColors.deepCyan,
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF1A1A1A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF757575),
    outline: Color(0xFFE0E0E0),
    shadowColor: Colors.black,
  );

  static const AppColorTokens dark = AppColorTokens(
    brightness: Brightness.dark,
    primary: BrandColors.vibrantPurple,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.deepPurple,
    onPrimaryContainer: BrandColors.lightPurple,
    secondary: BrandColors.vibrantPink,
    onSecondary: Colors.white,
    secondaryContainer: BrandColors.deepPink,
    onSecondaryContainer: BrandColors.lightPink,
    tertiary: BrandColors.vibrantCyan,
    onTertiary: Colors.white,
    tertiaryContainer: BrandColors.deepCyan,
    onTertiaryContainer: BrandColors.lightCyan,
    background: Color(0xFF000000),
    onBackground: Color(0xFFF5F5F5),
    surface: Color(0xFF0A0A0A),
    onSurface: Color(0xFFF5F5F5),
    surfaceVariant: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFF9E9E9E),
    outline: Color(0xFF2A2A2A),
    shadowColor: Colors.black,
  );

  static AppColorTokens of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

extension AppColorTokensBuildContext on BuildContext {
  AppColorTokens get tokens => AppColorTokens.of(Theme.of(this).brightness);
}

class AppGradients {
  const AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.vibrantPurple, BrandColors.vibrantPink],
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.vibrantCyan, BrandColors.deepCyan],
  );

  static const LinearGradient tertiary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.vibrantYellow, BrandColors.vibrantOrange],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      BrandColors.lightPurple,
      BrandColors.lightPink,
      BrandColors.lightCyan
    ],
  );
}

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
  static const double fourXl = 64.0;

  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsets only(
          {double left = 0,
          double top = 0,
          double right = 0,
          double bottom = 0}) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

class AppRadii {
  const AppRadii._();

  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double base = 20.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double xxl = 36.0;
  static const double full = 9999.0;

  static BorderRadius border(double radius) => BorderRadius.circular(radius);
}

class AppIconSizes {
  const AppIconSizes._();

  static const double sm = 16.0;
  static const double md = 20.0;
  static const double base = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
}

class AppMotion {
  const AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 600);

  static const Curve ease = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve bounce = Curves.easeOutBack;
  static const Curve snappy = Curves.easeOutExpo;
}

class AppElevation {
  const AppElevation._();

  static List<BoxShadow> level1(Color shadow) => [
        BoxShadow(
          color: shadow.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> level2(Color shadow) => [
        BoxShadow(
          color: shadow.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> level3(Color shadow) => [
        BoxShadow(
          color: shadow.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> level4(Color shadow) => [
        BoxShadow(
          color: shadow.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> level5(Color shadow) => [
        BoxShadow(
          color: shadow.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> colored(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}

class AppTypography {
  const AppTypography._();

  static const TextTheme base = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.75,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  );

  static TextTheme scale(TextScaler scaler) {
    TextStyle? scaleStyle(TextStyle? style) {
      if (style == null || style.fontSize == null) {
        return style;
      }
      return style.copyWith(fontSize: scaler.scale(style.fontSize!));
    }

    return TextTheme(
      displayLarge: scaleStyle(base.displayLarge),
      displayMedium: scaleStyle(base.displayMedium),
      displaySmall: scaleStyle(base.displaySmall),
      headlineLarge: scaleStyle(base.headlineLarge),
      headlineMedium: scaleStyle(base.headlineMedium),
      headlineSmall: scaleStyle(base.headlineSmall),
      titleLarge: scaleStyle(base.titleLarge),
      titleMedium: scaleStyle(base.titleMedium),
      titleSmall: scaleStyle(base.titleSmall),
      bodyLarge: scaleStyle(base.bodyLarge),
      bodyMedium: scaleStyle(base.bodyMedium),
      bodySmall: scaleStyle(base.bodySmall),
      labelLarge: scaleStyle(base.labelLarge),
      labelMedium: scaleStyle(base.labelMedium),
      labelSmall: scaleStyle(base.labelSmall),
    );
  }
}

class ResponsiveTypography {
  const ResponsiveTypography._();

  static TextTheme of(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return AppTypography.scale(scaler);
  }

  static TextTheme scale(TextScaler scaler) => AppTypography.scale(scaler);
}

@Deprecated(
    'Use AppColorTokens, AppSpacing, AppRadii, etc. instead for better type safety')
class DesignTokens {
  const DesignTokens._();

  static const Color vibrantPurple = BrandColors.vibrantPurple;
  static const Color deepPurple = BrandColors.deepPurple;
  static const Color lightPurple = BrandColors.lightPurple;
  static const Color vibrantPink = BrandColors.vibrantPink;
  static const Color deepPink = BrandColors.deepPink;
  static const Color lightPink = BrandColors.lightPink;
  static const Color vibrantCyan = BrandColors.vibrantCyan;
  static const Color deepCyan = BrandColors.deepCyan;
  static const Color lightCyan = BrandColors.lightCyan;
  static const Color vibrantYellow = BrandColors.vibrantYellow;
  static const Color vibrantOrange = BrandColors.vibrantOrange;
  static const Color neonGreen = BrandColors.neonGreen;
  static const Color limeGreen = BrandColors.limeGreen;

  static Color get lightBackground => AppColorTokens.light.background;
  static Color get lightSurface => AppColorTokens.light.surface;
  static Color get lightSurfaceVariant => AppColorTokens.light.surfaceVariant;
  static Color get lightOutline => AppColorTokens.light.outline;
  static Color get lightOnPrimary => AppColorTokens.light.onPrimary;
  static Color get lightOnSecondary => AppColorTokens.light.onSecondary;
  static Color get lightOnBackground => AppColorTokens.light.onBackground;
  static Color get lightOnSurface => AppColorTokens.light.onSurface;
  static Color get lightOnSurfaceVariant =>
      AppColorTokens.light.onSurfaceVariant;

  static Color get darkBackground => AppColorTokens.dark.background;
  static Color get darkSurface => AppColorTokens.dark.surface;
  static Color get darkSurfaceVariant => AppColorTokens.dark.surfaceVariant;
  static Color get darkOutline => AppColorTokens.dark.outline;
  static Color get darkOnPrimary => AppColorTokens.dark.onPrimary;
  static Color get darkOnSecondary => AppColorTokens.dark.onSecondary;
  static Color get darkOnBackground => AppColorTokens.dark.onBackground;
  static Color get darkOnSurface => AppColorTokens.dark.onSurface;
  static Color get darkOnSurfaceVariant => AppColorTokens.dark.onSurfaceVariant;

  static const Color errorColor = BrandColors.error;
  static const Color successColor = BrandColors.success;
  static const Color warningColor = BrandColors.warning;

  static const LinearGradient primaryGradient = AppGradients.primary;
  static const LinearGradient secondaryGradient = AppGradients.secondary;
  static const LinearGradient tertiaryGradient = AppGradients.tertiary;
  static const LinearGradient accentGradient = AppGradients.accent;
  static LinearGradient get surfaceGradient =>
      AppColorTokens.light.surfaceGradient;
  static LinearGradient get darkSurfaceGradient =>
      AppColorTokens.dark.surfaceGradient;

  static const double spacing2xs = AppSpacing.xxs;
  static const double spacingXs = AppSpacing.xs;
  static const double spacingSm = AppSpacing.sm;
  static const double spacingMd = AppSpacing.md;
  static const double spacing = AppSpacing.base;
  static const double spacingLg = AppSpacing.lg;
  static const double spacingXl = AppSpacing.xl;
  static const double spacing2xl = AppSpacing.xxl;
  static const double spacing3xl = AppSpacing.xxxl;
  static const double spacing4xl = AppSpacing.fourXl;

  static const double radiusXs = AppRadii.xs;
  static const double radiusSm = AppRadii.sm;
  static const double radiusMd = AppRadii.md;
  static const double radius = AppRadii.base;
  static const double radiusLg = AppRadii.lg;
  static const double radiusXl = AppRadii.xl;
  static const double radius2xl = AppRadii.xxl;
  static const double radiusFull = AppRadii.full;

  static const double iconSizeSm = AppIconSizes.sm;
  static const double iconSizeMd = AppIconSizes.md;
  static const double iconSize = AppIconSizes.base;
  static const double iconSizeLg = AppIconSizes.lg;
  static const double iconSizeXl = AppIconSizes.xl;

  static const Duration durationInstant = AppMotion.instant;
  static const Duration durationFast = AppMotion.fast;
  static const Duration duration = AppMotion.base;
  static const Duration durationSlow = AppMotion.slow;
  static const Duration durationSlower = AppMotion.slower;

  static const Curve curveDefault = AppMotion.ease;
  static const Curve curveEmphasized = AppMotion.emphasized;
  static const Curve curveDecelerate = AppMotion.decelerate;
  static const Curve curveAccelerate = AppMotion.accelerate;
  static const Curve curveBounce = AppMotion.bounce;
  static const Curve curveSnappy = AppMotion.snappy;

  static BoxShadow get shadowSm => AppElevation.level1(Colors.black).first;
  static BoxShadow get shadow => AppElevation.level2(Colors.black).first;
  static BoxShadow get shadowMd => AppElevation.level3(Colors.black).first;
  static BoxShadow get shadowLg => AppElevation.level4(Colors.black).first;
  static BoxShadow get shadowXl => AppElevation.level5(Colors.black).first;
  static BoxShadow coloredShadow(Color color) =>
      AppElevation.colored(color).first;
  static BoxShadow glowShadow(Color color) => AppElevation.glow(color).first;
}
