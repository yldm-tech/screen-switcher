import AppKit

@main
struct IconCheck {
    static func main() throws {
        let image = MenuBarIcon.image
        precondition(image.isTemplate)
        precondition(image.size == NSSize(width: 20, height: 18))
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            fatalError("Menu icon could not render")
        }
        if let path = CommandLine.arguments.dropFirst().first {
            try png.write(to: URL(fileURLWithPath: path))
        }
        print("PASS: menu icon renders and uses template appearance")
    }
}
