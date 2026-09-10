import AppKit

// Reproducible, vector-drawn source for the application mark.
let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
func render(_ pixels: Int) throws {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let transform = NSAffineTransform()
    transform.scale(by: CGFloat(pixels) / 1024)
    transform.concat()
    let tile = NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896), xRadius: 200, yRadius: 200)
    NSGradient(starting: NSColor(srgbRed: 0.16, green: 0.35, blue: 0.95, alpha: 1),
               ending: NSColor(srgbRed: 0.04, green: 0.10, blue: 0.30, alpha: 1))!.draw(in: tile, angle: -90)
    func screen(_ rect: NSRect, _ color: NSColor) {
        color.setStroke()
        let outline = NSBezierPath(roundedRect: rect, xRadius: 32, yRadius: 32)
        outline.lineWidth = 25
        outline.stroke()
    }
    screen(NSRect(x: 216, y: 442, width: 400, height: 286), NSColor.white.withAlphaComponent(0.55))
    NSColor(srgbRed: 0.10, green: 0.23, blue: 0.58, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 396, y: 286, width: 400, height: 286), xRadius: 32, yRadius: 32).fill()
    screen(NSRect(x: 396, y: 286, width: 400, height: 286), .white)
    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: 458, y: 429))
    arrow.line(to: NSPoint(x: 728, y: 429))
    arrow.move(to: NSPoint(x: 680, y: 477))
    arrow.line(to: NSPoint(x: 728, y: 429))
    arrow.line(to: NSPoint(x: 680, y: 381))
    arrow.lineWidth = 25
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    NSColor(srgbRed: 0.35, green: 0.94, blue: 0.93, alpha: 1).setStroke()
    arrow.stroke()
    NSGraphicsContext.restoreGraphicsState()
    let data = bitmap.representation(using: .png, properties: [:])!
    for size in [16, 32, 128, 256, 512] {
        if pixels == size { try data.write(to: directory.appendingPathComponent("icon_\(size)x\(size).png")) }
        if pixels == size * 2 { try data.write(to: directory.appendingPathComponent("icon_\(size)x\(size)@2x.png")) }
    }
}
for pixels in [16, 32, 64, 128, 256, 512, 1024] { try render(pixels) }
