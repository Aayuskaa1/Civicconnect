#!/bin/bash
set -euo pipefail

DEVICE="${1:-E1387979-29F8-40FC-B90D-C4DEC60E110C}"
OUT_DIR="${HOME}/Pictures/CivicConnect_Documentation"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$OUT_DIR"

echo "==> Boot simulator"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator >/dev/null 2>&1 || true

echo "==> Run screenshot integration test on simulator"
cd "$ROOT"
flutter test integration_test/app_screenshots_test.dart \
  -d "$DEVICE" \
  --dart-define=USE_LAN=false \
  --reporter expanded

echo "==> Collect screenshots"
find "$ROOT/build" -path '*integration_test*' -name '*.png' -print0 2>/dev/null \
  | while IFS= read -r -d '' f; do cp "$f" "$OUT_DIR/"; done

echo "==> Import into Photos"
shopt -s nullglob
for f in "$OUT_DIR"/*.png; do
  osascript -e "tell application \"Photos\" to import POSIX file \"$f\""
done

echo "Done: $OUT_DIR"
open -a Photos "$OUT_DIR" 2>/dev/null || true
