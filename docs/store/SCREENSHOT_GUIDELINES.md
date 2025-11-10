# Screenshot Guidelines

This guide explains how to capture high-quality screenshots for the TeenTalk app on both iOS and Android platforms.

## Overview

Effective store screenshots should:
- Showcase core features (feed, messages, profile, moderation)
- Highlight unique value propositions (privacy, teen-focused, safety)
- Use realistic sample data (no Lorem Ipsum)
- Be visually consistent (branding, layout, tone)
- Be localized (English and Italian)

## General Principles

### Sample Data Requirements
- **User profiles:** Diverse names, ages, schools, realistic bios
- **Posts:** Authentic teen topics (school events, interests, advice) – nothing inappropriate
- **Comments:** Thoughtful, on-topic, respectful
- **Messages:** Natural conversation flow
- **Timestamps:** Recent but varied (2m, 15m, 1h, 3h, etc.)
- **Counts:** Realistic likes (3-40), comments (0-15), followers (20-150)

### Visual Consistency
- **Status bar:** 9:41 AM, full battery, Wi-Fi, no notch overlay issues
- **Navigation:** All UI elements visible (no cut-off text)
- **Theme:** Capture both light and dark mode versions for hero screenshots
- **Safe zones:** Ensure no critical content is cut off by device corners/notch
- **Device frames:** Apply official device frames (Apple, Android) for premium look

## Screenshot Themes

### 1. Welcome / Onboarding (01-onboarding)
**Purpose:** Show new user experience and ease of use.

- **Frame 1:** Welcome screen with TeenTalk branding
- **Frame 2:** Profile creation (nickname, school selection)
- **Frame 3:** Privacy settings (opt-in for crash reports, notifications)
- **Caption:** "Join a safe, welcoming space for teens" (EN) / "Unisciti a uno spazio sicuro e accogliente per adolescenti" (IT)

### 2. Community Feed (02-feed)
**Purpose:** Highlight the vibrant, diverse social feed.

- **Frame:** Feed with 4-5 posts visible
- **Content:** Mix of text posts, images, trending topics
- **UI:** Show trust badges, like/comment buttons, trending tag
- **Caption:** "Share, connect, and discover with your peers" (EN) / "Condividi, connettiti e scopri con i tuoi coetanei" (IT)

### 3. Anonymous Posting (03-spotted)
**Purpose:** Emphasize safe, anonymous expression.

- **Frame:** Compose screen for "Spotted" post
- **UI:** Anonymous toggle ON, school/topic selection
- **Caption:** "Speak freely in a judgment-free zone" (EN) / "Esprimi liberamente in uno spazio senza giudizi" (IT)

### 4. Direct Messages (04-messages)
**Purpose:** Show private communication features.

- **Frame:** Message list with 3-4 conversations
- **UI:** Read receipts, online status indicators, search bar
- **Caption:** "Safe direct messaging with your friends" (EN) / "Messaggi diretti sicuri con i tuoi amici" (IT)

### 5. Safety & Moderation (05-safety)
**Purpose:** Reassure parents and teens about safety features.

- **Frame:** Report dialog or moderation queue (for admins)
- **UI:** Report options (harassment, spam, etc.), confirmation message
- **Caption:** "Community-focused moderation keeps everyone safe" (EN) / "La moderazione incentrata sulla comunità mantiene tutti al sicuro" (IT)

### 6. Profile Customization (06-profile)
**Purpose:** Show personalization and user control.

- **Frame:** User profile with stats (posts, comments, followers)
- **UI:** Edit profile button, trust badge, activity summary
- **Caption:** "Your profile, your way" (EN) / "Il tuo profilo, a modo tuo" (IT)

### 7. Notifications (07-notifications)
**Purpose:** Demonstrate real-time engagement.

- **Frame:** Notification list with various types (likes, comments, follows)
- **UI:** Grouped notifications, clear timestamps, swipe actions
- **Caption:** "Stay connected with instant updates" (EN) / "Rimani connesso con aggiornamenti istantanei" (IT)

### 8. Dark Mode (08-dark-mode)
**Purpose:** Showcase accessibility and user preference support.

- **Frame:** Feed or messages in dark theme
- **UI:** Deep purple/dark surfaces, vibrant accents pop
- **Caption:** "Comfortable viewing any time of day" (EN) / "Visualizzazione comoda in qualsiasi momento della giornata" (IT)

### 9. (Tablet only) Split View (09-tablet-layout)
**Purpose:** Highlight responsive design for larger screens.

- **Frame:** iPad split-view with feed on left, messages on right
- **UI:** Optimized layout, no wasted space
- **Caption:** "Powerful multitasking on iPad" (EN) / "Potente multitasking su iPad" (IT)

## Capture Process

### iOS (Xcode Simulator)

1. **Setup Simulator**
   ```bash
   # Open specific simulator
   xcrun simctl list devices
   xcrun simctl boot "iPhone 15 Pro Max"
   open -a Simulator
   ```

