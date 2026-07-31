#!/usr/bin/env bash
# macOS File Provider adds com.apple.provenance to build artifacts in Documents,
# which breaks iOS codesigning. Keep build output outside synced folders.
#
# Pass --clean-ios to wipe stale iOS products that trigger Xcode
# "Stale file '.../build/ios/...' is located outside of the allowed root paths" warnings.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_LINK="$ROOT_DIR/build"
BUILD_DIR="/tmp/civicconnect_build"

mkdir -p "$BUILD_DIR"

# Remove Finder duplicates like "build 2" that confuse Xcode path checks.
find "$ROOT_DIR" -maxdepth 1 \( -name 'build *' -o -name 'build 2' -o -name 'build 3' \) -exec rm -rf {} + 2>/dev/null || true

if [[ ! -L "$BUILD_LINK" ]]; then
  if [[ -d "$BUILD_LINK" ]]; then
    rm -rf "$BUILD_LINK"
  fi
  ln -s "$BUILD_DIR" "$BUILD_LINK"
fi

if [[ "${1:-}" == "--clean-ios" ]]; then
  rm -rf "$BUILD_DIR/ios" "$BUILD_DIR/native_assets"
  mkdir -p "$BUILD_DIR"
  echo "Cleared stale iOS build products under $BUILD_DIR"
fi
