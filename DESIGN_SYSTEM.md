# TeenTalk Design System

## Overview
The TeenTalk design system is built to provide a vibrant, youth-focused visual foundation that feels "must-download" while remaining accessible in both light and dark modes.

## Color Palette

### Primary Colors
- **Vibrant Purple** (`#8B5CF6`): Main brand color
- **Deep Purple** (`#6D28D9`): Darker variant for containers
- **Light Purple** (`#A78BFA`): Lighter variant for highlights

### Secondary Colors
- **Vibrant Pink** (`#EC4899`): Secondary accent
- **Deep Pink** (`#DB2777`): Darker pink variant
- **Light Pink** (`#F472B6`): Lighter pink variant

### Tertiary Colors
- **Vibrant Cyan** (`#06B6D4`): Tertiary accent
- **Deep Cyan** (`#0891B2`): Darker cyan variant
- **Light Cyan** (`#22D3EE`): Lighter cyan variant

### Accent Colors
- **Vibrant Yellow** (`#FBBF24`): Highlight color
- **Vibrant Orange** (`#F97316`): Warning/attention color
- **Neon Green** (`#10B981`): Success color
- **Lime Green** (`#84CC16`): Alternative success color

### Light Theme
- Background: `#FBFBFB`
- Surface: `#FFFFFF`
- Surface Variant: `#F5F5F7`
- Outline: `#E5E7EB`
- On Background: `#1F2937`
- On Surface Variant: `#6B7280`

### Dark Theme
- Background: `#0F0F1E`
- Surface: `#1A1A2E`
- Surface Variant: `#252538`
- Outline: `#374151`
- On Background: `#F9FAFB`
- On Surface Variant: `#9CA3AF`

## Gradients

### Primary Gradient
- Top Left: Vibrant Purple
- Bottom Right: Vibrant Pink

### Secondary Gradient
- Top Left: Vibrant Cyan
- Bottom Right: Deep Cyan

### Tertiary Gradient
- Top Left: Vibrant Yellow
- Bottom Right: Vibrant Orange

### Accent Gradient
- Multi-color: Light Purple → Light Pink → Light Cyan

## Typography

### Display
- **Display Large**: 40px, Weight 800, -1.0 letter spacing
- **Display Medium**: 36px, Weight 800, -0.75 letter spacing
- **Display Small**: 32px, Weight 700, -0.5 letter spacing

### Headlines
- **Headline Large**: 28px, Weight 700, -0.25 letter spacing
- **Headline Medium**: 24px, Weight 700, 0 letter spacing
- **Headline Small**: 20px, Weight 600, 0 letter spacing

### Titles
- **Title Large**: 18px, Weight 600, 0 letter spacing
- **Title Medium**: 16px, Weight 600, 0.15 letter spacing
- **Title Small**: 14px, Weight 600, 0.1 letter spacing

### Body
- **Body Large**: 16px, Weight 400, 0.5 letter spacing, 1.5 line height
- **Body Medium**: 14px, Weight 400, 0.25 letter spacing, 1.5 line height
- **Body Small**: 12px, Weight 400, 0.4 letter spacing, 1.5 line height

### Labels
- **Label Large**: 14px, Weight 600, 0.5 letter spacing
- **Label Medium**: 12px, Weight 600, 0.5 letter spacing
- **Label Small**: 11px, Weight 500, 0.5 letter spacing

## Spacing

- **2xs**: 2px
- **xs**: 4px
- **sm**: 8px
- **md**: 12px
- **base**: 16px
- **lg**: 24px
- **xl**: 32px
- **2xl**: 40px
- **3xl**: 48px
- **4xl**: 64px

## Border Radius

- **xs**: 4px
- **sm**: 8px
- **md**: 12px
- **base**: 16px
- **lg**: 20px
- **xl**: 24px
- **2xl**: 32px
- **full**: 9999px (fully rounded)

## Icons

- **Small**: 16px
- **Medium**: 20px
- **Base**: 24px
- **Large**: 32px
- **Extra Large**: 40px

## Animation & Motion

### Durations
- **Fast**: 150ms
- **Base**: 250ms
- **Slow**: 350ms
- **Slower**: 500ms

### Curves
- **Default**: Ease In Out
- **Emphasized**: Ease Out Cubic
- **Decelerate**: Decelerate
- **Accelerate**: Accelerate