2. **Configure Simulator**
   - Set time to 9:41 AM (Xcode: Debug > Set Time)
   - Set battery to 100% and plugged in (Debug > Battery)
   - Enable Wi-Fi indicator
   - Set language to English or Italian (Settings > General > Language)

3. **Run App**
   ```bash
   flutter run -d <simulator-device-id>
   ```

4. **Capture Screenshots**
   - Navigate to target screen
   - Use `Cmd + S` (saves to Desktop)
   - Or use `xcrun simctl io booted screenshot screenshot.png`

5. **Repeat for iPad Pro 12.9"**

### Android (Emulator or Physical Device)

1. **Setup Emulator (Android Studio AVD Manager)**
   - Device: Pixel 7 Pro (1440 x 3120, 6.7")
   - API Level: 33+ (Android 13+)
   - Language: English / Italian

2. **Configure Emulator**
   - Set status bar to clean state:
     ```bash
     adb shell settings put global sysui_demo_allowed 1
     adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
     adb shell am broadcast -a com.android.systemui.demo -e command battery -e plugged false -e level 100
     adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4
     adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
     ```

3. **Run App**
   ```bash
   flutter run -d <emulator-device-id>
   ```

4. **Capture Screenshots**
   - Use Android Studio screenshot tool (camera icon)
   - Or use adb:
     ```bash
     adb shell screencap -p /sdcard/screenshot.png
     adb pull /sdcard/screenshot.png
     ```

5. **Cleanup Status Bar**
   ```bash
   adb shell am broadcast -a com.android.systemui.demo -e command exit
   ```

6. **Repeat for Tablet (e.g., Pixel Tablet 10")**

## Automation Script

See [`automation/capture_screenshots.sh`](automation/capture_screenshots.sh) for an automated capture workflow.

### Usage
```bash
cd docs/store/automation
./capture_screenshots.sh ios en
./capture_screenshots.sh ios it
./capture_screenshots.sh android en
./capture_screenshots.sh android it
```

This script:
- Launches simulator/emulator with correct locale
- Opens TeenTalk app
- Navigates to predefined screens
- Captures and names screenshots automatically
- Saves to appropriate asset folder

## Post-Processing

### Add Device Frames
Use Figma/Sketch templates with official device frames:
- **iOS:** Apple device mockups (dark/light frames)
- **Android:** Material Design mockups

### Add Text Overlays
- **Position:** Top or bottom third, avoid covering key UI
- **Font:** TeenTalk brand font (SF Pro/Inter)
- **Weight:** Bold (700)
- **Color:** White with subtle gradient shadow for readability
- **Text Size:** 24-32px (readable at thumbnail size)

### Optimize File Size
```bash
# PNG optimization
pngquant --quality=80-95 --ext .png --force *.png

# JPG optimization
jpegoptim --max=90 --strip-all *.jpg
```

### Naming Convention
Format: `<order>-<feature-slug>-<locale>.png`

Examples:
- `01-onboarding-en.png`
- `02-feed-en.png`
- `02-feed-it.png`
- `03-spotted-en.png`
- `08-dark-mode-en.png`

> Note: Store platforms may rename files upon upload; these names are for organization.

## Quality Checklist

Before uploading:
- [ ] Resolution matches spec exactly (no upscaling/downscaling)
- [ ] Status bar shows 9:41, full battery, network
- [ ] No personal data (real names, emails, phone numbers)
- [ ] Sample data is appropriate for teen audience
- [ ] Text overlays are readable at thumbnail size
- [ ] Localized text matches screenshot language
- [ ] Device frame applied correctly (if used)
- [ ] No compression artifacts or pixelation
- [ ] File size under 5 MB per screenshot

## Common Mistakes to Avoid

❌ Using Lorem Ipsum or placeholder text
❌ Showing debug information (emulator labels, build info)
❌ Including copyrighted images without permission
❌ Mismatched status bar time (use 9:41 AM consistently)
❌ Text overlays covering critical UI elements
❌ Low-quality exports (blurry or pixelated)
❌ Non-localized screenshots (English text on Italian store page)

## Review Process

1. **Internal Review:** Product team reviews for accuracy and messaging
2. **Design Review:** Design team checks brand consistency
3. **Localization Review:** Native speaker verifies Italian translations
4. **Legal Review:** Compliance team checks for privacy/safety claims
5. **Final Approval:** Product lead signs off before upload

## References
- [Apple App Store Screenshot Specifications](https://developer.apple.com/app-store/product-page/)
- [Google Play Screenshot Guidelines](https://support.google.com/googleplay/android-developer/answer/9866151)
- [TeenTalk Design System](../../DESIGN_SYSTEM.md)
- [TeenTalk Branding Guide](https://www.figma.com/file/teentalk-brand)

## Contact
For screenshot questions or approvals, contact:
- **Product:** product@teentalk.app
- **Design:** design@teentalk.app
- **Localization:** localization@teentalk.app
