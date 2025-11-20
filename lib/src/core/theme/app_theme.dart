import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _buildTheme(AppColorTokens.light);
  static ThemeData get darkTheme => _buildTheme(AppColorTokens.dark);

  static ThemeData _buildTheme(AppColorTokens colors) {
    final colorScheme = colors.colorScheme;
    final textTheme = AppTypography.base;
    final isDark = colors.brightness == Brightness.dark;

    Color subtleOnSurface(double opacity) => colors.onSurface.withOpacity(opacity);

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      focusColor: colors.focusColor,
      hoverColor: colors.hoverColor,
      splashColor: colors.primary.withOpacity(0.12),
      highlightColor: colors.primary.withOpacity(0.08),
      dividerColor: colors.outline,
      shadowColor: colors.shadowColor.withOpacity(isDark ? 0.6 : 0.12),
      textTheme: textTheme,
      typography: Typography.material2021(),
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: AppIconSizes.base,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface.withOpacity(0.95),
        foregroundColor: colors.onBackground,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.onBackground,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: colors.onBackground,
          size: AppIconSizes.base,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shadowColor: colors.shadowColor.withOpacity(isDark ? 0.06 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: colors.outline.withOpacity(isDark ? 0.35 : 0.5),
            width: 1,
          ),
        ),
        margin: AppSpacing.all(AppSpacing.sm),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: isDark ? BrandColors.deepPurple : BrandColors.lightPurple,
        secondarySelectedColor: isDark ? BrandColors.deepPink : BrandColors.lightPink,
        disabledColor: colors.surfaceVariant.withOpacity(0.6),
        padding: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        labelStyle: textTheme.labelLarge?.copyWith(color: colors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: BrandColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: BrandColors.error, width: 2),
        ),
        contentPadding: AppSpacing.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          animationDuration: AppMotion.fast,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onPrimary.withOpacity(0.16);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onPrimary.withOpacity(0.08);
            }
            return null;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: AppSpacing.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.base),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface.withOpacity(0.95),
        selectedItemColor: isDark ? BrandColors.lightPurple : colorScheme.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        selectedIconTheme: IconThemeData(
          size: AppIconSizes.lg,
          color: isDark ? BrandColors.lightPurple : colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          size: AppIconSizes.base,
          color: colors.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface.withOpacity(0.95),
        indicatorColor: (isDark ? BrandColors.deepPurple : BrandColors.lightPurple).withOpacity(0.2),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            );
          }
          return textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: AppIconSizes.lg,
              color: isDark ? BrandColors.lightPurple : colorScheme.primary,
            );
          }
          return IconThemeData(
            size: AppIconSizes.base,
            color: colors.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.surface,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        elevation: 6,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        dense: false,
        contentPadding: AppSpacing.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.onSurface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: colors.surface),
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(milliseconds: 2500),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colors.surfaceVariant,
        circularTrackColor: colors.surfaceVariant,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return subtleOnSurface(0.5);
          }
          return subtleOnSurface(0.25);
        }),
        radius: Radius.circular(AppRadii.xl),
        thickness: WidgetStateProperty.all(6),
        interactive: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[
        _AppShadowExtension(colors),
      ],
    );
  }
}

class _AppShadowExtension extends ThemeExtension<_AppShadowExtension> {
  const _AppShadowExtension(this.colors);

  final AppColorTokens colors;

  List<BoxShadow> get level1 => AppElevation.level1(colors.shadowColor);
  List<BoxShadow> get level2 => AppElevation.level2(colors.shadowColor);
  List<BoxShadow> get level3 => AppElevation.level3(colors.shadowColor);
  List<BoxShadow> get level4 => AppElevation.level4(colors.shadowColor);
  List<BoxShadow> get level5 => AppElevation.level5(colors.shadowColor);
  List<BoxShadow> colored(Color color) => AppElevation.colored(color);
  List<BoxShadow> glow(Color color) => AppElevation.glow(color);

  @override
  _AppShadowExtension copyWith({AppColorTokens? colors}) {
    return _AppShadowExtension(colors ?? this.colors);
  }

  @override
  _AppShadowExtension lerp(ThemeExtension<_AppShadowExtension>? other, double t) {
    if (other is! _AppShadowExtension) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
