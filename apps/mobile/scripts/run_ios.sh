#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f ".env.ios.json" ]]; then
  echo "Missing apps/mobile/.env.ios.json"
  echo "Create it from apps/mobile/.env.example.json and fill Supabase values."
  exit 1
fi

pick_ios_simulator_id() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
devices = json.load(sys.stdin)
for device in devices:
    if device.get("targetPlatform") == "ios" and device.get("emulator"):
        print(device["id"])
        break
'
}

RUN_ARGS=("$@")
if [[ " $* " != *" -d "* ]]; then
  IOS_ID="$(pick_ios_simulator_id || true)"
  if [[ -z "${IOS_ID}" ]]; then
    echo "No iOS simulator running — launching apple_ios_simulator..."
    flutter emulators --launch apple_ios_simulator
    sleep 5
    IOS_ID="$(pick_ios_simulator_id || true)"
  fi
  if [[ -z "${IOS_ID}" ]]; then
    echo "Could not find an iOS simulator. Open Xcode → Simulator, or run: flutter emulators --launch apple_ios_simulator"
    exit 1
  fi
  RUN_ARGS=(-d "$IOS_ID" "$@")
fi

flutter run --dart-define-from-file=.env.ios.json "${RUN_ARGS[@]}"
