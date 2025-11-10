#!/bin/bash

# Firebase Emulator Start Script for Integration Tests
# This script starts the Firebase emulator suite required for integration tests

set -e

echo "🔥 Starting Firebase Emulator Suite..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it with:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Kill any existing emulator processes
echo "🧹 Cleaning up any existing emulator processes..."
pkill -f "firebase.*emulator" || true
sleep 2

# Start emulators in the background
echo "🚀 Starting emulators..."
firebase emulators:start \
  --only auth,firestore,storage,functions \
  --project teentalk-31e45 \
  > emulator.log 2>&1 &

EMULATOR_PID=$!
echo "📝 Emulator process started with PID: $EMULATOR_PID"
echo $EMULATOR_PID > .emulator.pid

# Wait for emulators to be ready
echo "⏳ Waiting for emulators to start..."
MAX_WAIT=30
WAITED=0

while [ $WAITED -lt $MAX_WAIT ]; do
  if curl -s http://localhost:4000 > /dev/null 2>&1; then
    echo "✅ Emulator UI is ready at http://localhost:4000"
    break
  fi
  
  sleep 1
  WAITED=$((WAITED + 1))
  echo -n "."
done

echo ""

if [ $WAITED -eq $MAX_WAIT ]; then
  echo "❌ Emulators failed to start within ${MAX_WAIT} seconds"
  echo "📋 Last 20 lines of emulator log:"
  tail -n 20 emulator.log
  exit 1
fi

# Verify individual emulators are running
echo "🔍 Verifying emulator services..."

check_emulator() {
  local name=$1
  local port=$2
  
  if curl -s "http://localhost:${port}" > /dev/null 2>&1; then
    echo "✅ ${name} emulator is running on port ${port}"
    return 0
  else
    echo "⚠️  ${name} emulator may not be ready on port ${port}"
    return 1
  fi
}

check_emulator "Auth" 9099 || true
check_emulator "Firestore" 8080 || true
check_emulator "Storage" 9199 || true
check_emulator "Functions" 5001 || true

echo ""
echo "🎉 Firebase Emulator Suite is ready!"
echo "📊 Emulator UI: http://localhost:4000"
echo "🔐 Auth Emulator: http://localhost:9099"
echo "📦 Firestore Emulator: http://localhost:8080"
echo "💾 Storage Emulator: http://localhost:9199"
echo "⚡ Functions Emulator: http://localhost:5001"
echo ""
echo "📝 Emulator logs are being written to: emulator.log"
echo "🛑 To stop emulators, run: ./scripts/stop_emulator.sh"
echo ""
