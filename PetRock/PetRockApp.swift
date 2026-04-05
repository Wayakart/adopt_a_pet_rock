import SwiftUI
import AppKit
import ServiceManagement

@main
struct PetRockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

// MARK: - Naming Window (SwiftUI)

struct NamingView: View {
    @State private var rockName: String = ""
    var onDone: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Mini rock drawing via NSViewRepresentable
            RockPreview()
                .frame(width: 120, height: 120)

            Text("name your rock")
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.25))

            TextField("", text: $rockName)
                .font(.system(.title3, design: .monospaced))
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(red: 0.92, green: 0.88, blue: 0.82))
                .cornerRadius(6)
                .frame(width: 200)
                .multilineTextAlignment(.center)

            Button(action: {
                let name = rockName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    onDone(name)
                }
            }) {
                Text("done")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(red: 0.95, green: 0.92, blue: 0.87))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.45, green: 0.40, blue: 0.35))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(32)
        .frame(width: 300, height: 320)
        .background(Color(red: 0.96, green: 0.93, blue: 0.88))
    }
}

struct RockPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> RockPreviewNSView {
        RockPreviewNSView()
    }
    func updateNSView(_ nsView: RockPreviewNSView, context: Context) {}
}

class RockPreviewNSView: NSView {
    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let s = min(bounds.width, bounds.height)
        drawMiniRock(ctx: ctx, size: s)
        // Draw static eyes (looking straight ahead)
        drawMiniEye(ctx: ctx, cx: s * 0.38, cy: s * 0.60,
                    ew: s * 0.11, eh: s * 0.12, pr: s * 0.045)
        drawMiniEye(ctx: ctx, cx: s * 0.62, cy: s * 0.62,
                    ew: s * 0.12, eh: s * 0.13, pr: s * 0.05)
    }

    func drawMiniRock(ctx: CGContext, size s: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: s * 0.15, y: s * 0.25))
        path.addQuadCurve(to: CGPoint(x: s * 0.12, y: s * 0.58),
                          control: CGPoint(x: s * 0.05, y: s * 0.42))
        path.addQuadCurve(to: CGPoint(x: s * 0.25, y: s * 0.78),
                          control: CGPoint(x: s * 0.15, y: s * 0.70))
        path.addQuadCurve(to: CGPoint(x: s * 0.50, y: s * 0.88),
                          control: CGPoint(x: s * 0.35, y: s * 0.88))
        path.addQuadCurve(to: CGPoint(x: s * 0.78, y: s * 0.82),
                          control: CGPoint(x: s * 0.65, y: s * 0.90))
        path.addQuadCurve(to: CGPoint(x: s * 0.92, y: s * 0.58),
                          control: CGPoint(x: s * 0.88, y: s * 0.75))
        path.addQuadCurve(to: CGPoint(x: s * 0.88, y: s * 0.28),
                          control: CGPoint(x: s * 0.96, y: s * 0.45))
        path.addQuadCurve(to: CGPoint(x: s * 0.70, y: s * 0.12),
                          control: CGPoint(x: s * 0.85, y: s * 0.18))
        path.addQuadCurve(to: CGPoint(x: s * 0.40, y: s * 0.10),
                          control: CGPoint(x: s * 0.55, y: s * 0.08))
        path.addQuadCurve(to: CGPoint(x: s * 0.15, y: s * 0.25),
                          control: CGPoint(x: s * 0.25, y: s * 0.12))
        path.closeSubpath()

        ctx.saveGState()
        ctx.addPath(path)
        ctx.clip()
        let colors = [
            CGColor(red: 0.65, green: 0.63, blue: 0.60, alpha: 1),
            CGColor(red: 0.50, green: 0.48, blue: 0.46, alpha: 1),
            CGColor(red: 0.38, green: 0.36, blue: 0.34, alpha: 1)
        ] as CFArray
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: colors, locations: [0, 0.5, 1])!
        ctx.drawRadialGradient(g,
                               startCenter: CGPoint(x: s * 0.4, y: s * 0.65),
                               startRadius: 0,
                               endCenter: CGPoint(x: s * 0.5, y: s * 0.5),
                               endRadius: s * 0.5,
                               options: [.drawsAfterEndLocation])
        ctx.restoreGState()
    }

    func drawMiniEye(ctx: CGContext, cx: CGFloat, cy: CGFloat,
                     ew: CGFloat, eh: CGFloat, pr: CGFloat) {
        let r = CGRect(x: cx - ew, y: cy - eh, width: ew * 2, height: eh * 2)
        ctx.setFillColor(CGColor.white)
        ctx.fillEllipse(in: r)
        ctx.setStrokeColor(CGColor(gray: 0.25, alpha: 1))
        ctx.setLineWidth(1.5)
        ctx.strokeEllipse(in: r)
        ctx.setFillColor(CGColor(gray: 0.07, alpha: 1))
        ctx.fillEllipse(in: CGRect(x: cx - pr, y: cy - pr, width: pr * 2, height: pr * 2))
        let gr = pr * 0.3
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
        ctx.fillEllipse(in: CGRect(x: cx + pr * 0.25 - gr, y: cy + pr * 0.3 - gr,
                                    width: gr * 2, height: gr * 2))
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var eyeSpeed: Double
    var onChange: (Double) -> Void

    init(currentSpeed: Double, onChange: @escaping (Double) -> Void) {
        _eyeSpeed = State(initialValue: currentSpeed)
        self.onChange = onChange
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("settings")
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.25))

            VStack(spacing: 8) {
                Text("eye speed")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(Color(red: 0.45, green: 0.40, blue: 0.35))

                HStack(spacing: 12) {
                    Text("lazy")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
                    Slider(value: $eyeSpeed, in: 0.2...3.0, step: 0.1)
                        .onChange(of: eyeSpeed) { _, val in
                            onChange(val)
                        }
                    Text("frantic")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
                }
            }
        }
        .padding(24)
        .frame(width: 280, height: 140)
        .background(Color(red: 0.96, green: 0.93, blue: 0.88))
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: DispatchSourceTimer?
    let s: CGFloat = 256
    var lastMouse: CGPoint = .zero
    var namingWindow: NSWindow?
    var settingsWindow: NSWindow?
    var rockName: String?
    var eyeSpeed: Double = 1.0

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register as login item (auto-start on boot)
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        }

        // Load saved settings
        rockName = UserDefaults.standard.string(forKey: "rockName")
        let saved = UserDefaults.standard.double(forKey: "eyeSpeed")
        eyeSpeed = saved > 0 ? saved : 1.0

        if rockName == nil {
            showNamingWindow()
        } else {
            startIconTimer()
        }
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ""))
        return menu
    }

    @objc func showSettings() {
        if let existing = settingsWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = SettingsView(currentSpeed: eyeSpeed) { [weak self] val in
            self?.eyeSpeed = val
            UserDefaults.standard.set(val, forKey: "eyeSpeed")
        }

        let hostingView = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 140),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.center()
        window.title = "Pet Rock"
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }

    func showNamingWindow() {
        let namingView = NamingView { [weak self] name in
            guard let self = self else { return }
            UserDefaults.standard.set(name, forKey: "rockName")
            self.rockName = name
            self.namingWindow?.close()
            self.namingWindow = nil
            self.startIconTimer()
        }

        let hostingView = NSHostingView(rootView: namingView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.center()
        window.title = "Pet Rock"
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        namingWindow = window
    }

    func startIconTimer() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now(), repeating: .milliseconds(100))
        t.setEventHandler { [weak self] in
            self?.updateIcon()
        }
        t.resume()
        timer = t
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }

    func updateIcon() {
        let mouse = NSEvent.mouseLocation

        // Skip redraw if cursor hasn't moved enough
        let moveDx = mouse.x - lastMouse.x
        let moveDy = mouse.y - lastMouse.y
        if moveDx * moveDx + moveDy * moveDy < 25 { return }
        lastMouse = mouse

        let screen = NSScreen.main?.frame ?? .zero

        let dx = mouse.x - screen.midX
        let dy = mouse.y - 40
        let dist = sqrt(dx * dx + dy * dy)
        let maxOff: CGFloat = s * 0.045 * CGFloat(eyeSpeed)
        let norm = min(dist / (300 / CGFloat(eyeSpeed)), 1.0)

        var pdx: CGFloat = 0
        var pdy: CGFloat = 0
        if dist > 1 {
            pdx = (dx / dist) * maxOff * norm
            pdy = (dy / dist) * maxOff * norm
        }

        let image = NSImage(size: NSSize(width: s, height: s))
        image.lockFocus()

        guard let ctx = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return
        }

        // NSImage lockFocus gives us a bottom-left origin (standard macOS coords)
        drawRock(ctx: ctx, size: s)

        drawEye(ctx: ctx, cx: s * 0.38, cy: s * 0.60,
                ew: s * 0.11, eh: s * 0.12, pr: s * 0.045,
                dx: pdx, dy: pdy)
        drawEye(ctx: ctx, cx: s * 0.62, cy: s * 0.62,
                ew: s * 0.12, eh: s * 0.13, pr: s * 0.05,
                dx: pdx, dy: pdy)

        // Draw rock name at the bottom of the icon
        if let name = rockName {
            drawName(ctx: ctx, name: name, size: s)
        }

        image.unlockFocus()
        NSApp.applicationIconImage = image
    }

    func drawName(ctx: CGContext, name: String, size s: CGFloat) {
        let displayName = name.count > 12 ? String(name.prefix(11)) + "\u{2026}" : name
        let fontSize: CGFloat = s * 0.09
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.20, green: 0.17, blue: 0.14, alpha: 1.0)
        ]
        let attrStr = NSAttributedString(string: displayName, attributes: attributes)
        let textSize = attrStr.size()

        // Draw a small rounded pill behind the text
        let pillPadH: CGFloat = 8
        let pillPadV: CGFloat = 3
        let pillW = textSize.width + pillPadH * 2
        let pillH = textSize.height + pillPadV * 2
        let pillX = (s - pillW) / 2
        let pillY: CGFloat = s * 0.02

        let pillRect = CGRect(x: pillX, y: pillY, width: pillW, height: pillH)
        let pillPath = CGPath(roundedRect: pillRect, cornerWidth: pillH / 2, cornerHeight: pillH / 2, transform: nil)

        ctx.saveGState()
        ctx.addPath(pillPath)
        ctx.setFillColor(CGColor(red: 0.30, green: 0.26, blue: 0.22, alpha: 0.85))
        ctx.fillPath()
        ctx.restoreGState()

        // Draw the text centered in the pill
        let textX = pillX + pillPadH
        let textY = pillY + pillPadV

        // Use NSString drawing (requires flipping for CGContext)
        ctx.saveGState()
        // We're in bottom-left origin, NSAttributedString.draw works in flipped coords,
        // so we use NSGraphicsContext which is already set up by lockFocus
        attrStr.draw(at: NSPoint(x: textX, y: textY))
        ctx.restoreGState()
    }

    func drawRock(ctx: CGContext, size s: CGFloat) {
        // Rock shape in bottom-left origin coords (y increases upward)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: s * 0.15, y: s * 0.25))
        path.addQuadCurve(to: CGPoint(x: s * 0.12, y: s * 0.58),
                          control: CGPoint(x: s * 0.05, y: s * 0.42))
        path.addQuadCurve(to: CGPoint(x: s * 0.25, y: s * 0.78),
                          control: CGPoint(x: s * 0.15, y: s * 0.70))
        path.addQuadCurve(to: CGPoint(x: s * 0.50, y: s * 0.88),
                          control: CGPoint(x: s * 0.35, y: s * 0.88))
        path.addQuadCurve(to: CGPoint(x: s * 0.78, y: s * 0.82),
                          control: CGPoint(x: s * 0.65, y: s * 0.90))
        path.addQuadCurve(to: CGPoint(x: s * 0.92, y: s * 0.58),
                          control: CGPoint(x: s * 0.88, y: s * 0.75))
        path.addQuadCurve(to: CGPoint(x: s * 0.88, y: s * 0.28),
                          control: CGPoint(x: s * 0.96, y: s * 0.45))
        path.addQuadCurve(to: CGPoint(x: s * 0.70, y: s * 0.12),
                          control: CGPoint(x: s * 0.85, y: s * 0.18))
        path.addQuadCurve(to: CGPoint(x: s * 0.40, y: s * 0.10),
                          control: CGPoint(x: s * 0.55, y: s * 0.08))
        path.addQuadCurve(to: CGPoint(x: s * 0.15, y: s * 0.25),
                          control: CGPoint(x: s * 0.25, y: s * 0.12))
        path.closeSubpath()

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 16,
                      color: CGColor(gray: 0, alpha: 0.35))
        ctx.addPath(path)
        ctx.setFillColor(CGColor(gray: 0.5, alpha: 1))
        ctx.fillPath()
        ctx.restoreGState()

        ctx.saveGState()
        ctx.addPath(path)
        ctx.clip()
        let colors = [
            CGColor(red: 0.65, green: 0.63, blue: 0.60, alpha: 1),
            CGColor(red: 0.50, green: 0.48, blue: 0.46, alpha: 1),
            CGColor(red: 0.38, green: 0.36, blue: 0.34, alpha: 1)
        ] as CFArray
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: colors, locations: [0, 0.5, 1])!
        ctx.drawRadialGradient(g,
                               startCenter: CGPoint(x: s * 0.4, y: s * 0.65),
                               startRadius: 0,
                               endCenter: CGPoint(x: s * 0.5, y: s * 0.5),
                               endRadius: s * 0.5,
                               options: [.drawsAfterEndLocation])
        ctx.restoreGState()
    }

    func drawEye(ctx: CGContext, cx: CGFloat, cy: CGFloat,
                 ew: CGFloat, eh: CGFloat, pr: CGFloat,
                 dx: CGFloat, dy: CGFloat) {
        let r = CGRect(x: cx - ew, y: cy - eh, width: ew * 2, height: eh * 2)
        ctx.setFillColor(CGColor.white)
        ctx.fillEllipse(in: r)
        ctx.setStrokeColor(CGColor(gray: 0.25, alpha: 1))
        ctx.setLineWidth(2)
        ctx.strokeEllipse(in: r)

        let px = cx + dx, py = cy + dy
        ctx.setFillColor(CGColor(gray: 0.07, alpha: 1))
        ctx.fillEllipse(in: CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2))

        let gr = pr * 0.3
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
        ctx.fillEllipse(in: CGRect(x: px + pr * 0.25 - gr, y: py + pr * 0.3 - gr,
                                    width: gr * 2, height: gr * 2))
    }
}
