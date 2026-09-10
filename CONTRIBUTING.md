# Contributing

Bug reports, translations, and focused pull requests are welcome.

## Development

Use Node.js 22+ for website checks, and macOS 13 or later with Xcode or Apple Command Line Tools (Swift 5.9+).
Run `sh Scripts/verify.sh` before submitting a change. It builds the app and
runs standalone checks; it does not change display settings.
`swift test` is not the test entry point for this executable-only package.

Keep changes scoped and describe the behavior before and after the change.
Include test coverage where practical. Do not claim physical display validation
from a build or a simulated test. Use [the manual checklist](docs/TESTING.md).

## Translations

Edit `apps/macos/Sources/ScreenSwitcher/Resources/<language>.lproj/Localizable.strings`.
Use stable semantic keys and preserve format placeholders. When adding a key,
update every language and `apps/macos/Tests/check-localizations.swift`.
When adding a language, also update `Localization.languages`, its native name,
and the language list in the validation script and documentation.
Keep app-owned UI text out of Swift source, except product and native language names.

Website translations live in `apps/web/src/locales/<language>.json`. Keep all keys
in every dictionary and use `data-i18n` attributes for page text. Run
`npm run check:web` to validate coverage. The optional
`apps/web/tests/i18n_browser.py` test uses Python Playwright with Chrome and
the local development server on port 4321 to verify actual language changes.

## Pull requests

- Explain what changed and why; link the issue if applicable.
- Run automated checks and report any untested hardware scenarios.
- Do not include credentials, local logs, screen serial numbers, or build output.
- Translations should be checked by a fluent speaker when possible.

By submitting a contribution, you agree to license it under the project's MIT license.
Be respectful and constructive in all discussions.
