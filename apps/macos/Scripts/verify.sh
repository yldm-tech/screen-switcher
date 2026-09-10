#!/bin/sh
# Run from any directory. Never launches the UI or changes display configuration.
set -eu
cd "$(dirname "$0")/.."
validation_dir=$(mktemp -d "${TMPDIR:-/tmp}/screen-switcher-verify.XXXXXX")
trap 'rm -rf "$validation_dir"' EXIT HUP INT TERM

swift build
sh build-app.sh
swift Tests/check-localizations.swift
swift Tests/check-localizations.swift dist/ScreenSwitcher.app/Contents/Resources/ScreenSwitcher_ScreenSwitcher.bundle
swift Tests/check-language-menu.swift
swift Tests/check-icon.swift
swiftc Sources/ScreenSwitcher/MenuBarIcon.swift Tests/check-menubar-icon.swift -o "$validation_dir/icon-check"
"$validation_dir/icon-check"

# Run the localization harness in an isolated app bundle, with packaged resources.
validation_bin=$(swift build --show-bin-path)
validation_app="$validation_dir/Validation.app"
mkdir -p "$validation_app/Contents/MacOS" "$validation_app/Contents/Resources"
cp Info.plist "$validation_app/Contents/Info.plist"
ditto dist/ScreenSwitcher.app/Contents/Resources/ScreenSwitcher_ScreenSwitcher.bundle "$validation_app/Contents/Resources/ScreenSwitcher_ScreenSwitcher.bundle"
swiftc Sources/ScreenSwitcher/Localization.swift \
    "$validation_bin/ScreenSwitcher.build/DerivedSources/resource_bundle_accessor.swift" \
    Tests/check-resolution.swift -o "$validation_app/Contents/MacOS/ScreenSwitcher"
"$validation_app/Contents/MacOS/ScreenSwitcher" "$validation_app/Contents/Resources/ScreenSwitcher_ScreenSwitcher.bundle"
codesign --verify --strict dist/ScreenSwitcher.app
echo "All automated checks passed. Physical display tests remain manual."
