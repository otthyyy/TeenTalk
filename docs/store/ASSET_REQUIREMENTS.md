# Asset Requirements

This document outlines the specifications for all visual assets needed for the App Store and Google Play Store releases of TeenTalk.

## App Icon

### iOS App Store
- **Size:** 1024 x 1024 px
- **Format:** PNG
- **Background:** No transparency (alpha channel must be removed)
- **File name:** `app-icon-ios-1024.png`
- **Notes:** Avoid text on the icon; use TeenTalk logo with brand gradient.

### Google Play Store
- **Size:** 512 x 512 px
- **Format:** PNG (32-bit with alpha)
- **File name:** `app-icon-android-512.png`
- **Notes:** Icon must fit within the required safe-zone (circular mask).

## Feature Graphics & Promotional Images

### iOS App Store
- **Promotional Image:** 4320 x 1080 px JPG/PNG (optional but recommended for featuring)
- **App Preview Video:** 1920 x 1080 px, up to 30 seconds, MOV/MP4
- **Frame Rate:** 30 fps recommended
- **File name:**
  - `promo-image-ios.png`
  - `app-preview-ios-en.mp4`
  - `app-preview-ios-it.mp4`

### Google Play Store
- **Feature Graphic:** 1024 x 500 px PNG/JPG, RGB, no transparency
- **Promo Video:** YouTube URL only (1080p resolution recommended)
- **Phone Preview Video (optional):** 16:9 aspect ratio, MP4
- **File name:**
  - `feature-graphic-android.png`
  - `promo-video-android.txt` (contains YouTube URL)

## Screenshots

### iOS App Store
| Device | Resolution | Orientation | Count | Folder |
|--------|------------|-------------|-------|--------|
| iPhone 15 Pro Max (6.7") | 1290 x 2796 px | Portrait | 5 | `assets/app-store/screenshots/iphone/<locale>/` |
| iPhone 14 Pro Max (6.7") | 1284 x 2778 px | Portrait | optional | same |
| iPhone 14 (6.1") | 1170 x 2532 px | Portrait | optional | same |
| iPad Pro 12.9" (6th gen) | 2048 x 2732 px | Portrait | 5 | `assets/app-store/screenshots/ipad/<locale>/` |
| iPad Pro 11" (4th gen) | 1668 x 2388 px | Portrait | optional | same |

- **Format:** PNG (preferred) or high-quality JPG
- **Locales:** `en-US`, `it-IT` (use folder name `en` / `it`)
- **Device frame:** Add official Apple device frames (Figma template provided)
- **Status bar:** 9:41 time, full battery, Wi-Fi signal
- **Naming:** `01-feed.png`, `02-messages.png`, etc.

### Google Play Store
| Device Category | Resolution | Orientation | Count | Folder |
|-----------------|------------|-------------|-------|--------|
| Phone (6.3"-6.9") | 1080 x 1920 px | Portrait | 8 (min 2) | `assets/google-play/screenshots/phone/<locale>/` |
| Tablet 7" | 1200 x 1920 px | Portrait | 3 (recommended) | `assets/google-play/screenshots/tablet/<locale>/` |
| Tablet 10" | 1920 x 1200 px | Landscape | 3 (recommended) | same |

- **Format:** PNG/JPG
- **Locales:** `en-US`, `it-IT`
- **Device frame:** Optional on Android but recommended for consistency
- **Status bar:** Clean status bar with full battery and network
- **Naming:** `01-feed.png`, `02-safe-space.png`, etc.

## Content Guidelines

### Required Screenshot Themes
1. **Onboarding & Safety Controls** (privacy settings, parental consent)
2. **Community Feed** (diverse content, trending topics)
3. **Direct Messages** (anonymous but safe communication)
4. **Mentor Support** (moderation, resources)
5. **Profile Highlights** (customizable profiles, trust badges)
6. **Notifications & Alerts** (real-time updates)
7. **Dark Mode** (night-friendly UI)
8. **Tablet Layout** (responsive design)

### Visual Notes
- Use brand gradient backgrounds for text overlays
- Highlight unique features: trust badges, anonymous posts, moderation tools
- Emphasize safety and privacy (COPPA, GDPR compliance messaging)
- Include short benefit statements (max 40 characters) on each screenshot
- Verify translations for Italian overlays

## Asset Editing Workflow

1. **Design Tool:** Figma or Sketch with TeenTalk brand kit
2. **Typography:** Use TeenTalk fonts (Headlines 700 weight, Body 400)
3. **Color Palette:** Follow TeenTalk brand colors (see README)
4. **Export:** Use export presets for exact resolution
5. **Optimization:** Run through ImageOptim (or use `pngquant`) to reduce file size without quality loss
6. **Naming:** Follow naming conventions strictly to avoid store upload confusion

## Quality Checklist
- [ ] Resolution matches exact specification (no scaling or stretching)
- [ ] No pixelation or compression artifacts
- [ ] Branding consistent (logo, colors, typography)
- [ ] Text overlays legible (>14pt, high contrast)
- [ ] No personal data or internal build indicators
- [ ] Localized captions match screenshot language
- [ ] File names match required pattern
- [ ] Device frames correctly applied (if used)

## Asset Templates
- Figma templates for screenshots: `TeenTalk Store Kit.fig`
- Icon template: `TeenTalk App Icon.fig`
- Feature graphic template: `TeenTalk Feature Graphic.fig`

> Download templates from internal design drive: `Design/StoreAssets/`

## Contact
For questions about asset requirements, contact the design team at `design@teentalk.app`.
