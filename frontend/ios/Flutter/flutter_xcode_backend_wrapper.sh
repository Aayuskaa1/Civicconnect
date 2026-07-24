#!/bin/sh
export COPYFILE_DISABLE=1
# Wrapper for Flutter xcode_backend that also:
# 1) keeps build/ outside Documents (avoids macOS File Provider / rsync failures)
# 2) strips Finder/resource metadata that break codesign

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
FRONTEND_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"

# Ensure build output is a symlink to /tmp before Flutter prepare/copy runs.
if [ -x "$FRONTEND_DIR/scripts/setup_ios_build_dir.sh" ]; then
  /bin/bash "$FRONTEND_DIR/scripts/setup_ios_build_dir.sh" || true
fi

FLUTTER_ROOT_VALUE="${FLUTTER_ROOT:-}"
if [ -z "$FLUTTER_ROOT_VALUE" ] && [ -f "$SCRIPT_DIR/Generated.xcconfig" ]; then
  FLUTTER_ROOT_VALUE="$(awk -F= '/^FLUTTER_ROOT=/{print $2; exit}' "$SCRIPT_DIR/Generated.xcconfig")"
fi
export FLUTTER_ROOT="$FLUTTER_ROOT_VALUE"

FLUTTER_TOOL="$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
if [ -x "$FLUTTER_TOOL" ]; then
  /bin/sh "$FLUTTER_TOOL" "$@"
  BACKEND_EXIT_CODE=$?
else
  echo "error: Flutter xcode backend not found at: $FLUTTER_TOOL" >&2
  echo "error: Ensure FLUTTER_ROOT is set and Flutter is installed correctly." >&2
  BACKEND_EXIT_CODE=1
fi

# Strip extended attributes from Flutter.framework (codesign / rsync safety).
if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -n "$FRAMEWORKS_FOLDER_PATH" ]; then
  TARGET_FRAMEWORK="$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH/Flutter.framework"
  if [ -d "$TARGET_FRAMEWORK" ]; then
    echo "Stripping extended attributes from $TARGET_FRAMEWORK"
    xattr -rc "$TARGET_FRAMEWORK" 2>/dev/null || true
    dot_clean -m "$TARGET_FRAMEWORK" 2>/dev/null || true
  fi
fi

# Also strip on the app bundle if present.
if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -d "$BUILT_PRODUCTS_DIR/Runner.app" ]; then
  xattr -rc "$BUILT_PRODUCTS_DIR/Runner.app" 2>/dev/null || true
fi

exit ${BACKEND_EXIT_CODE:-0}
