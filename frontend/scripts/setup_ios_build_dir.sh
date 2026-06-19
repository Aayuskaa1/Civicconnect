#!/usr/bin/env bash
# macOS File Provider adds com.apple.provenance to build artifacts in Documents,
# which breaks iOS codesigning. Keep build output outside synced folders.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_LINK="$ROOT_DIR/build"
BUILD_DIR="/tmp/civicconnect_build"

mkdir -p "$BUILD_DIR"

if [[ -L "$BUILD_LINK" ]]; then
  exit 0
fi

if [[ -d "$BUILD_LINK" ]]; then
  rm -rf "$BUILD_LINK"
fi

ln -s "$BUILD_DIR" "$BUILD_LINK"
