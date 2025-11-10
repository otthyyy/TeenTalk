#!/bin/bash

# Integration Test Runner Script
# This script automates the complete integration test workflow

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 TeenTalk Integration Test Runner"
echo "===================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "📦 Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed."
    echo "📦 Please install Flutter from: https://flutter.dev"
    exit 1
fi

cd "$PROJECT_DIR"

# Start emulators
echo "🔥 Starting Firebase emulators..."
./scripts/start_emulator.sh

# Wait a bit to ensure emulators are fully ready
echo "⏳ Waiting for emulators to stabilize..."
sleep 5

# Run integration tests
echo ""
echo "🧪 Running integration tests..."
flutter test integration_test/

TEST_EXIT_CODE=$?

# Stop emulators
echo ""
echo "🛑 Stopping Firebase emulators..."
./scripts/stop_emulator.sh

# Report results
echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ All integration tests passed!"
    exit 0
else
    echo "❌ Some integration tests failed."
    echo "📋 Check the output above for details."
    exit $TEST_EXIT_CODE
fi
