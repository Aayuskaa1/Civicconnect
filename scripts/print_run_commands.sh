#!/usr/bin/env bash
# Prints the correct flutter run command for simulator vs physical device.
set -euo pipefail

LAN_HOST="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "192.168.1.70")"

echo "Mac LAN IP: $LAN_HOST"
echo "Backend must be running on the Mac:  cd backend && npm run dev"
echo ""
echo "iOS Simulator (localhost):"
echo "  cd frontend && flutter run --dart-define=USE_LAN=false"
echo ""
echo "Physical iPhone (same Wi‑Fi as Mac):"
echo "  cd frontend && flutter run --dart-define=USE_LAN=true --dart-define=LAN_HOST=$LAN_HOST"
echo ""
echo "VS Code / Cursor launch configs:"
echo "  • Flutter: iOS Simulator (localhost)"
echo "  • Flutter: Physical iPhone (LAN)"
