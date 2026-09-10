#!/bin/sh
# Integration test: requires a local Developer ID identity and network timestamping.
set -eu
cd "$(dirname "$0")/.."
: "${SIGNING_IDENTITY:?Set SIGNING_IDENTITY to a Developer ID Application SHA-1 fingerprint}"
sh build-app.sh
signature=$(codesign -dvv dist/ScreenSwitcher.app 2>&1)
printf '%s\n' "$signature"
printf '%s\n' "$signature" | grep -q '^Authority=Developer ID Application:' || { echo 'FAIL: missing Developer ID signature' >&2; exit 1; }
printf '%s\n' "$signature" | grep -q 'flags=.*runtime' || { echo 'FAIL: hardened runtime missing' >&2; exit 1; }
printf '%s\n' "$signature" | grep -q '^Timestamp=' || { echo 'FAIL: secure timestamp missing' >&2; exit 1; }
codesign --verify --deep --strict dist/ScreenSwitcher.app
echo 'Developer ID signing checks passed.'
