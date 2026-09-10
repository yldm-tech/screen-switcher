# Verification

## Automated

`sh Scripts/verify.sh` checks:

- Debug and Release compilation, app packaging and ad-hoc signature.
- Translation key parity and selected format placeholders.
- Preferred-language resolution, manual language changes, and packaged resource lookup.
- App icon decoding and menu-bar template image rendering.
- Static wiring checks for the language menu (not a UI interaction test).

Checks do **not** exercise CoreGraphics configuration, login-item registration,
or real menu interaction. CI does not publish a release or launch the app.

## Manual hardware checklist

Run a build from `apps/macos/dist/ScreenSwitcher.app`. Save your work before changing display
configuration. A brief black screen during mode changes can be normal.

- [ ] One display: mirror switch disabled; status says single display.
- [ ] Two displays: switch on mirrors, switch off extends.
- [ ] While mirrored: choose each mirror source and verify its actual content.
- [ ] Three displays: all other displays follow the chosen source.
- [ ] Unplug/reconnect a display; status and choices update without a refresh button.
- [ ] Mixed display sizes/aspect ratios: document scaling/letterboxing behavior.
- [ ] Change every language; menu and About update; language menu remains open.
- [ ] Restart: language preference persists.
- [ ] Toggle launch at login from a stable app location; inspect macOS Login Items.
- [ ] Repeat launch: only one menu-bar instance remains.
- [ ] Light/dark appearance: icon and switch remain legible.

Record macOS version, CPU architecture, display connection type and monitor models,
but redact serial numbers, personal paths, and unrelated window contents.

At initial publication, full multi-display hardware/UI validation remains incomplete.