## Shadows

### Standard Shadows
- **Small**: 4px blur, 2px offset, 5% opacity
- **Base**: 8px blur, 4px offset, 8% opacity
- **Medium**: 12px blur, 6px offset, 10% opacity
- **Large**: 16px blur, 8px offset, 12% opacity
- **Extra Large**: 24px blur, 12px offset, 15% opacity

### Colored Shadows
Use `DesignTokens.coloredShadow(color)` for brand-colored shadows on hero elements.

### Glow Shadows
Use `DesignTokens.glowShadow(color)` for glowing effects around interactive elements.

## Components

### Buttons

#### Elevated Button
- Background: Vibrant Purple
- Foreground: White
- Padding: 24px horizontal, 16px vertical
- Border Radius: 12px
- Elevation: 4
- Colored shadow on hover/press

#### Outlined Button
- Border: 2px Vibrant Purple
- Foreground: Vibrant Purple
- Padding: 24px horizontal, 16px vertical
- Border Radius: 12px

#### Text Button
- Foreground: Vibrant Purple
- Padding: 16px horizontal, 12px vertical
- Border Radius: 12px

### Chips
- Background: Surface Variant
- Border Radius: Full (pill shape)
- Padding: 12px horizontal, 8px vertical
- Selected: Light Purple (light) / Deep Purple (dark)

### Cards
- Background: Surface
- Border Radius: 20px
- Elevation: 2
- Margin: 8px

### Input Fields
- Fill Color: Surface Variant
- Border Radius: 12px
- Focused Border: 2px Vibrant Purple
- Padding: 16px horizontal and vertical

### App Bar
- Background: Surface with 95% opacity
- Elevation: 0
- Border Radius: 20px bottom corners
- Center title: true

### Bottom Navigation
- Background: Glass effect with backdrop blur
- Border Radius: 24px top corners
- Selected: Vibrant Purple (light) / Light Purple (dark)
- Icon Size: 24px (unselected), 32px (selected)
- Label: 12px, Weight 600 (selected), Weight 500 (unselected)

## Decorations

### Glass Effect
Use `AppDecorations.glass()` or `AppDecorations.glassContainer()` for modern glassmorphism effects with:
- Backdrop blur
- Semi-transparent background
- Border highlight
- Subtle shadow

### Gradient Backgrounds
Use `AppDecorations.gradientBackground()` for full gradient backgrounds with custom or preset gradients.

### Surface Gradients
Use `AppDecorations.surfaceGradientBackground()` for subtle gradient overlays on surfaces.

### Gradient Cards
Use `AppDecorations.gradientCard()` for cards with gradient backgrounds and colored shadows.

### Glow Cards
Use `AppDecorations.glowCard()` for cards with glowing effects around them.

## Accessibility

### WCAG AA Compliance
All color combinations meet WCAG AA standards (4.5:1 contrast ratio) for:
- Body text on backgrounds
- Primary actions
- Interactive elements

### Semantic Colors
- **Error**: `#EF4444`
- **Success**: `#10B981`
- **Warning**: `#FBBF24`

## Usage Examples

### Using Design Tokens
```dart
import 'package:teen_talk_app/src/core/theme/design_tokens.dart';

Container(
  padding: EdgeInsets.all(DesignTokens.spacing),
  decoration: BoxDecoration(
    color: DesignTokens.vibrantPurple,
    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
  ),
)
```

### Using Decorations
```dart
import 'package:teen_talk_app/src/core/theme/decorations.dart';

AppDecorations.glassContainer(
  child: Text('Glass effect container'),
  isDark: Theme.of(context).brightness == Brightness.dark,
)
```

### Animated Transitions
```dart
AnimatedContainer(
  duration: DesignTokens.duration,
  curve: DesignTokens.curveEmphasized,
  // ... properties
)
```

## Testing

Golden tests are provided to ensure design consistency:
- `test/src/core/theme/theme_golden_test.dart`: Theme component showcase
- `test/features/auth/auth_golden_test.dart`: Auth page themes

Run golden tests with:
```bash
flutter test --update-goldens
```

## Notes

- The design system is built on Material 3 with custom theming
- All components automatically adapt to light/dark mode
- Page transitions use platform-specific animations (Zoom for Android, Cupertino for iOS)
- The bottom navigation uses a glass effect with subtle gradient background on the scaffold
