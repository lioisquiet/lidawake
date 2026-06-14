import Cocoa

final class App: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ n: Notification) {
        if let b = item.button {
            b.target = self
            b.action = #selector(click)
            b.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        render()
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in self.render() }
    }

    func isAwake() -> Bool {
        let p = Process(); p.launchPath = "/usr/bin/pmset"; p.arguments = ["-g"]
        let pipe = Pipe(); p.standardOutput = pipe; try? p.run(); p.waitUntilExit()
        let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        for line in out.split(separator: "\n") where line.contains("SleepDisabled") { return line.contains("1") }
        return false
    }

    func render() {
        guard let b = item.button else { return }
        let on = isAwake()
        // minimal monochrome SF Symbol; template = adapts to light/dark menu bar
        let name = on ? "sun.max" : "moon"
        if let img = NSImage(systemSymbolName: name, accessibilityDescription: name) {
            img.isTemplate = true          // template = auto-adapts to the menu-bar
            b.contentTintColor = nil       // theme: white on dark, black on light
            b.image = img
            b.title = ""
        } else {
            b.image = nil
            b.contentTintColor = nil
            b.title = on ? "☀︎" : "☾"   // fallback glyph, adapts via system label color
        }
        b.toolTip = on
            ? "Lid: STAY AWAKE (closed lid keeps running) · click to allow sleep"
            : "Lid: normal sleep · click to STAY AWAKE"
    }

    @objc func click() {
        let ev = NSApp.currentEvent
        let isRight = ev?.type == .rightMouseUp
            || (ev?.modifierFlags.contains(.control) ?? false)
        if isRight { showQuit(); return }
        let target = isAwake() ? "0" : "1"
        let p = Process(); p.launchPath = "/usr/bin/sudo"
        p.arguments = ["-n", "/usr/bin/pmset", "-a", "disablesleep", target]
        try? p.run(); p.waitUntilExit()
        render()
    }

    func showQuit() {
        let m = NSMenu()
        let q = NSMenuItem(title: "Quit LidAwake", action: #selector(quit), keyEquivalent: "q")
        q.target = self; m.addItem(q)
        item.menu = m
        item.button?.performClick(nil)   // open it
        item.menu = nil                   // detach so normal click toggles next time
    }
    @objc func quit() { NSApplication.shared.terminate(nil) }
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let d = App(); app.delegate = d
app.run()
