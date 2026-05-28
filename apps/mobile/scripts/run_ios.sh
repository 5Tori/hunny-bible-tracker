#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f ".env.ios.json" ]]; then
  echo "Missing apps/mobile/.env.ios.json"
  echo "Create it from apps/mobile/.env.example.json and fill Supabase values."
  exit 1
fi

flutter run --dart-define-from-file=.env.ios.json "$@"
