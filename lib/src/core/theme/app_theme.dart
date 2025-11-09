import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: DesignTokens.vibrantPurple,
      onPrimary: DesignTokens.lightOnPrimary,
      primaryContainer: DesignTokens.lightPurple,
      onPrimaryContainer: DesignTokens.deepPurple,
      secondary: DesignTokens.vibrantPink,
      onSecondary: DesignTokens.lightOnSecondary,
      secondaryContainer: DesignTokens.lightPink,
      onSecondaryContainer: DesignTokens.deepPink,
      tertiary: DesignTokens.vibrantCyan,
      onTertiary: DesignTokens.lightOnPrimary,
      tertiaryContainer: DesignTokens.lightCyan,
      onTertiaryContainer: DesignTokens.deepCyan,
      error: DesignTokens.errorColor,
      surface: DesignTokens.lightSurface,
      onSurface: DesignTokens.lightOnSurface,
      background: DesignTokens.lightBackground,
      onBackground: DesignTokens.lightOnBackground,
      surfaceVariant: DesignTokens.lightSurfaceVariant,
      onSurfaceVariant: DesignTokens.lightOnSurfaceVariant,
      outline: DesignTokens.lightOutline,
    ),
    scaffoldBackgroundColor: DesignTokens.lightBackground,
    
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.lightSurface.withOpacity(0.95),
      foregroundColor: DesignTokens.lightOnBackground,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: DesignTokens.lightOnBackground,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(
        color: DesignTokens.lightOnBackground,
        size: DesignTokens.iconSize,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.lightSurface.withOpacity(0.95),
      selectedItemColor: DesignTokens.vibrantPurple,
      unselectedItemColor: DesignTokens.lightOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      selectedIconTheme: const IconThemeData(
        size: DesignTokens.iconSizeLg,
      ),
      unselectedIconTheme: const IconThemeData(
        size: DesignTokens.iconSize,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.vibrantPurple,
        foregroundColor: DesignTokens.lightOnPrimary,
        elevation: 4,
        shadowColor: DesignTokens.vibrantPurple.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return DesignTokens.lightOnPrimary.withOpacity(0.2);
          }
          return null;
        }),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DesignTokens.vibrantPurple,
        foregroundColor: DesignTokens.lightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DesignTokens.vibrantPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing,
          vertical: DesignTokens.spacingMd,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.vibrantPurple,
        side: const BorderSide(
          color: DesignTokens.vibrantPurple,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DesignTokens.vibrantPurple,
      foregroundColor: DesignTokens.lightOnPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radius),
      ),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: DesignTokens.lightSurfaceVariant,
      labelStyle: const TextStyle(
        color: DesignTokens.lightOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: DesignTokens.lightPurple,
      secondarySelectedColor: DesignTokens.lightPink,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      side: BorderSide.none,
    ),
    
    cardTheme: CardThemeData(
      color: DesignTokens.lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      margin: const EdgeInsets.all(DesignTokens.spacingSm),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.vibrantPurple,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing,
        vertical: DesignTokens.spacing,
      ),
      hintStyle: const TextStyle(
        color: DesignTokens.lightOnSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: DesignTokens.lightOutline,
      thickness: 1,
      space: 1,
    ),
    
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    textTheme: _textTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: DesignTokens.vibrantPurple,
      onPrimary: DesignTokens.darkOnPrimary,
      primaryContainer: DesignTokens.deepPurple,
      onPrimaryContainer: DesignTokens.lightPurple,
      secondary: DesignTokens.vibrantPink,
      onSecondary: DesignTokens.darkOnSecondary,
      secondaryContainer: DesignTokens.deepPink,
      onSecondaryContainer: DesignTokens.lightPink,
      tertiary: DesignTokens.vibrantCyan,
      onTertiary: DesignTokens.darkOnPrimary,
      tertiaryContainer: DesignTokens.deepCyan,
      onTertiaryContainer: DesignTokens.lightCyan,
      error: DesignTokens.errorColor,
      surface: DesignTokens.darkSurface,
      onSurface: DesignTokens.darkOnSurface,
      background: DesignTokens.darkBackground,
      onBackground: DesignTokens.darkOnBackground,
      surfaceVariant: DesignTokens.darkSurfaceVariant,
      onSurfaceVariant: DesignTokens.darkOnSurfaceVariant,
      outline: DesignTokens.darkOutline,
    ),
    scaffoldBackgroundColor: DesignTokens.darkBackground,
    
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.darkSurface.withOpacity(0.95),
      foregroundColor: DesignTokens.darkOnBackground,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: DesignTokens.darkOnBackground,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(
        color: DesignTokens.darkOnBackground,
        size: DesignTokens.iconSize,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.darkSurface.withOpacity(0.95),
      selectedItemColor: DesignTokens.lightPurple,
      unselectedItemColor: DesignTokens.darkOnSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      selectedIconTheme: const IconThemeData(
        size: DesignTokens.iconSizeLg,
      ),
      unselectedIconTheme: const IconThemeData(
        size: DesignTokens.iconSize,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.vibrantPurple,
        foregroundColor: DesignTokens.darkOnPrimary,
        elevation: 4,
        shadowColor: DesignTokens.vibrantPurple.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return DesignTokens.darkOnPrimary.withOpacity(0.2);
          }
          return null;
        }),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DesignTokens.vibrantPurple,
        foregroundColor: DesignTokens.darkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DesignTokens.lightPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing,
          vertical: DesignTokens.spacingMd,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.lightPurple,
        side: const BorderSide(
          color: DesignTokens.vibrantPurple,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacing,
        ),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DesignTokens.vibrantPurple,
      foregroundColor: DesignTokens.darkOnPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radius),
      ),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: DesignTokens.darkSurfaceVariant,
      labelStyle: const TextStyle(
        color: DesignTokens.darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: DesignTokens.deepPurple,
      secondarySelectedColor: DesignTokens.deepPink,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      side: BorderSide.none,
    ),
    
    cardTheme: CardThemeData(
      color: DesignTokens.darkSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      margin: const EdgeInsets.all(DesignTokens.spacingSm),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.lightPurple,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: const BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing,
        vertical: DesignTokens.spacing,
      ),
      hintStyle: const TextStyle(
        color: DesignTokens.darkOnSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: DesignTokens.darkOutline,
      thickness: 1,
      space: 1,
    ),
    
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    textTheme: _textTheme,
  );

  static TextTheme get _textTheme => const TextTheme(
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
}
