#!/usr/bin/env bash

# TeenTalk Screenshot Capture Automation Script
# --------------------------------------------
# This script provides helper commands to automate screenshot capture for
# App Store and Google Play assets. It wraps common `flutter`, `adb`, and
# `xcrun simctl` commands so the design and QA teams can generate consistent
# assets quickly.
#
# Usage examples:
#   ./capture_screenshots.sh ios en
#   ./capture_screenshots.sh ios it
#   ./capture_screenshots.sh android en
#   ./capture_screenshots.sh android it
#
# Prerequisites:
#   - macOS for iOS capture (Xcode + Command Line Tools installed)
#   - Android SDK + emulator images installed
#   - Flutter installed and configured for both platforms
#   - TeenTalk repository checked out and dependencies resolved
#   - Integration tests located under `integration_test/store_flow_test.dart`
#     (see README.md for details on setting up the navigation script)

set -euo pipefail

PLATFORM=${1:-}
LOCALE=${2:-en}

if [[ -z "${PLATFORM}" || -z "${LOCALE}" ]]; then
  echo "Usage: $0 <ios|android> <en|it>"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
INTEGRATION_TEST="integration_test/store_flow_test.dart"
OUTPUT_BASE="${PROJECT_ROOT}/docs/store/assets"

function ensure_dependencies() {
  command -v flutter >/dev/null 2>&1 || {
    echo "Flutter not found. Install Flutter SDK before running this script." >&2
    exit 1
  }
}

function run_ios_flow() {
  local locale=$1
  local device="iPhone 15 Pro Max"
  local device_locale="${locale}"
  case "${locale}" in
    en)
      device_locale="en-US"
      ;;
    it)
      device_locale="it-IT"
      ;;
  esac

  echo "Booting simulator: ${device} (${locale})"
  xcrun simctl shutdown all || true
  xcrun simctl boot "${device}" || true
  xcrun simctl bootstatus "${device}" -b

  echo "Setting locale to ${locale}"
  xcrun simctl erase "${device}" || true
  xcrun simctl boot "${device}"
  /usr/libexec/PlistBuddy -c "Set :AppleLanguages:0 ${locale}" "$(xcrun simctl get_app_container "${device}" com.apple.Preferences data)/Library/Preferences/.GlobalPreferences.plist" || true

  echo "Running integration test for screenshot generation"
  mkdir -p "${OUTPUT_BASE}/app-store/screenshots/iphone/${locale}"
  pushd "${PROJECT_ROOT}" >/dev/null
  flutter drive \
    --driver=integration_test/driver.dart \
    --target="${INTEGRATION_TEST}" \
    -d "${device}" \
    --dart-define=LOCALE=${locale} \
    --dart-define=OUTPUT_DIR="${OUTPUT_BASE}/app-store/screenshots/iphone/${locale}" \
    --dart-define=DEVICE=iphone
  popd >/dev/null

  echo "Capturing iPad screenshots"
  local ipad="iPad Pro (12.9-inch) (6th generation)"
  xcrun simctl shutdown "${ipad}" || true
  xcrun simctl boot "${ipad}"
  xcrun simctl bootstatus "${ipad}" -b

  mkdir -p "${OUTPUT_BASE}/app-store/screenshots/ipad/${locale}"
  pushd "${PROJECT_ROOT}" >/dev/null
  flutter drive \
    --driver=integration_test/driver.dart \
    --target="${INTEGRATION_TEST}" \
    -d "${ipad}" \
    --dart-define=LOCALE=${locale} \
    --dart-define=OUTPUT_DIR="${OUTPUT_BASE}/app-store/screenshots/ipad/${locale}" \
    --dart-define=DEVICE=ipad
  popd >/dev/null
}

function run_android_flow() {
  local locale=$1
  local phone_avd="Pixel_7_Pro_API_34"
  local tablet_avd="Pixel_Tablet_API_34"
  local device_locale="${locale}"
  case "${locale}" in
    en)
      device_locale="en-US"
      ;;
    it)
      device_locale="it-IT"
      ;;
  esac

  echo "Starting Android emulator: ${phone_avd}"
  (nohup emulator -avd "${phone_avd}" >/tmp/${phone_avd}.log 2>&1 &)
  adb wait-for-device
  adb shell settings put system system_locales ${device_locale}

  echo "Enabling demo mode status bar"
  adb shell settings put global sysui_demo_allowed 1
  adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
  adb shell am broadcast -a com.android.systemui.demo -e command battery -e plugged false -e level 100
  adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e mobile show -e datatype lte
  adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false

  echo "Running integration test for phone screenshots"
  mkdir -p "${OUTPUT_BASE}/google-play/screenshots/phone/${locale}"
  pushd "${PROJECT_ROOT}" >/dev/null
  flutter drive \
    --driver=integration_test/driver.dart \
    --target="${INTEGRATION_TEST}" \
    -d "${phone_avd}" \
    --dart-define=LOCALE=${locale} \
    --dart-define=OUTPUT_DIR="${OUTPUT_BASE}/google-play/screenshots/phone/${locale}" \
    --dart-define=DEVICE=android_phone
  popd >/dev/null

  echo "Capturing tablet screenshots"
  (nohup emulator -avd "${tablet_avd}" >/tmp/${tablet_avd}.log 2>&1 &)
  adb -s "emulator-5556" wait-for-device
  adb -s "emulator-5556" shell settings put system system_locales ${device_locale}

  mkdir -p "${OUTPUT_BASE}/google-play/screenshots/tablet/${locale}"
  pushd "${PROJECT_ROOT}" >/dev/null
  flutter drive \
    --driver=integration_test/driver.dart \
    --target="${INTEGRATION_TEST}" \
    -d "emulator-5556" \
    --dart-define=LOCALE=${locale} \
    --dart-define=OUTPUT_DIR="${OUTPUT_BASE}/google-play/screenshots/tablet/${locale}" \
    --dart-define=DEVICE=android_tablet
  popd >/dev/null

  echo "Disabling demo mode"
  adb shell am broadcast -a com.android.systemui.demo -e command exit || true
}

ensure_dependencies

case "${PLATFORM}" in
  ios)
    run_ios_flow "${LOCALE}"
    ;;
  android)
    run_android_flow "${LOCALE}"
    ;;
  *)
    echo "Unsupported platform: ${PLATFORM}. Use ios or android." >&2
    exit 1
    ;;
esac
