#!/bin/bash

# Firebase Emulator Stop Script for Integration Tests

set -e

PID_FILE=.emulator.pid

if [ ! -f "$PID_FILE" ]; then
  echo "⚠️  No emulator PID file found. Attempting to stop emulator by process name..."
  pkill -f "firebase.*emulator" || true
  echo "✅ Emulator processes stopped"
  exit 0
fi

EMULATOR_PID=$(cat "$PID_FILE")

if ps -p "$EMULATOR_PID" > /dev/null 2>&1; then
  echo "🛑 Stopping Firebase emulator with PID $EMULATOR_PID..."
  kill "$EMULATOR_PID"
  sleep 3
  if ps -p "$EMULATOR_PID" > /null 2>&1; then
    echo "⚠️  Force killing emulator process..."
    kill -9 "$EMULATOR_PID" || true
  fi
  echo "✅ Emulator stopped"
else
  echo "ℹ️  Emulator process with PID $EMULATOR_PID not found."
fi

rm -f "$PID_FILE"

echo "🧹 Removing emulator log..."
rm -f emulator.log || true

echo "✨ Cleanup complete"
