import Foundation

enum Localization {
    static let languages = ["en", "zh-Hans", "ja", "ko", "es", "fr", "de"]
    static let names = ["English", "简体中文", "日本語", "한국어", "Español", "Français", "Deutsch"]
    static var selection: String {
        get { UserDefaults.standard.string(forKey: "appLanguage") ?? "system" }
        set { UserDefaults.standard.set(newValue, forKey: "appLanguage") }
    }

    static func resolvedLanguage(selection: String, preferred: [String]) -> String {
        if languages.contains(selection) { return selection }
        return Bundle.preferredLocalizations(from: languages, forPreferences: preferred).first ?? "en"
    }

    // The packaged app must not depend on SwiftPM's absolute build-directory fallback.
    static var resources: Bundle {
        if let url = Bundle.main.resourceURL?.appendingPathComponent("ScreenSwitcher_ScreenSwitcher.bundle"),
           let bundle = Bundle(url: url) { return bundle }
        return Bundle.module
    }

    static func text(_ key: String) -> String {
        let language = resolvedLanguage(selection: selection, preferred: Locale.preferredLanguages)
        let fallback = localizedBundle("en").localizedString(forKey: key, value: key, table: nil)
        return localizedBundle(language).localizedString(forKey: key, value: fallback, table: nil)
    }

    private static func localizedBundle(_ language: String) -> Bundle {
        guard let path = resources.path(forResource: language, ofType: "lproj") ?? resources.path(forResource: language.lowercased(), ofType: "lproj"),
              let bundle = Bundle(path: path) else { return resources }
        return bundle
    }
}

func L(_ key: String) -> String { Localization.text(key) }
func LF(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: L(key), arguments: arguments)
}
