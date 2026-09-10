// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ScreenSwitcher",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "ScreenSwitcher", targets: ["ScreenSwitcher"])],
    targets: [
        .executableTarget(
            name: "ScreenSwitcher",
            path: "Sources/ScreenSwitcher",
            resources: [.process("Resources")]
        )
    ]
)
