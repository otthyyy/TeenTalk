import 'package:flutter/material.dart';

class DesignTokens {
  const DesignTokens._();

  static const Color vibrantPurple = Color(0xFF8B5CF6);
  static const Color deepPurple = Color(0xFF6D28D9);
  static const Color lightPurple = Color(0xFFA78BFA);
  
  static const Color vibrantPink = Color(0xFFEC4899);
  static const Color deepPink = Color(0xFFDB2777);
  static const Color lightPink = Color(0xFFF472B6);
  
  static const Color vibrantCyan = Color(0xFF06B6D4);
  static const Color deepCyan = Color(0xFF0891B2);
  static const Color lightCyan = Color(0xFF22D3EE);
  
  static const Color vibrantYellow = Color(0xFFFBBF24);
  static const Color vibrantOrange = Color(0xFFF97316);
  
  static const Color neonGreen = Color(0xFF10B981);
  static const Color limeGreen = Color(0xFF84CC16);
  
  static const Color lightBackground = Color(0xFFFBFBFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F7);
  static const Color lightOutline = Color(0xFFE5E7EB);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1F2937);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);
  
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252538);
  static const Color darkOutline = Color(0xFF374151);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFF9FAFB);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);
  
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
  
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radius = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radiusFull = 9999.0;
  
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSize = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration duration = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);
  
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveAccelerate = Curves.accelerate;
  
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
