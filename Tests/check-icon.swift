import AppKit
let app = Bundle(path: "dist/ScreenSwitcher.app")!
guard let name = app.object(forInfoDictionaryKey: "CFBundleIconFile") as? String,
      let url = app.url(forResource: name, withExtension: "icns"),
      let image = NSImage(contentsOf: url), image.isValid else {
    print("FAIL: packaged app icon is missing or unreadable")
    exit(1)
}
print("PASS: packaged icon decodes successfully")
