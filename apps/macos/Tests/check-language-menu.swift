import Foundation

let source = try String(contentsOfFile: "Sources/ScreenSwitcher/main.swift", encoding: .utf8)
let required = [
    "menu.addItem(languageItem)",
    "item.view = button",
    "private func updateMenuTitles()",
    "updateMenuTitles()"
]
var failures = required.filter { !source.contains($0) }
if source.contains("settings.addItem(languageItem)") { failures.append("language nested in settings") }
if source.contains("DispatchQueue.main.async { self.rebuildMenu() }") { failures.append("language action rebuilds menu") }
print(failures.isEmpty ? "PASS: language menu placement and in-place update wiring" : "FAIL: \(failures)")
exit(failures.isEmpty ? 0 : 1)
