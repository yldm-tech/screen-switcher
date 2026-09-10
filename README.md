# Screen Switcher

[简体中文](README.zh-CN.md) · [Contributing](CONTRIBUTING.md) · [MIT License](LICENSE)

A native macOS menu-bar utility for switching between mirrored and extended displays.
Built with Swift and AppKit, without third-party dependencies.

**Early-stage project:** build and resource checks are automated; full physical-display
and UI validation is incomplete. There are no notarized binary releases yet.

## Features

- One mirror switch: **on = mirror**, **off = extend**.
- Choose a mirror source while mirroring; other connected displays follow it.
- Automatic status updates when display configuration changes.
- Launch at login using macOS Login Items.
- Follow system language or select English, Simplified Chinese, Japanese, Korean,
  Spanish, French, or German.
- Matching app and monochrome menu-bar icons.

## Build and run

Requires macOS 13+ and Xcode or Apple Command Line Tools with Swift 5.9+.
Mirroring requires at least two online displays.

```sh
git clone https://github.com/yldm-tech/screen-switcher.git
cd screen-switcher
sh build-app.sh
open dist/ScreenSwitcher.app
```

The build creates an ad-hoc signed app for the current machine's architecture;
it is not a universal or notarized distribution. Run the packaged app rather
than `swift run` for notification, icon, and login-item integration.
Keep the app at a stable location (for example, Applications) before enabling launch at login.

Click the menu-bar icon and use the mirror switch. While mirroring, open **Mirror Source**
to choose a display. Language and Launch at Login are directly accessible from the main menu.
Display IDs distinguish similarly named displays. A numeric fallback appears when macOS
does not expose a name. Source selection reflects the current session, not a saved preset.

## Verification

```sh
sh Scripts/verify.sh
```

Builds Debug and Release, validates translation keys and packaged resource lookup,
checks icons and signatures, and runs structural menu checks. It does not change your
physical display setup. See [the manual checklist](docs/TESTING.md) for hardware tests.

## Limitations

- Changes apply to the current login session. macOS and hardware determine supported
  mirror modes; different aspect ratios may cause scaling or black bars.
- Mirror Source selects the CoreGraphics mirror source, not a resolution preset
  or permanent primary-display preference.
- Some virtual displays, adapters, and multi-display combinations may be unsupported.
- UI interactions and Login Items require manual validation. Login items may need
  approval in System Settings.
- No timed rollback is implemented. If a configuration is unsuitable, switch mirroring
  off or use macOS System Settings → Displays.

## Privacy and security

No analytics, application network requests, or screen capture are implemented.
Display information is read locally; language selection is stored in UserDefaults.
Notification permission is optional. See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE), including the native icon drawing source.
