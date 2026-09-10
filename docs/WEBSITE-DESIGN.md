# Website design

The page introduces Screen Switcher to Mac users and helps them build the current
source release. It must not imply that a downloadable notarized release exists.

## Direction

A quiet desktop-workspace visual, with an interactive pair of screens as the main
demonstration. This is more specific to the product than a generic app screenshot
or a collection of promotional cards. The mirror switch changes only the demo.

- Paper: #f5f7fc
- Ink: #162342
- Secondary text: #62718b
- Brand blue: #315cf6
- Accent cyan: #65dedd
- Dividers: #dce3ef

Headlines use the native system display face at a tight, large scale. Body copy
uses the system UI face; commands and demo captions use the platform monospace face.
No external fonts or runtime assets are required.

## Structure

Navigation → product statement and interactive demo → three actual capabilities →
source-build commands → limitations and FAQ → repository/license links.
On mobile, the demo follows the headline and sections stack in reading order.
Focus states, native disclosure controls, a keyboard-operable switch, copy feedback,
and reduced-motion handling are included.

## Architecture

An npm workspace at apps/web, with plain HTML, CSS, and JavaScript. Node's built-in
test runner verifies content and links, and an optional Python Playwright test
checks the rendered site. GitHub Pages deploys the static build. The macOS package
remains an independent Swift project at apps/macos.

## Localization

The navigation language picker follows browser language preferences by default.
Manual choices persist only in this website's localStorage; they are independent
of the native app's language setting. Seven JSON dictionaries live in
`apps/web/src/locales`. Semantic keys also cover metadata, accessible labels,
demo state and copy feedback. The document's `lang` updates with the chosen language.
Unsupported browser languages fall back to English. Chinese browser variants use
the available Simplified Chinese translation. Returning to “Follow browser” clears
the manual preference. Blocked storage does not prevent in-page switching.

English HTML remains readable without JavaScript. If a translation request fails,
the previous working language is retained. Canonical URL remains the same; this
single-page implementation does not publish separate indexed language URLs.
