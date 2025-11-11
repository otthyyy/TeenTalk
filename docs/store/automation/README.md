# Screenshot Automation Toolkit

This folder contains automation resources to streamline the capture of App Store and Google Play screenshots for TeenTalk.

## Overview

The automation workflow uses Flutter integration tests to navigate through key app flows and capture screenshots programmatically. This ensures consistent data, device states, and image naming across both iOS and Android.

### Files
- `capture_screenshots.sh` – Shell script orchestrating the capture process for iOS and Android
- `integration_test/store_flow_test.dart` – (to be created) Integration test script that navigates through the app and triggers screenshot captures
- `integration_test/driver.dart` – (existing Flutter driver entry point)

> Note: This repository does not yet include the `store_flow_test.dart` file. Use the template below to create it in your working branch if automation is required. Manual capture instructions are available in [`../SCREENSHOT_GUIDELINES.md`](../SCREENSHOT_GUIDELINES.md).

## Prerequisites

1. **Flutter environment**
   - Flutter SDK (3.19.6 or higher)
   - Dart SDK
   - `flutter doctor` reports no critical errors

2. **iOS** (macOS only)
   - Xcode 15+
   - Command Line Tools
   - SSH access or local environment with required permissions

3. **Android**
   - Android Studio with SDK 33+
   - AVDs configured for `Pixel_7_Pro_API_34` and `Pixel_Tablet_API_34`
   - `adb` available in PATH

4. **TeenTalk app setup**
   - `flutter pub get`
   - Firebase configuration files present (`GoogleService-Info.plist`, `google-services.json`)
   - Sample data or mock authentication available for integration tests

5. **Fonts & Graphics**
   - TeenTalk brand font installed locally (for overlay editing)
   - Figma templates accessible for device frames

## Quick Start

```bash
cd docs/store/automation
./capture_screenshots.sh ios en
./capture_screenshots.sh ios it
./capture_screenshots.sh android en
./capture_screenshots.sh android it
```

Each command:
1. Boots the appropriate simulator/emulator
2. Sets locale (en-US or it-IT)
3. Runs the integration test (`store_flow_test.dart`)
4. Saves screenshots to:
   - `docs/store/assets/app-store/screenshots/...`
   - `docs/store/assets/google-play/screenshots/...`

## Integration Test Template (`integration_test/store_flow_test.dart`)

Create this file within the project root (not committed yet). Outline:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:teen_talk_app/main.dart' as app;

Future<void> captureScreenshot(WidgetTester tester, String name) async {
  const outputDir = String.fromEnvironment('OUTPUT_DIR', defaultValue: '');
  final directory = Directory(outputDir);
  if (!directory.exists()) {
    await directory.create(recursive: true);
  }
  final path = '${directory.path}/$name.png';
  await tester.pumpAndSettle(const Duration(seconds: 1));
  await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(path);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Store listing flow', (tester) async {
    const locale = String.fromEnvironment('LOCALE', defaultValue: 'en');
    app.main(localeOverride: locale);
    await tester.pumpAndSettle();

    // TODO: implement navigation to each feature screen
    await captureScreenshot(tester, '01-onboarding');
    // ... continue for feed, messages, safety, etc.
  });
}
```

Customize the test to navigate through each screen (feed, messages, profile, settings, etc.) before taking a screenshot.

## Post-Processing

After automation runs:
1. Review and trim screenshots as needed (simulate gestures may show tooltips)
2. Add device frames via Figma templates
3. Insert localized captions and overlays
4. Optimize images (`pngquant`, `jpegoptim`)
5. Rename files according to manifest (see [`../ASSET_REQUIREMENTS.md`](../ASSET_REQUIREMENTS.md))

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Simulator fails to boot | Quit Simulator app, run `xcrun simctl erase all`, re-run script |
| Flutter cannot find driver | Ensure `integration_test/driver.dart` exists. Example provided below |
| Emulator times out | Increase AVD RAM to 4GB, ensure hardware acceleration enabled |
| Locale not applied | For iOS, set locale manually in Settings; for Android use `adb shell setprop persist.sys.locale it-IT` |
| Screenshots black | Disable lockscreen (Simulator > Hardware > Lock), rerun test |

### Example `integration_test/driver.dart`

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

## Manual Capture Alternative

When automation is unavailable:
1. Follow [`../SCREENSHOT_GUIDELINES.md`](../SCREENSHOT_GUIDELINES.md) for manual capture steps
2. Use the naming convention and folder structure defined in [`../ASSET_REQUIREMENTS.md`](../ASSET_REQUIREMENTS.md)
3. Document manual steps in the release notes for traceability

## Support
- Product Engineering: product@teentalk.app
- QA Team: qa@teentalk.app
- Design Team: design@teentalk.app
