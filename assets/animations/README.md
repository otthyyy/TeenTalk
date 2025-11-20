# Animation Assets

This directory contains motion assets for the TeenTalk app.

## Directory Structure

- `rive/` - Rive animation files (.riv)
- `lottie/` - Lottie animation files (.json)

## Rive Animations

Place Rive animation files in the `rive/` directory:
- `splash_logo.riv` - TeenTalk logo animation for splash screen (≤1.5s)
- `intro_background.riv` - Background animation for first-run intro

## Lottie Animations

Place Lottie animation files in the `lottie/` directory:
- `onboarding_welcome.json` - Welcome animation for onboarding steps
- `empty_state.json` - Animation for empty states
- `loading.json` - Loading animation
- `success.json` - Success animation

## Asset Guidelines

- Keep file sizes reasonable (< 500KB per animation)
- Rive animations should be optimized for web/mobile
- Lottie animations should be exported from After Effects with standard settings
- Test animations on both light and dark themes
- Ensure animations work offline with appropriate fallbacks

## Testing

Animations can be disabled for testing/CI using:
- Environment variable: `SKIP_SPLASH_ANIMATION=true`
- Motion preference flag (exposed as `shouldAnimate` parameter)
