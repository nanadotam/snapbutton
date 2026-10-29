// Draws the app icon and the DMG background. Usage: swift scripts/art.swift <outdir>
import AppKit

let out = CommandLine.arguments[1]

func png(_ size: NSSize, scale: CGFloat = 1, _ path: String, _ draw: (NSRect) -> Void) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * scale), pixelsHigh: Int(size.height * scale),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw(NSRect(origin: .zero, size: size))
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

func symbol(_ name: String, _ pt: CGFloat, _ color: NSColor) -> NSImage {
    let cfg = NSImage.SymbolConfiguration(pointSize: pt, weight: .semibold)
        .applying(.init(paletteColors: [color]))
    return NSImage(systemSymbolName: name, accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
}

let top = NSColor(srgbRed: 1.00, green: 0.55, blue: 0.35, alpha: 1)
let bottom = NSColor(srgbRed: 0.85, green: 0.20, blue: 0.45, alpha: 1)

// App icon, 1024 master
png(NSSize(width: 1024, height: 1024), "\(out)/icon_1024.png") { r in
    let card = r.insetBy(dx: 100, dy: 100)
    let shape = NSBezierPath(roundedRect: card, xRadius: 185, yRadius: 185)
    NSGraphicsContext.saveGraphicsState()
    let sh = NSShadow(); sh.shadowBlurRadius = 30; sh.shadowOffset = NSSize(width: 0, height: -12)
    sh.shadowColor = .black.withAlphaComponent(0.3); sh.set()
    bottom.setFill(); shape.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGradient(starting: top, ending: bottom)!.draw(in: shape, angle: -90)
    let s = symbol("camera.viewfinder", 420, .white)
    let sz = s.size
    s.draw(in: NSRect(x: r.midX - sz.width / 2, y: r.midY - sz.height / 2, width: sz.width, height: sz.height))
}

// DMG background 640x400 (@2x for sharpness)
png(NSSize(width: 640, height: 400), scale: 2, "\(out)/dmg_bg.png") { r in
    NSGradient(starting: NSColor(white: 0.99, alpha: 1), ending: NSColor(srgbRed: 1, green: 0.93, blue: 0.9, alpha: 1))!.draw(in: r, angle: -90)
    let p = NSMutableParagraphStyle(); p.alignment = .center
    ("Drag SnapButton into Applications" as NSString).draw(in: NSRect(x: 0, y: 320, width: 640, height: 40), withAttributes: [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold), .foregroundColor: bottom, .paragraphStyle: p])
    ("then open it from your Applications folder" as NSString).draw(in: NSRect(x: 0, y: 296, width: 640, height: 24), withAttributes: [
        .font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.darkGray, .paragraphStyle: p])
    let a = symbol("arrow.right", 54, bottom)
    a.draw(in: NSRect(x: 320 - a.size.width / 2, y: 190 - a.size.height / 2, width: a.size.width, height: a.size.height))
}
