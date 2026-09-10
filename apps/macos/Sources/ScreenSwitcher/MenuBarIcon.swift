import AppKit

/// Optical-size version of the app's overlapping screens and right-arrow mark.
enum MenuBarIcon {
    static let image: NSImage = {
        let image = NSImage(size: NSSize(width: 20, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            let rear = NSBezierPath()
            rear.move(to: NSPoint(x: 7, y: 6.5))
            rear.line(to: NSPoint(x: 2.5, y: 6.5))
            rear.curve(to: NSPoint(x: 1.5, y: 7.5), controlPoint1: NSPoint(x: 1.5, y: 6.5), controlPoint2: NSPoint(x: 1.5, y: 6.5))
            rear.line(to: NSPoint(x: 1.5, y: 15.5))
            rear.curve(to: NSPoint(x: 2.5, y: 16.5), controlPoint1: NSPoint(x: 1.5, y: 16.5), controlPoint2: NSPoint(x: 1.5, y: 16.5))
            rear.line(to: NSPoint(x: 12.5, y: 16.5))
            rear.curve(to: NSPoint(x: 13.5, y: 15.5), controlPoint1: NSPoint(x: 13.5, y: 16.5), controlPoint2: NSPoint(x: 13.5, y: 16.5))
            rear.line(to: NSPoint(x: 13.5, y: 12))
            rear.lineWidth = 1.4
            rear.stroke()
            let front = NSBezierPath(roundedRect: NSRect(x: 7, y: 1.5, width: 11.5, height: 10.5), xRadius: 1.5, yRadius: 1.5)
            front.lineWidth = 1.4
            front.stroke()
            let arrow = NSBezierPath()
            arrow.move(to: NSPoint(x: 9.5, y: 6.75))
            arrow.line(to: NSPoint(x: 16, y: 6.75))
            arrow.move(to: NSPoint(x: 13.75, y: 9))
            arrow.line(to: NSPoint(x: 16, y: 6.75))
            arrow.line(to: NSPoint(x: 13.75, y: 4.5))
            arrow.lineWidth = 1.3
            arrow.lineCapStyle = .round
            arrow.lineJoinStyle = .round
            arrow.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }()
}
