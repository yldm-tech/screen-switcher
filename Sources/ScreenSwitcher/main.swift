import AppKit
import ServiceManagement
import UserNotifications

final class DisplayService {
    func displays() -> [CGDirectDisplayID] {
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(0, nil, &count) == .success else { return [] }
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetOnlineDisplayList(count, &ids, &count) == .success else { return [] }
        return Array(ids.prefix(Int(count)))
    }
    func setMirroring(_ mirror: Bool, source: CGDirectDisplayID? = nil) -> CGError {
        let ids = displays()
        guard ids.count > 1 else { return .invalidOperation }
        let main = source ?? CGMainDisplayID()
        guard ids.contains(main) else { return .invalidOperation }
        var config: CGDisplayConfigRef?
        let begin = CGBeginDisplayConfiguration(&config)
        guard begin == .success else { return begin }
        // Release the previous mirror relationships before changing their source.
        for id in ids {
            let result = CGConfigureDisplayMirrorOfDisplay(config, id, kCGNullDirectDisplay)
            guard result == .success else {
                CGCancelDisplayConfiguration(config)
                return result
            }
        }
        for id in ids where id != main {
            let result = CGConfigureDisplayMirrorOfDisplay(config, id, mirror ? main : kCGNullDirectDisplay)
            guard result == .success else {
                CGCancelDisplayConfiguration(config)
                return result
            }
        }
        return CGCompleteDisplayConfiguration(config, .forSession)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let service = DisplayService()
    private var statusItem: NSStatusItem!
    private let mirrorSwitch = NSSwitch()
    private let mirrorLabel = NSTextField(labelWithString: "")
    private let statusItemLabel = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let launchItem = NSMenuItem(title: L("menu.launch"), action: nil, keyEquivalent: "")
    private var mirrored = false
    private let sourceItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private var displayNames: [CGDirectDisplayID: String] = [:]
    private var languageButtons: [NSButton] = []
    private let languageCodes = ["system"] + Localization.languages
    private let aboutItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let languageItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let quitItem = NSMenuItem(title: "", action: nil, keyEquivalent: "q")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 菜单栏工具只允许一个实例，避免重复图标和重复监听。
        let myPID = ProcessInfo.processInfo.processIdentifier
        NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "").forEach {
            if $0.processIdentifier != myPID { _ = $0.terminate() }
        }
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = MenuBarIcon.image
        rebuildMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    private func rebuildMenu() {
        statusItem.menu?.removeAllItems()
        launchItem.title = L("menu.launch")
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        let titleItem = NSMenuItem(title: "Screen Switcher", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false; menu.addItem(titleItem)
        aboutItem.action = #selector(showAbout)
        aboutItem.target = self
        statusItemLabel.isEnabled = false; menu.addItem(statusItemLabel)
        menu.addItem(.separator())
        let modeItem = NSMenuItem(title: L("menu.mirror"), action: nil, keyEquivalent: "")
        let row = NSView(frame: NSRect(x: 0, y: 0, width: 280, height: 36))
        mirrorLabel.frame = NSRect(x: 14, y: 9, width: 208, height: 20)
        mirrorLabel.autoresizingMask = [.width]
        mirrorSwitch.frame = NSRect(x: 230, y: 6, width: 38, height: 24)
        mirrorSwitch.autoresizingMask = [.minXMargin]
        mirrorSwitch.target = self
        mirrorSwitch.action = #selector(toggleMirroring(_:))
        row.addSubview(mirrorLabel)
        row.addSubview(mirrorSwitch)
        modeItem.view = row
        menu.addItem(modeItem)
        menu.addItem(sourceItem)
        launchItem.action = #selector(toggleLaunchAtLogin); launchItem.target = self
        let languageMenu = NSMenu(title: L("language.title"))
        languageMenu.autoenablesItems = false
        languageButtons.removeAll()
        let choices = [("system", L("language.system"))] + Array(zip(Localization.languages, Localization.names))
        for (index, choice) in choices.enumerated() {
            let (code, name) = choice
            let item = NSMenuItem(title: name, action: nil, keyEquivalent: "")
            // Interactive custom views do not invoke NSMenu's dismiss-on-action path.
            let button = NSButton(radioButtonWithTitle: name, target: self, action: #selector(selectLanguage(_:)))
            button.frame = NSRect(x: 0, y: 0, width: 240, height: 28)
            button.tag = index
            button.state = Localization.selection == code ? .on : .off
            item.view = button
            item.representedObject = code
            languageButtons.append(button)
            languageMenu.addItem(item)
        }
        languageItem.submenu = languageMenu
        menu.addItem(languageItem)
        menu.addItem(launchItem)
        menu.addItem(.separator())
        menu.addItem(aboutItem)
        quitItem.action = #selector(quit); quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
        updateMenuTitles()

    }

    @objc private func selectLanguage(_ sender: NSButton) {
        guard languageCodes.indices.contains(sender.tag) else { return }
        Localization.selection = languageCodes[sender.tag]
        updateMenuTitles()
    }

    private func updateMenuTitles() {
        mirrorLabel.stringValue = L("menu.mirror")
        mirrorSwitch.setAccessibilityLabel(L("menu.mirror"))
        launchItem.title = L("menu.launch")
        aboutItem.title = L("menu.about")
        languageItem.title = L("language.title")
        languageItem.submenu?.title = languageItem.title
        quitItem.title = L("menu.quit")
        for button in languageButtons {
            button.state = languageCodes[button.tag] == Localization.selection ? .on : .off
            if button.tag == 0 { button.title = L("language.system") }
        }
        languageItem.submenu?.items.first?.title = L("language.system")
        refresh()
    }

    @objc private func toggleMirroring(_ sender: NSSwitch) {
        apply(sender.state == .on)
    }
    @objc private func selectMirrorSource(_ sender: NSMenuItem) {
        guard let number = sender.representedObject as? NSNumber else { return }
        apply(true, source: number.uint32Value)
    }
    @objc private func toggleLaunchAtLogin() {
        do {
            switch SMAppService.mainApp.status {
            case .enabled:
                try SMAppService.mainApp.unregister()
            case .requiresApproval:
                SMAppService.openSystemSettingsLoginItems()
            default:
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert(); alert.messageText = L("error.launch"); alert.informativeText = error.localizedDescription; alert.addButton(withTitle: L("button.ok")); alert.runModal()
        }
        refresh()
    }
    private func apply(_ targetMirror: Bool, source: CGDirectDisplayID? = nil) {
        refresh()
        let result = service.setMirroring(targetMirror, source: source)
        if result != .success {
            let alert = NSAlert()
            alert.messageText = L("error.switch")
            alert.informativeText = LF("error.detail", String(result.rawValue))
            alert.addButton(withTitle: L("button.ok"))
            alert.runModal()
        } else {
            let content = UNMutableNotificationContent()
            content.title = "Screen Switcher"
            content.body = L(targetMirror ? "notice.mirror" : "notice.extend")
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
        refresh()
    }
    @objc private func refresh() {
        let ids = service.displays()
        mirrored = ids.contains { CGDisplayMirrorsDisplay($0) != kCGNullDirectDisplay }
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                displayNames[number.uint32Value] = screen.localizedName
            }
        }
        sourceItem.title = L("mirror.source")
        sourceItem.isHidden = !mirrored
        sourceItem.isEnabled = ids.count > 1
        let sources = NSMenu(title: sourceItem.title)
        sources.autoenablesItems = false
        let currentSource = ids.map { CGDisplayMirrorsDisplay($0) }.first { $0 != kCGNullDirectDisplay }
        for id in ids {
            let name = displayNames[id] ?? LF("display.name", String(id))
            let item = NSMenuItem(title: "\(name) · \(id)", action: #selector(selectMirrorSource(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = NSNumber(value: id)
            item.state = id == currentSource ? .on : .off
            sources.addItem(item)
        }
        sourceItem.submenu = sources
        statusItem.button?.image = MenuBarIcon.image
        statusItem.button?.setAccessibilityLabel(L(mirrored ? "menu.mirror" : "menu.extend"))
        statusItem.button?.toolTip = L(mirrored ? "status.mirror" : "status.extend")
        let names = NSScreen.screens.compactMap { $0.localizedName.isEmpty ? nil : $0.localizedName }
        let detail = ListFormatter.localizedString(byJoining: names)
        statusItemLabel.title = LF("status.format", L(ids.count < 2 ? "status.single" : (mirrored ? "status.mirror" : "status.extend")), detail)
        mirrorSwitch.state = mirrored ? .on : .off
        mirrorSwitch.isEnabled = ids.count > 1
        mirrorLabel.textColor = ids.count > 1 ? .labelColor : .disabledControlTextColor
        mirrorSwitch.toolTip = L(mirrored ? "menu.mirror" : "menu.extend")
        let loginStatus = SMAppService.mainApp.status
        launchItem.state = loginStatus == .enabled ? .on : (loginStatus == .requiresApproval ? .mixed : .off)
        launchItem.toolTip = loginStatus == .requiresApproval ? L("login.approval") : nil
    }
    func menuWillOpen(_ menu: NSMenu) { refresh() }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func showAbout() {
        let alert = NSAlert()
        if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") {
            alert.icon = NSImage(contentsOf: url)
        }
        alert.messageText = "Screen Switcher"
        alert.informativeText = L("about.description") + "\n\n" + LF("about.version", Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
        alert.addButton(withTitle: L("button.ok"))
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate(); app.delegate = delegate
app.run()
