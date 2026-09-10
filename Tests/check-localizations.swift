import Foundation

let root = CommandLine.arguments.dropFirst().first ?? "Sources/ScreenSwitcher/Resources"
let languages = ["en", "zh-Hans", "ja", "ko", "es", "fr", "de"]
let keys: Set<String> = ["login.approval", "mirror.source", "display.name", "menu.mirror", "menu.extend", "menu.settings", "menu.launch", "menu.quit", "menu.about", "language.title", "language.system", "status.mirror", "status.extend", "status.single", "status.format", "error.launch", "error.switch", "error.detail", "notice.mirror", "notice.extend", "about.description", "about.version", "button.ok"]
var failures = 0
for language in languages {
    let url = URL(fileURLWithPath: root).appendingPathComponent("\(language).lproj/Localizable.strings")
    guard let data = try? Data(contentsOf: url), let entries = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: String] else {
        print("FAIL: missing/invalid \(language)"); failures += 1; continue
    }
    if Set(entries.keys) != keys || entries.values.contains(where: { $0.isEmpty }) {
        print("FAIL: incomplete keys in \(language)"); failures += 1
    }
    for key in ["status.format", "error.detail", "about.version", "display.name"] {
        if !(entries[key]?.contains("%@") ?? false) { failures += 1; print("FAIL: placeholder \(language)/\(key)") }
    }
}
print("Localization checks: \(failures) failures")
exit(failures == 0 ? 0 : 1)
