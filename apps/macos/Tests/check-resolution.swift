import Foundation

@main
struct CheckResolution {
    static func main() {
        if let expectedResources = CommandLine.arguments.dropFirst().first {
            precondition(Localization.resources.bundleURL.standardizedFileURL.path == URL(fileURLWithPath: expectedResources).standardizedFileURL.path,
                         "Must load resources from the packaged bundle, not the build folder")
        }
        assert(Localization.resolvedLanguage(selection: "system", preferred: ["ja-JP"]) == "ja")
        assert(Localization.resolvedLanguage(selection: "system", preferred: ["zh-CN"]) == "zh-Hans")
        assert(Localization.resolvedLanguage(selection: "de", preferred: ["ja"]) == "de")
        assert(Localization.resolvedLanguage(selection: "system", preferred: ["xx"]) == "en")
        let previous = UserDefaults.standard.object(forKey: "appLanguage")
        defer { UserDefaults.standard.set(previous, forKey: "appLanguage") }
        for language in Localization.languages {
            Localization.selection = language
            assert(L("menu.about") != "menu.about")
            assert(L("about.description") != "about.description")
            assert(!LF("about.version", "1.0").contains("%@"))
        }
        Localization.selection = "zh-Hans"
        assert(L("menu.settings") == "设置")
        Localization.selection = "ja"
        assert(L("menu.settings") == "設定")
        Localization.selection = "en"
        assert(L("menu.settings") == "Settings")
        print("Resolution, live language changes, and resource lookup: PASS")
    }
}
