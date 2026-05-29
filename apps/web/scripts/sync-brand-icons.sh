#!/usr/bin/env bash
# Regenerate web icons from the monorepo brand source (assets/brand/favicon.png).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/assets/brand/favicon.png"
WEB="$ROOT/apps/web"

if [[ ! -f "$SRC" ]]; then
  echo "Missing brand source: $SRC" >&2
  exit 1
fi

mkdir -p "$WEB/public/brand"
sips -Z 256 "$SRC" --out "$WEB/public/brand/hunny-mark.png" >/dev/null
sips -Z 512 "$SRC" --out "$WEB/src/app/icon.png" >/dev/null
sips -Z 180 "$SRC" --out "$WEB/src/app/apple-icon.png" >/dev/null

echo "Synced brand icons → apps/web/public/brand/hunny-mark.png, src/app/icon.png, apple-icon.png"

ANDROID_SRC="$ROOT/assets"
ANDROID_OUT="$WEB/public/android-tester"
if [[ -f "$ANDROID_SRC/step1.png" ]]; then
  mkdir -p "$ANDROID_OUT"
  for i in 1 2 3; do
    sips -Z 720 "$ANDROID_SRC/step${i}.png" --out "$ANDROID_OUT/step-${i}.png" >/dev/null
  done
  echo "Synced Android tester steps → apps/web/public/android-tester/step-{1,2,3}.png"
fi
