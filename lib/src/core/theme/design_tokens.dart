import 'package:flutter/material.dart';

class DesignTokens {
  const DesignTokens._();

  // BeReal-inspired minimalistic accent colors (subtle and clean)
  static const Color vibrantPurple = Color(0xFF000000); // Pure black as primary
  static const Color deepPurple = Color(0xFF1A1A1A);
  static const Color lightPurple = Color(0xFF4A4A4A);

  static const Color vibrantPink = Color(0xFFFF6B6B); // Soft coral accent
  static const Color deepPink = Color(0xFFFF5252);
  static const Color lightPink = Color(0xFFFF8A80);

  static const Color vibrantCyan = Color(0xFF4ECDC4); // Soft teal
  static const Color deepCyan = Color(0xFF45B7AF);
  static const Color lightCyan = Color(0xFF80DEEA);

  static const Color vibrantYellow = Color(0xFFFFE66D); // Soft yellow
  static const Color vibrantOrange = Color(0xFFFF9F43);

  static const Color neonGreen = Color(0xFF6BCF7F); // Soft green
  static const Color limeGreen = Color(0xFF95E1A4);

  // BeReal-style light theme (clean white with minimal grays)
  static const Color lightBackground = Color(0xFFFAFAFA); // Off-white for less eye strain
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5); // Very subtle gray
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A1A); // Softer black
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF757575);

  // BeReal-style dark theme (true black OLED-friendly)
  static const Color darkBackground = Color(0xFF000000); // Pure black for OLED
  static const Color darkSurface = Color(0xFF0A0A0A); // Almost black
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color darkOutline = Color(0xFF2A2A2A);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFF5F5F5); // Soft white
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkOnSurfaceVariant = Color(0xFF9E9E9E);
  
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFFBBF24);
  
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      vibrantPurple,
      vibrantPink,
    ],
  );
  
  static final LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      vibrantCyan,
      deepCyan,
    ],
  );
  
  static final LinearGradient tertiaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      vibrantYellow,
      vibrantOrange,
    ],
  );
  
  static final LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lightPurple,
      lightPink,
      lightCyan,
    ],
  );
  
  static final LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      vibrantPurple.withOpacity(0.05),
      Colors.transparent,
    ],
  );
  
  static final LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      vibrantPurple.withOpacity(0.1),
      Colors.transparent,
    ],
  );
  
  static const double spacing2xs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacing = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 40.0;
  static const double spacing3xl = 48.0;
  static const double spacing4xl = 64.0;
  
  // BeReal-style rounded corners (more rounded!)
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radius = 20.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 28.0;
  static const double radius2xl = 36.0;
  static const double radiusFull = 9999.0;
  
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSize = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;
  
  // BeReal-inspired smooth, snappy animations
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration duration = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);
  static const Duration durationSlower = Duration(milliseconds: 600);

  // Smooth, natural curves like BeReal (less bouncy, more fluid)
  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeOutQuart; // Smooth deceleration
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveAccelerate = Curves.easeInCubic;
  static const Curve curveBounce = Curves.easeOutBack; // Subtle spring effect
  static const Curve curveSnappy = Curves.easeOutExpo; // Quick and snappy
  
  static BoxShadow get shadowSm => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get shadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow get shadowMd => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
  
  static BoxShadow get shadowLg => BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow get shadowXl => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 24,
    offset: const Offset(0, 12),
  );
  
  static BoxShadow coloredShadow(Color color) => BoxShadow(
    color: color.withOpacity(0.3),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
  
  static BoxShadow glowShadow(Color color) => BoxShadow(
    color: color.withOpacity(0.5),
    blurRadius: 20,
    spreadRadius: 2,
  );
}
