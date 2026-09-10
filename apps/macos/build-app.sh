#!/bin/sh
set -eu
cd "$(dirname "$0")"
swift build -c release
mkdir -p dist/ScreenSwitcher.app/Contents/MacOS
cp .build/release/ScreenSwitcher dist/ScreenSwitcher.app/Contents/MacOS/ScreenSwitcher
cp Info.plist dist/ScreenSwitcher.app/Contents/Info.plist
mkdir -p dist/ScreenSwitcher.app/Contents/Resources
swift Scripts/make-icon.swift .build/AppIcon.iconset
iconutil -c icns .build/AppIcon.iconset -o dist/ScreenSwitcher.app/Contents/Resources/AppIcon.icns
ditto .build/release/ScreenSwitcher_ScreenSwitcher.bundle dist/ScreenSwitcher.app/Contents/Resources/ScreenSwitcher_ScreenSwitcher.bundle
# Public/local builds remain possible without Apple credentials. A requested
# signing identity must succeed; never silently fall back to an ad-hoc signature.
if [ -n "${SIGNING_IDENTITY:-}" ] && [ "$SIGNING_IDENTITY" != "-" ]; then
    codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" dist/ScreenSwitcher.app
else
    codesign --force --sign - dist/ScreenSwitcher.app
fi
codesign --verify --deep --strict dist/ScreenSwitcher.app
