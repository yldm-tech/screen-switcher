# Screen Switcher

[简体中文](README.zh-CN.md) · [Contributing](CONTRIBUTING.md) · [MIT License](LICENSE)

A native macOS menu-bar utility for switching between mirrored and extended displays.
Built with Swift and AppKit, without third-party dependencies.

**Early-stage project:** build and resource checks are automated; full physical-display and UI validation is incomplete.

## Download

[Download the signed and Apple-notarized DMG](https://github.com/yldm-tech/screen-switcher/releases/latest/download/ScreenSwitcher-AppleSilicon.dmg) for Apple Silicon Macs running macOS 13+. Open the DMG and drag ScreenSwitcher into Applications. Both the app and DMG include notarization tickets. The [release page](https://github.com/yldm-tech/screen-switcher/releases/latest) includes SHA-256 checksums. Intel users can build from source below.

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
open apps/macos/dist/ScreenSwitcher.app
```

The build creates an ad-hoc signed app for the current machine's architecture;
it is not a universal or notarized distribution. Run the packaged app rather
than `swift run` for notification, icon, and login-item integration.
Keep the app at a stable location (for example, Applications) before enabling launch at login.

### Developer ID signing

Use `asc certificates list --certificate-type DEVELOPER_ID_APPLICATION --fields name,serialNumber,expirationDate` to inspect your Apple certificates. A downloaded certificate alone cannot sign an app: its matching private key must also exist in the local keychain. Find usable identities with `security find-identity -v -p codesigning`, then supply the Developer ID Application SHA-1 fingerprint:

```sh
SIGNING_IDENTITY="YOUR_DEVELOPER_ID_SHA1" sh build-app.sh
SIGNING_IDENTITY="YOUR_DEVELOPER_ID_SHA1" sh apps/macos/Tests/check-signing.sh
```

Explicit signing enables hardened runtime and a secure timestamp, requires network access, and fails on signing errors. Without `SIGNING_IDENTITY`, builds remain ad-hoc signed. This does not notarize the app or configure CI credentials. Never commit private keys or signing credentials. See the [ASC signing guide](https://docs.asccli.sh/guides/code-signing).

The upstream `macOS validation` workflow builds and notarizes an Apple Silicon DMG after validation succeeds on `main`. It reads signing secrets `BUILD_CERTIFICATE_BASE64` (encrypted P12, Base64), `P12_PASSWORD`, and `SIGNING_IDENTITY` (SHA-1 fingerprint), plus notarization secrets `APPLE_API_KEY_BASE64`, `APPLE_API_KEY_ID`, and `APPLE_API_ISSUER_ID`. It staples both app and DMG tickets, checks Gatekeeper and uploads `ScreenSwitcher-notarized-dmg` with SHA-256 checksums for seven days. PRs and forks only run unsigned/ad-hoc validation. Signing material is cleaned up even on failure; credentials are never included in the artifact.

To publish a release, update `CFBundleShortVersionString` in `apps/macos/Info.plist` to an unused `major.minor.patch` version, push to `main`, then manually run the workflow with `publish_release=true`. Only a successfully notarized DMG is published. Existing version tags/releases are not overwritten. If notarization times out, Apple may still be processing the submission: inspect Notary history before submitting again. P12 files must be tested with macOS `security import`, not only OpenSSL; incompatible PKCS#12 algorithms can produce a misleading “wrong password” error.

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

## Monorepo

- `apps/macos`: native Swift application, resources, tests, and icon generator.
- `apps/web`: dependency-free static website for `screenswitcher.yldm.tech`.
- Root scripts retain the app build entry point and run combined checks.

Website development requires Node.js 22+: `npm ci`, then `npm run dev`.
Run `npm run check:web` and `npm run build:web` for the site alone.
See [deployment](docs/DEPLOYMENT.md) for GitHub Pages and DNS setup.
