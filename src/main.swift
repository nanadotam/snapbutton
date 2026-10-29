import AppKit
import ServiceManagement

// SnapButton — a camera in the menu bar. Click it to take a screenshot.

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ note: Notification) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Take Screenshot")
            button.toolTip = "Click to take a screenshot\nRight-click for more"
            button.action = #selector(clicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        menu.addItem(withTitle: "Take Screenshot…", action: #selector(openToolbar), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Capture Part of Screen", action: #selector(captureArea), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Capture a Window", action: #selector(captureWindow), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Capture Whole Screen", action: #selector(captureScreen), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Open Screenshots Folder", action: #selector(openFolder), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Start When Mac Turns On", action: #selector(toggleLogin), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit SnapButton", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // First launch: start automatically at login so it's always there.
        if !UserDefaults.standard.bool(forKey: "didSetup") {
            UserDefaults.standard.set(true, forKey: "didSetup")
            try? SMAppService.mainApp.register()
        }
    }

    @objc private func clicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            menu.item(withTitle: "Start When Mac Turns On")?.state =
                SMAppService.mainApp.status == .enabled ? .on : .off
            item.menu = menu
            item.button?.performClick(nil)
            item.menu = nil
        } else {
            openToolbar()
        }
    }

    // Same as pressing ⌘⇧5 — Apple's own screenshot bar.
    @objc private func openToolbar() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Screenshot.app"))
    }

    @objc private func captureArea()   { run(["-i", "-s"]) }   // like ⌘⇧4
    @objc private func captureWindow() { run(["-i", "-w"]) }   // like ⌘⇧4 then Space
    @objc private func captureScreen() { run([]) }             // like ⌘⇧3

    private func run(_ args: [String]) {
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyy-MM-dd 'at' h.mm.ss a"
        let file = saveFolder().appendingPathComponent("Screenshot \(stamp.string(from: Date())).png")
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = args + [file.path]
        // Small delay so the menu closes before the shot.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { try? p.run() }
    }

    // Uses the same place the Mac already saves screenshots (Desktop by default).
    private func saveFolder() -> URL {
        if let loc = UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location") {
            let url = URL(fileURLWithPath: (loc as NSString).expandingTildeInPath)
            if FileManager.default.fileExists(atPath: url.path) { return url }
        }
        return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
    }

    @objc private func openFolder() { NSWorkspace.shared.open(saveFolder()) }

    @objc private func toggleLogin() {
        let s = SMAppService.mainApp
        if s.status == .enabled { try? s.unregister() } else { try? s.register() }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
