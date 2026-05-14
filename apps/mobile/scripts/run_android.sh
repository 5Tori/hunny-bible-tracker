#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f ".env.android.json" ]]; then
  echo "Missing apps/mobile/.env.android.json"
  echo "Create it from apps/mobile/.env.example.json and fill Firebase values."
  echo "Use HUNNY_API_BASE_URL=http://10.0.2.2:3000 for Android emulator."
  exit 1
fi

flutter run --dart-define-from-file=.env.android.json "$@"
